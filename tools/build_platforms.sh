#!/bin/bash
#
#

function get_date()
{
  echo $(date "+%Y-%m-%d %H:%M:%S")
}

function print_usage()
{
	echo
	echo "Usage: $0 <platform>[:release-name] [no-checkout] [dry-run] [help]"
	echo "    platform: should take the form like avlite-donut avlite-eclair etc. release-name can be like beta1, alpha2"
	echo "       if release-name is not specified, platform is used as the manifest branch name"
	echo "       if release-name is specified, rls_<platform>_<release-name> is used as the manifest branch name, the - in platform name is replaced with _"
	echo "    no-checkout: don't checkout aabs project for build. this should be used for testing."
    echo "    dry-run: don't actully run the build, this should be used for testing."
    echo "    help: show this message"
}

LOG=build_platforms.log

platforms=
dryrun_flag=false
no_checkout=false
for flag in $@; do
	case $flag in
		dry-run) dryrun_flag=true;;
		no-checkout) no_checkout=true;;
		help) print_usage; exit 2;;
		*)
		platforms="$platforms $flag";; 
	esac
done

echo | tee -a $LOG
echo "=========" | tee -a $LOG
echo "New round:" | tee -a $LOG
echo "=========" | tee -a $LOG

if [ "$no_checkout" = "false" ]; then
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
	echo "[$(get_date)]:restart the build_platforms.sh as $0 $@ no-checkout" | tee -a $LOG
	exec $0 $@ no-checkout
fi

for platform in $platforms; do
	rlsname=
	if [ ! ${platform%%:*} == "$platform" ]; then
		rlsname=${platform##*:}
		platform=${platform%%:*}
		if [ ! -z "$rlsname" ]; then
			rlsname=rls:$rlsname
		fi
	fi

	echo "[$(get_date)]:start to build:$platform $rlsname" | tee -a $LOG
	if [ -x build-${platform}.sh ]; then
		if [ "$dryrun_flag" == true ]; then
			echo "will-run:./build-${platform}.sh clobber source pkgsrc publish email $rlsname" | tee -a $LOG
		else
			./build-${platform}.sh clobber source pkgsrc publish email $rlsname
		fi
	else
		echo "!!!./build-${platform}.sh not exist or not excutable" | tee -a $LOG
	fi
	echo "[$(get_date)]:done." | tee -a $LOG
done

echo "Round completes." | tee -a $LOG
echo | tee -a $LOG

