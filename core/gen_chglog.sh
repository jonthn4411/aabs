#! /bin/bash
#
# generate the changelog from GIT commit history
# The current working directory should be the root folder of this build system. So that it can get the history of this build system.
# $1: output directory
# $2: source code directory
# $3: the product code:such as avlite-cupcake, avlite-donut
# $4: the directory where LAST_BUILD.<product-code> LAST_REL..<product-code> locates

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
		echo "-prj:$CURRENT_PRJNAME:" >> $2
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
function gen_log_lastbuild()
{
	local output_file=${1}
	local commit=${2}

	declare -a COMMITS
	local len=0
	while read line; do
		if [ ! -z "$line" ]; then
			COMMITS[$len]=$line
			len=$(( $len + 1 ))
		fi
	done < <(git --no-pager log ${commit}..HEAD --pretty="format:%s [%an][%h][%ci]%n")

	if [ $len -gt 0 ]; then
		echo "----------------" >> $output_file
		echo "-prj:$CURRENT_PRJNAME:" >> $output_file
		echo "----------------" >> $output_file

		local i=0
		while [ $i -lt $len ]; do
			echo "    *${COMMITS[$i]}" >> $output_file
			i=$(( $i + 1 ))
		done	
		echo >> $output_file
	fi
}

#$1: output file
#$2: since
function gen_log_lastbuild_newprj()
{
	local output_file=${1}
	local since=$2

	echo "----------------" >> $output_file
	echo "-prj:$CURRENT_PRJNAME:+newly added project, commits since $since" >> $output_file
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

OUTPUT_DIR=$1
SRC_DIR=$2
PRODUCT_CODE=$3
LAST_BUILD_LOC=$4

LAST_BUILD_PACKAGE=
LAST_BUILD_BUILDNUM=
LAST_REL_PACKAGE=
LAST_REL_VERSION=
LAST_REL_BUILDNUM=

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
  if [ -z "$PRODUCT_CODE" ]; then
    echo "If last-build-location is specified, product-code must be specified in arguments."
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

if [ ! -z "$LAST_BUILD_LOC" ]; then
  if [ -e $LAST_BUILD_LOC/LAST_BUILD.${PRODUCT_CODE} ]; then
    parse_lastbuild_file $LAST_BUILD_LOC/LAST_BUILD.${PRODUCT_CODE} &&
    echo -n > "$OUTPUT_DIR/changelog.build"
    echo "Change logs since last build: $LAST_BUILD_BUILDNUM" >> "$OUTPUT_DIR/changelog.build"
    echo "" >> "$OUTPUT_DIR/changelog.build"
    echo "The last build package can be found at: $LAST_BUILD_PACKAGE" >> "$OUTPUT_DIR/changelog.build"
    echo "==============================================================" >> "$OUTPUT_DIR/changelog.build"
    echo >> "$OUTPUT_DIR/changelog.build"
  else
    echo "LAST_BUILD.${PRODUCT_CODE} is not found at $LAST_BUILD_LOC. This is the first build." > "$OUTPUT_DIR/changelog.build"
  fi &&

  if [ -e $LAST_BUILD_LOC/LAST_REL.${PRODUCT_CODE} ]; then
    parse_lastrel_file $LAST_BUILD_LOC/LAST_REL.${PRODUCT_CODE} &&
    echo -n > "$OUTPUT_DIR/changelog.rel"
    echo "Change logs since last release: $LAST_REL_VERSION" >> "$OUTPUT_DIR/changelog.rel"
	echo "" >> "$OUTPUT_DIR/changelog.rel"
    echo "The last release package can be found at: $LAST_REL_PACKAGE" >> "$OUTPUT_DIR/changelog.rel"
    echo "==============================================================" >> "$OUTPUT_DIR/changelog.rel"
    echo >> "$OUTPUT_DIR/changelog.build"
  else
    echo "LAST_REL.${PRODUCT_CODE} is not found at $LAST_BUILD_LOC. This is the first release." > "$OUTPUT_DIR/changelog.rel"
  fi
fi &&

CURRENT_PRJNAME=aabs &&
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

cd $SRC_DIR &&
PRJS=$(repo forall -c "echo -n \$REPO_PROJECT:;pwd") &&
for prj in $PRJS
do
  CURRENT_PRJNAME=${prj%%:*} &&
  CURRENT_PRJPATH=${prj##*:} &&
  cd $CURRENT_PRJPATH &&
  echo "  log for: $CURRENT_PRJNAME " &&
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
  else
    gen_log_lastbuild_newprj $OUTPUT_DIR/changelog.rel "3 months ago"
  fi &&
  cd - >/dev/null
done


