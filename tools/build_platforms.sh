#!/bin/bash
#
#

get_date()
{
  echo $(date "+%Y-%m-%d %H:%M:%S")
}

print_usage()
{
	echo
	echo "Usage: $0 <platform>[:release-name] [no-checkout] [dry-run] [help]"
	echo "    The scrip will checkout the master branch to build the dev build and rls_<platform>_<release-name> branch to build the rls build."
	echo ""
	echo "    <platform>: should take the form like avlite-donut avlite-eclair etc. release-name can be like beta1, alpha2"
	echo "    [release-name]: only valid if there is no \$ABS_MANIFEST_BRANCH defined"
	echo "       1. if it is not specified, platform is used as the manifest branch name;"
	echo "       2. otherwise, rls_<platform>_<release-name> is used as the manifest branch name, the - in platform name is replaced with _"
	echo "    [no-checkout]: don't checkout aabs project for build. this should be used for testing this script."
    echo "    [dry-run]: don't actully run the build, this should be used for testing this script."
    echo "    [help]: show this message"
    echo "    For virtual build, you must export ABS_SOURCE_DIR and ABS_PUBLISH_DIR"
    echo "    To specify android variant, export PLATFORM_ANDROID_VARIANT=<user|userdebug|eng>"
    echo "    To force it to build, export ABS_FORCE_BUILD=true"
}

LOG=build_platforms.log

#enable pipefail so that if make fail the exit of whole command is non-zero value.
set -o pipefail

#For release build, the aabs will be branched, too. So we can only do one platform build a time.
#And for release build, we should checkout the rls_<board>_<droid>_<version> branch; for dev build, we should checkout the master 

all_flags=
platforms=
dryrun_flag=false
no_checkout=false
all_params=$*
for flag in $@; do
	case $flag in
		dry-run) dryrun_flag=true; all_flags="$all_flags $flag";;
		no-checkout) no_checkout=true;;
		help) print_usage; exit 2;;
		*)
		platforms="$platforms $flag";; 
	esac
done

count=$(echo "$platforms" | wc -w)
if [ $count -ne 1 ]; then
	echo "[aabs] required to build platforms: $platforms"
	echo "[aabs] but the script is changed to support only one platform build a time, due to aabs is branched for every release."
	exit 1
fi

platform=${platforms# }
platform=${platform% }
rlsname=
version=
aabs_branch=master
if [ ! ${platform%%:*} == "$platform" ]; then
	version=${platform##*:}
	platform=${platform%%:*}
	if [ ! -z "$version" ]; then
		rlsname=rls:$version
		aabs_branch=rls_${platform}_$version
		aabs_branch=${aabs_branch/-/_}			
	fi
fi

if [ "$no_checkout" = "false" ]; then
	echo "[aabs][$(get_date)]:start to fetch AABS itself..." | tee -a $LOG
	git fetch origin 2>&1 | tee -a $LOG
	if [ $? -ne 0 ]; then
		echo "[aabs]git fetch fail, check the git server." | tee -a $LOG
		exit 10
	fi
	echo "[aabs][$(get_date)]:done" | tee -a $LOG

	current_head=$(git rev-parse HEAD)
	if [ $? -ne 0 ]; then
		echo "[aabs]git rev-parse HEAD:returns error." | tee -a $LOG
		exit 20
	fi
	new_head=$(git rev-parse origin/$aabs_branch)
	if [ $? -ne 0 ]; then
		echo "[aabs]git rev-parse $aabs_branch:returns error, check if the branch is created" | tee -a $LOG
		exit 30
	fi

	if [ ! "$current_head" = "$new_head" ]; then
		echo "[aabs]==================" | tee -a $LOG
		echo "[aabs][$(get_date)]:start to checkout origin/$aabs_branch..." | tee -a $LOG
		echo "[aabs]==================" | tee -a $LOG
		git checkout origin/$aabs_branch 2>&1 | tee -a $LOG
		if [ $? -ne 0 ]; then
			echo "[aabs]git checkout branch:$aabs_branch failed, check if the branch is created." | tee -a $LOG
			exit 40
		fi
		echo "[aabs][$(get_date)]:done" | tee -a $LOG

		echo "[aabs][$(get_date)]:restart the build_platforms.sh as $0 $all_params" | tee -a $LOG
		echo | tee -a $LOG
		exec $0 $all_params
	else
		echo "[aabs][$(get_date)]:aabs is up to date to commit:$current_head" | tee -a $LOG
	fi
fi

echo "[aabs][$(get_date)]:start to build:$platform $rlsname" | tee -a $LOG
if [ -x build-${platform}.sh ]; then
    if [ -n "$ABS_SOURCE_DIR" -a -n "$ABS_PUBLISH_DIR" ]; then
        export ABS_VIRTUAL_BUILD=true
        TARGET_SOURCE=""
        TARGET_PKGSRC=""
        TARGET_EMAIL=""
    else
        export ABS_VIRTUAL_BUILD=""
        TARGET_SOURCE="source"
        TARGET_PKGSRC="pkgsrc"
        TARGET_EMAIL="email"
    fi
    if [ "$ABS_FORCE_BUILD" = "true" ]; then
        FORCE_BUILD="force"
    fi
	if [ "$dryrun_flag" == true ]; then
		echo "[aabs]will-run:./build-${platform}.sh clobber source pkgsrc publish autotest email $rlsname" | tee -a $LOG
	else
		if [ "$FLAG_TEMP_BUILD" = "true" ]; then
			./build-${platform}.sh clobber $TARGET_SOURCE $TARGET_PKGSRC publish temp $FORCE_BUILD $rlsname
		else
			./build-${platform}.sh clobber $TARGET_SOURCE $TARGET_PKGSRC publish autotest $TARGET_EMAIL $FORCE_BUILD $rlsname
		fi
	fi
else
	echo "[aabs]!!!./build-${platform}.sh not exist or not excutable" | tee -a $LOG
fi
echo "[aabs][$(get_date)]:build done." | tee -a $LOG

echo | tee -a $LOG

