#!/bin/bash
#
#

function get_date()
{
  echo $(date "+%Y-%m-%d %H:%M:%S")
}

LOG=build_platforms.log

echo | tee -a $LOG
echo "=========" | tee -a $LOG
echo "New round:" | tee -a $LOG
echo "=========" | tee -a $LOG

echo "[$(get_date)]:start to fetch AABS itself..." | tee -a $LOG
git fetch origin 2>&1 | tee -a $LOG
echo "[$(get_date)]:done" | tee -a $LOG

if [ $? -ne 0 ]; then
	exit 1
fi

echo "[$(get_date)]:start to checkout origin/master..." | tee -a $LOG
git checkout origin/master 2>&1 | tee -a $LOG
echo "[$(get_date)]:done" | tee -a $LOG

if [ $? -ne 0 ]; then
	exit 1
fi

dryrun_flag=false
for platform in $@; do
	if [ "$platform" == "dry-run" ]; then
		dryrun_flag=true
		break
	fi
done

for platform in $*; do
	if [ ! "$platform" == "dry-run" ]; then
		echo "[$(get_date)]:start to build:$platform" | tee -a $LOG
		if [ -x build-${platform}.sh ]; then
			if [ "$dryrun_flag" == true ]; then
				echo "will-run:./build-${platform}.sh clobber source pkgsrc publish email"
			else
				./build-${platform}.sh clobber source pkgsrc publish email
			fi
		else
			echo "!!!./build-${platform}.sh not exist or not excutable" | tee -a $LOG
		fi
		echo "[$(get_date)]:done." | tee -a $LOG
	fi
done

echo "Round completes." | tee -a $LOG
echo | tee -a $LOG

