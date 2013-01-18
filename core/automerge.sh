#! /bin/bash
#
# automerge from the parent branch
# The current working directory should be the root folder of this build system. So that it can get the history of this build system.
# $1: output directory
# $2: source code directory
# $3: the manifest branch name: such as avlite-donut or rls_avlite_donut_beta1
# $4: the directory where LAST_BUILD.<manifest-branch-name> LAST_REL.<manifest-branch-name> locates

OUTPUT_DIR=$1
SRC_DIR=$2
MANIFEST_BRANCH=$3
LAST_BUILD_LOC=$4
LAST_BUILD_FILE=
LAST_BUILD_PACKAGE=
LAST_BUILD_MANIFEST=

THIS_APP=$0
#assuming that get_rev.sh app locates at the same folder of this script.
if [ -z "$(echo $THIS_APP | grep /)" ]; then
  GET_REV_APP=get_rev.sh
else
  if [ ${THIS_APP:0:1} == '/' ]; then
    GET_REV_APP=${THIS_APP%/*}/get_rev.sh
  else
    GET_REV_APP=$(pwd)/${THIS_APP%/*}/get_rev.sh
  fi
fi

if [[ ! -d "$SRC_DIR" ]] || [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Source dir($SRC_DIR) or output dir($OUTPUT_DIR) doesn't exit"
  exit 1
fi

if [ ! ${OUTPUT_DIR:0:1} == '/' ]; then
  OUTPUT_DIR=$(pwd)/$OUTPUT_DIR
fi

if [ ! ${SRC_DIR:0:1} == '/' ]; then
  SRC_DIR=$(pwd)/$SRC_DIR
fi

if [ ! -z "$ABS_CHILD_NAME" ]; then
  echo "automerge: starting to automerge from parent branch..."
  LAST_BUILD_FILE=$LAST_BUILD_LOC/LAST_BUILD.$ABS_PARENT_BRANCH
  if [ -e "$LAST_BUILD_FILE" ]; then
    LAST_BUILD_PACKAGE=$(awk -F: '/[:blank:]*Package/ { print $2 }' ${LAST_BUILD_FILE})
    LAST_BUILD_MANIFEST=${LAST_BUILD_PACKAGE}/manifest.xml
    echo -n > "$OUTPUT_DIR/changelog.automerge"
    echo "Merge from the parent build package: $LAST_BUILD_PACKAGE" >> "$OUTPUT_DIR/changelog.automerge"
    MERGE_CONFLICT=false
    PUSH_FAILED=false
    cd $SRC_DIR &&
    PRJS=$(repo forall -c "echo \$REPO_PROJECT:\$REPO_PATH") &&
    for prj in $PRJS
    do
      CURRENT_PRJNAME=${prj%%:*} &&
      CURRENT_PRJPATH=${prj##*:} &&
      cd $CURRENT_PRJPATH &&
      parent_commit=$(${GET_REV_APP} -m $LAST_BUILD_PACKAGE/manifest.xml $CURRENT_PRJNAME 2>/dev/null)
      if [ -z "$parent_commit" ]; then
        echo "automerge:$CURRENT_PRJPATH this project is added by child branch, not in parent branch"
      else
        head_commit=$(git rev-parse HEAD)
        git merge $parent_commit >/dev/null 2>&1
        if [ $? -eq 0 ]; then
          merge_commit=$(git rev-parse HEAD)
          if [ ! "${merge_commit}" == "${head_commit}" ]; then
            echo "----------------" >> "$OUTPUT_DIR/changelog.automerge"
            echo "-prj:$CURRENT_PRJPATH" >> "$OUTPUT_DIR/changelog.automerge"
            echo " parent commit:$parent_commit" >> "$OUTPUT_DIR/changelog.automerge"
            echo "automerge:$CURRENT_PRJPATH merge successfully, push to git server"
            remote=$(git remote)
            branch=$(cat .git/refs/remotes/m/$MANIFEST_BRANCH)
            branch=${branch##ref: refs\/remotes\/${remote}\/}
            git push $remote HEAD:$branch
            if  [ $? -eq 0 ]; then
              echo "automerge:$CURRENT_PRJPATH git push successfully"
            else
              PUSH_FAILED=true
              echo "automerge:$CURRENT_PRJPATH git push error"
            fi
          else
            echo "automerge:$CURRENT_PRJPATH merge nothing, already up to date"
          fi
        else
          MERGE_CONFLICT=true
          echo "automerge:$CURRENT_PRJPATH merge conflict, the details are as follows"
          git diff
        fi
      fi
      cd - >/dev/null
    done
    if [ "$PUSH_FAILED" = "true" ]; then
      exit 1
    fi
    if [ "$MERGE_CONFLICT" = "true" ]; then
      exit 1
    fi
  fi
fi
