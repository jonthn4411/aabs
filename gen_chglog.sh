#! /bin/bash
#
# generate the changelog from GIT commit history
#
# $1: output directory
# $2: source code directory

function project_name()
{
	PWD=$(pwd)
	echo ${PWD##\/*\/}
}

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
	done < <(git --no-pager log --since="$1" --pretty="format:%s [%h]%n")

	if [ $len -gt 0 ]; then
		echo "--------" >> $2
		echo "$(project_name):$REPO_PROJECT" >> $2
		echo "--------" >> $2

		local i=0
		while [ $i -lt $len ]; do
			echo "    *${COMMITS[$i]}" >> $2
			i=$(( $i + 1 ))
		done	
		echo >> $2
	fi
}

OUTPUT_DIR=$1
SRC_DIR=$2

if [[ ! -d "$SRC_DIR" ]] || [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "source dir($SRC_DIR) or output dir($OUTPUT_DIR) doesn't exit"
  exit 1
fi

echo "  log for: $(project_name) "
echo -n > $OUTPUT_DIR/changelog.day    && gen_log "1 day ago"   "$OUTPUT_DIR/changelog.day" &&
echo -n > $OUTPUT_DIR/changelog.week   && gen_log "1 week ago"  "$OUTPUT_DIR/changelog.week" &&
echo -n > $OUTPUT_DIR/changelog.biweek && gen_log "2 weeks ago" "$OUTPUT_DIR/changelog.biweek" &&
echo -n > $OUTPUT_DIR/changelog.month  && gen_log "1 month ago" "$OUTPUT_DIR/changelog.month" &&

cd $SRC_DIR &&
PRJS=$(repo forall -c "pwd") &&
for prj in $PRJS
do
  cd $prj &&
  echo "  log for: $(project_name) " &&
  gen_log "1 day ago"   "$OUTPUT_DIR/changelog.day" &&
  gen_log "1 week ago"  "$OUTPUT_DIR/changelog.week" &&
  gen_log "2 weeks ago" "$OUTPUT_DIR/changelog.biweek" &&
  gen_log "1 month ago" "$OUTPUT_DIR/changelog.month" &&
  cd - >/dev/null
done


