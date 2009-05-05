#! /bin/bash
#
# generate the changelog from GIT commit history
#
# $1: output directory
# 

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

gen_log "1 day ago" "$1/changelog.day"
gen_log "1 week ago" "$1/changelog.week"
gen_log "2 weeks ago" "$1/changelog.biweek"
gen_log "1 month ago" "$1/changelog.month"
