#! /bin/bash
#
# generate the changelog from GIT commit history
# The current working directory should be the root folder of this build system. So that it can get the history of this build system.
# $1: output directory
# $2: source code directory
# $3: the manifest branch name: such as avlite-donut or rls_avlite_donut_beta1
# $4: the directory where LAST_BUILD.<manifest-branch-name> LAST_REL.<manifest-branch-name> locates

#$1: since
#$2: logfile
function gen_log()
{
	declare -a COMMITS
	local len=0
	while read line; do
		if [ ! -z "$line" ]; then
			COMMITS[$len]=$line
			len=$(( $len + 1 ))
		fi
	done < <(git --no-pager log --since="$1" --pretty="format:%s [%an][%h][%ci]%n")

	if [ $len -gt 0 ]; then
		echo "----------------" >> $2
		echo "-prj:$CURRENT_PRJNAME: [$CURRENT_PRJORG]" >> $2
		echo "----------------" >> $2

		local i=0
		while [ $i -lt $len ]; do
			echo "    *${COMMITS[$i]}" >> $2
			i=$(( $i + 1 ))
		done	
		echo >> $2
	fi
}

#$1: output file
#$2: commit
#$3: milestone: milestone log which shows commits in both branches.
function gen_log_lastbuild()
{
	local output_file=${1}
	local commit=${2}
	local ms=${3}

	declare -a COMMITS
	local len=0

	if [ -z "$ms" ]; then
		while read line; do
			if [ ! -z "$line" ]; then
				COMMITS[$len]=$line
				len=$(( $len + 1 ))
			fi
		done < <(git --no-pager log ${commit}..HEAD --pretty="format:%s [%an][%h][%ci]%n")
	else
		while read line; do
			if [ ! -z "$line" ]; then
				COMMITS[$len]=$line
				len=$(( $len + 1 ))
			fi
		done < <(git --no-pager log ${commit}...HEAD --left-right --boundary --cherry-pick --topo-order --pretty="format:%m%s [%an][%h][%ci]%n")
	fi

	if [ $len -gt 0 ]; then
		echo "----------------" >> $output_file
		echo "-prj:$CURRENT_PRJNAME: [$CURRENT_PRJORG]" >> $output_file
		echo "----------------" >> $output_file

		local i=0
		while [ $i -lt $len ]; do
			echo "    *${COMMITS[$i]}" >> $output_file
			i=$(( $i + 1 ))
		done	
		echo >> $output_file
	else
		#If the HEAD's SHA1 is not equal to the commit, and there is no log generated,
		#in this case we shall still generate a log and force the build to continue.
		#This can be a) the commit is lost due to force update the branch. b) the commit is later than HEAD.
		head_commit=$(git rev-parse HEAD)
		if [ ! "${commit}" == "${head_commit}" ]; then
			echo "----------------" >> $output_file
			echo "-prj:$CURRENT_PRJNAME:+the project's branch was force updated. Need attention! [$CURRENT_PRJORG]" >> $output_file
			echo "----------------" >> $output_file

			echo "    *Last commit:${commit}; current HEAD's commit:${head_commit}" >> $output_file
		fi 
	fi
}

#$1: output file
#$2: since
function gen_log_lastbuild_newprj()
{
	local output_file=${1}
	local since=$2

	echo "----------------" >> $output_file
	echo "-prj:$CURRENT_PRJNAME:+newly added project, commits since $since. [$CURRENT_PRJORG]" >> $output_file
	echo "----------------" >> $output_file

	declare -a COMMITS
	local len=0
	while read line; do
		if [ ! -z "$line" ]; then
			COMMITS[$len]=$line
			len=$(( $len + 1 ))
		fi
	done < <(git --no-pager log --since="$since" --pretty="format:%s [%an][%h][%ci]%n")

	local i=0
	while [ $i -lt $len ]; do
		echo "    *${COMMITS[$i]}" >> $output_file
		i=$(( $i + 1 ))
	done	

	echo >> $output_file
}

#$1:file name
function parse_lastbuild_file()
{
  local line
  line=$(grep "[:blank:]*Package:" $1)
  LAST_BUILD_PACKAGE=${line##Package:}
  line=$(grep "[:blank:]*Build-Num:" $1)
  LAST_BUILD_BUILDNUM=${line##Build-Num:}

  if [ -z "$LAST_BUILD_PACKAGE" ] || [ -z "$LAST_BUILD_BUILDNUM" ]; then
    echo "Invalid format of LAST_REL file: $1"
    return 2
  fi
  if [ ! -r "$LAST_BUILD_PACKAGE/manifest.xml" ] || [ ! -r "$LAST_BUILD_PACKAGE/abs.commit" ]; then
    echo "Can't read manifest.xml or abs.commit in LAST_BUILD_PACKAGE:$LAST_BUILD_PACKAGE"
    return 3
  fi
}

function parse_lastrel_file()
{
  local line
  line=$(grep "[:blank:]*Package:" $1)
  LAST_REL_PACKAGE=${line##*Package:}

  line=$(grep "[:blank:]*Version:" $1)
  LAST_REL_VERSION=${line##*Version:}

  line=$(grep "[:blank:]*Build-Num:" $1)
  LAST_REL_BUILDNUM=${line##*Build-Num:}

  if [ -z "$LAST_REL_PACKAGE" ] || [ -z "$LAST_REL_VERSION" ] || [ -z "$LAST_REL_BUILDNUM" ]; then
    echo "Invalid format of LAST_REL file: $1"
    return 2
  fi
  if [ ! -r "$LAST_REL_PACKAGE/manifest.xml" ] || [ ! -r "$LAST_REL_PACKAGE/abs.commit" ]; then
    echo "Can't read manifest.xml or abs.commit in LAST_REL_PACKAGE:$LAST_REL_PACKAGE"
    return 3
  fi
}

function parse_last_ms1_file()
{
  local line
  line=$(grep "[:blank:]*Package:" $1)
  LAST_MS1_PACKAGE=${line##*Package:}

  line=$(grep "[:blank:]*Version:" $1)
  LAST_MS1_VERSION=${line##*Version:}

  line=$(grep "[:blank:]*Build-Num:" $1)
  LAST_MS1_BUILDNUM=${line##*Build-Num:}

  if [ -z "$LAST_MS1_PACKAGE" ] || [ -z "$LAST_MS1_VERSION" ] || [ -z "$LAST_MS1_BUILDNUM" ]; then
    echo "Invalid format of LAST_MS1 file: $1"
    return 2
  fi
  if [ ! -r "$LAST_MS1_PACKAGE/manifest.xml" ] || [ ! -r "$LAST_MS1_PACKAGE/abs.commit" ]; then
    echo "Can't read manifest.xml or abs.commit in LAST_MS1_PACKAGE:$LAST_MS1_PACKAGE"
    return 3
  fi
}

function parse_last_ms2_file()
{
  local line
  line=$(grep "[:blank:]*Package:" $1)
  LAST_MS2_PACKAGE=${line##*Package:}

  line=$(grep "[:blank:]*Version:" $1)
  LAST_MS2_VERSION=${line##*Version:}

  line=$(grep "[:blank:]*Build-Num:" $1)
  LAST_MS2_BUILDNUM=${line##*Build-Num:}

  if [ -z "$LAST_MS2_PACKAGE" ] || [ -z "$LAST_MS2_VERSION" ] || [ -z "$LAST_MS2_BUILDNUM" ]; then
    echo "Invalid format of LAST_MS2 file: $1"
    return 2
  fi
  if [ ! -r "$LAST_MS2_PACKAGE/manifest.xml" ] || [ ! -r "$LAST_MS2_PACKAGE/abs.commit" ]; then
    echo "Can't read manifest.xml or abs.commit in LAST_MS2_PACKAGE:$LAST_MS2_PACKAGE"
    return 3
  fi
}

OUTPUT_DIR=$1
SRC_DIR=$2
MANIFEST_BRANCH=$3
LAST_BUILD_LOC=$4

LAST_BUILD_PACKAGE=
LAST_BUILD_BUILDNUM=

LAST_REL_PACKAGE=
LAST_REL_VERSION=
LAST_REL_BUILDNUM=

LAST_MS1_PACKAGE=
LAST_MS1_VERSION=
LAST_MS1_BUILDNUM=

LAST_MS2_PACKAGE=
LAST_MS2_VERSION=
LAST_MS2_BUILDNUM=

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

if [ ! -z "$LAST_BUILD_LOC" ]; then
  if [ -z "$MANIFEST_BRANCH" ]; then
    echo "If last-build-location is specified, MANIFEST_BRANCH must be specified in arguments."
    exit 1
  fi
fi

if [ ! ${OUTPUT_DIR:0:1} == '/' ]; then
  OUTPUT_DIR=$(pwd)/$OUTPUT_DIR
fi

if [ ! ${SRC_DIR:0:1} == '/' ]; then
  SRC_DIR=$(pwd)/$SRC_DIR
fi

if [ ! -z "$LAST_BUILD_LOC" ] && [ ! "${LAST_BUILD_LOC:0:1}" == '/' ]; then
  LAST_BUILD_LOC=$(pwd)/$SRC_DIR
fi

if [ -n "$ABS_UNIQUE_MANIFEST_BRANCH" ]; then
  if [ -n "$RELEASE_NAME" ]; then
    RELEASE_BRANCH=rls_${MANIFEST_BRANCH/-/_}_${RELEASE_NAME}
  fi
fi

LAST_BUILD_FILE=LAST_BUILD.${RELEASE_BRANCH}
LAST_REL_FILE=LAST_REL.${RELEASE_BRANCH}
LAST_MS1_FILE=LAST_MS1.${RELEASE_BRANCH}
LAST_MS2_FILE=LAST_MS2.${RELEASE_BRANCH}

if [ ! -z "$LAST_BUILD_LOC" ]; then
  if [ -e $LAST_BUILD_LOC/${LAST_BUILD_FILE} ]; then
    parse_lastbuild_file $LAST_BUILD_LOC/${LAST_BUILD_FILE} &&
    echo -n > "$OUTPUT_DIR/changelog.build"
    echo "Change logs since last build: $LAST_BUILD_BUILDNUM" >> "$OUTPUT_DIR/changelog.build"
    echo "" >> "$OUTPUT_DIR/changelog.build"
    echo "The last build package can be found at: $LAST_BUILD_PACKAGE" >> "$OUTPUT_DIR/changelog.build"
    echo "==============================================================" >> "$OUTPUT_DIR/changelog.build"
    echo >> "$OUTPUT_DIR/changelog.build"
  else
    echo "${LAST_BUILD_FILE} is not found at $LAST_BUILD_LOC. This is the first build." > "$OUTPUT_DIR/changelog.build"
  fi &&

  if [ -e $LAST_BUILD_LOC/${LAST_REL_FILE} ]; then
    parse_lastrel_file $LAST_BUILD_LOC/${LAST_REL_FILE} &&
    echo -n > "$OUTPUT_DIR/changelog.rel"
    echo "Change logs since last release: $LAST_REL_VERSION" >> "$OUTPUT_DIR/changelog.rel"
	echo "" >> "$OUTPUT_DIR/changelog.rel"
    echo "The last release package can be found at: $LAST_REL_PACKAGE" >> "$OUTPUT_DIR/changelog.rel"
    echo "==============================================================" >> "$OUTPUT_DIR/changelog.rel"
    echo >> "$OUTPUT_DIR/changelog.rel"
  fi &&

  if [ -e $LAST_BUILD_LOC/${LAST_MS1_FILE} ]; then
    parse_last_ms1_file $LAST_BUILD_LOC/${LAST_MS1_FILE} &&
    echo -n > "$OUTPUT_DIR/changelog.ms1"
    echo "Change logs since last milestone: $LAST_MS1_VERSION" >> "$OUTPUT_DIR/changelog.ms1"
	echo 'Notes: commit begin with > is the change in current release' >> "$OUTPUT_DIR/changelog.ms1"
	echo "       commit begin with < is the change in [$LAST_MS1_VERSION]" >> "$OUTPUT_DIR/changelog.ms1"
	echo '       commit begin with - is the diverse point' >> "$OUTPUT_DIR/changelog.ms1"
	echo "" >> "$OUTPUT_DIR/changelog.ms1"
    echo "The last release package can be found at: $LAST_MS1_PACKAGE" >> "$OUTPUT_DIR/changelog.ms1"
    echo "==============================================================" >> "$OUTPUT_DIR/changelog.ms1"
    echo >> "$OUTPUT_DIR/changelog.ms1"
  fi &&

  if [ -e $LAST_BUILD_LOC/${LAST_MS2_FILE} ]; then
    parse_last_ms2_file $LAST_BUILD_LOC/${LAST_MS2_FILE} &&
    echo -n > "$OUTPUT_DIR/changelog.ms2"
    echo "Change logs since last milestone: $LAST_MS2_VERSION" >> "$OUTPUT_DIR/changelog.ms2"
	echo 'Notes: commit begin with > is the change in current release' >> "$OUTPUT_DIR/changelog.ms2"
	echo '       commit begin with < is the change in [$LAST_MS1_VERSION]' >> "$OUTPUT_DIR/changelog.ms2"
	echo '       commit begin with - is the diverse point' >> "$OUTPUT_DIR/changelog.ms2"
	echo "" >> "$OUTPUT_DIR/changelog.ms2"
    echo "The last release package can be found at: $LAST_MS2_PACKAGE" >> "$OUTPUT_DIR/changelog.ms2"
    echo "==============================================================" >> "$OUTPUT_DIR/changelog.ms2"
    echo >> "$OUTPUT_DIR/changelog.ms2"
  fi

fi &&

CURRENT_PRJNAME=aabs &&
CURRENT_PRJORG=master &&
echo "  log for: $CURRENT_PRJNAME " &&
echo -n > $OUTPUT_DIR/changelog.day    && gen_log "1 day ago"   "$OUTPUT_DIR/changelog.day" &&
echo -n > $OUTPUT_DIR/changelog.week   && gen_log "1 week ago"  "$OUTPUT_DIR/changelog.week" &&
echo -n > $OUTPUT_DIR/changelog.biweek && gen_log "2 weeks ago" "$OUTPUT_DIR/changelog.biweek" &&
echo -n > $OUTPUT_DIR/changelog.month  && gen_log "1 month ago" "$OUTPUT_DIR/changelog.month" &&
if [ ! -z "$LAST_BUILD_PACKAGE" ]; then
  commit=$(cat $LAST_BUILD_PACKAGE/abs.commit) &&
  gen_log_lastbuild $OUTPUT_DIR/changelog.build $commit 
fi &&

if [ ! -z "$LAST_REL_PACKAGE" ]; then
  commit=$(cat $LAST_REL_PACKAGE/abs.commit) &&
  gen_log_lastbuild $OUTPUT_DIR/changelog.rel $commit
fi &&

if [ ! -z "$LAST_MS1_PACKAGE" ]; then
  commit=$(cat $LAST_MS1_PACKAGE/abs.commit) &&
  gen_log_lastbuild $OUTPUT_DIR/changelog.ms1 $commit milestone
fi &&

if [ ! -z "$LAST_MS2_PACKAGE" ]; then
  commit=$(cat $LAST_MS2_PACKAGE/abs.commit) &&
  gen_log_lastbuild $OUTPUT_DIR/changelog.ms2 $commit milestone
fi &&

cd $SRC_DIR &&
PRJS=$(repo forall -c "echo -n \$REPO_PROJECT:;pwd") &&
for prj in $PRJS
do
  CURRENT_PRJNAME=${prj%%:*} &&
  CURRENT_PRJPATH=${prj##*:} &&
  cd $CURRENT_PRJPATH &&
  echo "========="
  echo "  log for: $CURRENT_PRJNAME " &&
  BRANCH=$(cat .git/refs/remotes/m/$MANIFEST_BRANCH) &&
  CURRENT_PRJORG=${BRANCH##ref: refs\/remotes\/} &&
  gen_log "1 day ago"   "$OUTPUT_DIR/changelog.day" &&
  gen_log "1 week ago"  "$OUTPUT_DIR/changelog.week" &&
  gen_log "2 weeks ago" "$OUTPUT_DIR/changelog.biweek" &&
  gen_log "1 month ago" "$OUTPUT_DIR/changelog.month" &&
  
  if [ ! -z "$LAST_BUILD_PACKAGE" ]; then
    commit=$(${GET_REV_APP} -m $LAST_BUILD_PACKAGE/manifest.xml $CURRENT_PRJNAME 2>/dev/null) 
    if [ -z "$commit" ]; then
      gen_log_lastbuild_newprj $OUTPUT_DIR/changelog.build "2 weeks ago"
    else  
      gen_log_lastbuild $OUTPUT_DIR/changelog.build $commit 
    fi
  else
    gen_log_lastbuild_newprj $OUTPUT_DIR/changelog.build "2 weeks ago"
  fi &&

  if [ ! -z "$LAST_REL_PACKAGE" ]; then
    commit=$(${GET_REV_APP} -m $LAST_REL_PACKAGE/manifest.xml $CURRENT_PRJNAME 2>/dev/null) 
    if [ -z "$commit" ]; then
      gen_log_lastbuild_newprj $OUTPUT_DIR/changelog.rel "3 months ago"
    else
      gen_log_lastbuild $OUTPUT_DIR/changelog.rel $commit
    fi
  fi &&

  if [ ! -z "$LAST_MS1_PACKAGE" ]; then
    commit=$(${GET_REV_APP} -m $LAST_MS1_PACKAGE/manifest.xml $CURRENT_PRJNAME 2>/dev/null) 
    if [ -z "$commit" ]; then
      gen_log_lastbuild_newprj $OUTPUT_DIR/changelog.ms1 "3 months ago"
    else
      gen_log_lastbuild $OUTPUT_DIR/changelog.ms1 $commit milestone
    fi
  fi &&

  if [ ! -z "$LAST_MS2_PACKAGE" ]; then
    commit=$(${GET_REV_APP} -m $LAST_MS2_PACKAGE/manifest.xml $CURRENT_PRJNAME 2>/dev/null) 
    if [ -z "$commit" ]; then
      gen_log_lastbuild_newprj $OUTPUT_DIR/changelog.ms2 "3 months ago"
    else
      gen_log_lastbuild $OUTPUT_DIR/changelog.ms2 $commit milestone
    fi
  fi &&

  cd - >/dev/null
done


