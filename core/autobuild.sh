#! /bin/bash
#
# This script must be executed in the folder where this script locats.
# It generates the final package from scratch. 
#
# paramters: 
#   clobber: force to have a completely clean build. All the source code, intermediate files are removed.
#   email: generate email notification after the build.

get_ip()
{
OS=`uname`
IO="" # store IP
case $OS in
   Linux) IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;;
   FreeBSD|OpenBSD) IP=`ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'` ;;
   SunOS) IP=`ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2} '` ;;
   *) IP="Unknown";;
esac
echo "$IP"
}

get_publish_server_ip()
{
	if [ -z "$PUBLISH_SERVER_IP_FILE" ]; then
		echo $(get_ip)
	else
		if [ -r $PUBLISH_SERVER_IP_FILE ]; then
			cat $PUBLISH_SERVER_IP_FILE
		else
			echo $(get_ip)
		fi
	fi
}

get_new_publish_dir()
{
	DATE=$(date +%Y-%m-%d)
	BUILD_NUM=${DATE}
	PUBLISH_DIR=$PUBLISH_DIR_BASE/${BUILD_NUM}_${PRODUCT_CODE}${RLS_SUFFIX}
	index=0
	while [ 1 ]; do
	  if [ ! -d $PUBLISH_DIR ]; then
	    break
	  else
	    if [ -z "$(ls $PUBLISH_DIR)" ]; then
	      break
	    fi
	  fi
	  index=$(( index + 1 ))
	  BUILD_NUM=${DATE}_${index}
	  PUBLISH_DIR=$PUBLISH_DIR_BASE/${BUILD_NUM}_${PRODUCT_CODE}${RLS_SUFFIX}
	done
}
#$1: changelog.build
generate_error_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team
	Subject: $BUILD_TAG [$PRODUCT_CODE${RLS_SUFFIX}] autobuild failed! please check

	This is an automated email from the autobuild script. It was
	generated because an error encountered while building the code.
	The error can be resulted from newly checked in codes. 
	Please check the change log (if it is generated successfully) 
    and build log below and fix the error as early as possible.

	=========================== Change LOG ====================

	$(cat ${1}  2>/dev/null)
	
	===========================================================

	Last part of build log is followed:
	=========================== Build LOG =====================

	$(tail -200 $STD_LOG 2>/dev/null)
	
	===========================================================

	Complete Time: $(date)
	Build Host: $(hostname)
	---
	Team of $PRODUCT_CODE
	EOF
}

#$1: changelog.build
generate_error_log_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $build_maintainer
	Subject: $BUILD_TAG [$PRODUCT_CODE${RLS_SUFFIX}] autobuild failed! Full log is attached.

	This is an automated email from the autobuild script. It was
	generated because an error encountered while building the code.
	The error can be resulted from newly checked in codes. 
	Please check the change log (if it is generated successfully) 
    and build log below and fix the error as early as possible.

	=========================== Change LOG ====================

	$(cat ${1}  2>/dev/null)
	
	===========================================================

	
	=========================== Build LOG =====================

	$(cat $STD_LOG 2>/dev/null)
	
	===========================================================

	Complete Time: $(date)
	Build Host: $(hostname)
	---
	Team of $PRODUCT_CODE
	EOF
}

generate_success_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team;
	Subject: $BUILD_TAG [$PRODUCT_CODE${RLS_SUFFIX}] build $BUILD_NUM is ready.

	This is an automated email from the autobuild script. It was
	generated because a new package is generated successfully and
	the package is changed since last day.

	You can get the package from:
		\\\\$(get_publish_server_ip)${PUBLISH_DIR//\//\\}
	or
		http://$(get_publish_server_ip)${PUBLISH_DIR}
	or
		mount -t nfs $(get_publish_server_ip):${PUBLISH_DIR} /mnt

	The change log since last build is:

	$(cat ${PUBLISH_DIR}/changelog.build)

	---
	Team of $PRODUCT_CODE
	EOF
}

#$1: the changelog.build file
generate_nobuild_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team;
	Subject: $BUILD_TAG [$PRODUCT_CODE${RLS_SUFFIX}] no build today.

	This is an automated email from the autobuild script. You received
	this email because you are the maintainer of $PRODUCT_CODE. The
	email was generated because the script detects no significant change in
	source code since last build, please check the details of the change log
	since last build:
	========================================================================

	$(cat ${1} )

	---
	Team of $PRODUCT_CODE
	EOF
}

#$1: the file path of changelog.build
send_error_notification()
{
	generate_error_notification_email $1 | /usr/sbin/sendmail -t $envelopesender
	generate_error_log_email $1 | /usr/sbin/sendmail -t $envelopesender
}

send_success_notification()
{
	generate_success_notification_email | /usr/sbin/sendmail -t $envelopesender
}

#$1: the file path of changelog.build
send_nobuild_notification()
{
	generate_nobuild_notification_email $1 | /usr/sbin/sendmail -t $envelopesender
}

#$1: the folder where change logs locate
#$2: build number
update_changelogs()
{
	LOG_FILES="changelog.build changelog.rel changelog.day changelog.week changelog.biweek changelog.month"
	for log in $LOG_FILES; do
		log_file=$1/$log
		if [ -e "$log_file" ]; then
			echo >> $log_file
			echo "=============================================================================" >>$log_file
			echo "Build: $2" >> $log_file
			echo "Complete Time: $(date)" >> $log_file
			echo "Build Host: $(hostname)" >> $log_file
		fi
	done
}

print_usage()
{
	echo "Usage: $0 [clobber] [source] [pkgsrc] [publish] [email] [temp] [ccache] [mgcc] [force] [autotest] [help]"
	echo "  clobber: do a clean build. Before build starts, the source code and output directory is removed first."
	echo "  source: download the source code from GIT server."
	echo "  publish:if build success, copy the result to publish dir."
	echo "  email:once build is completed, either successfully or interrupted due to an error, generate an email notification."
	echo "  pkgsrc: package the source code into a tarball."
	echo "  temp: indicate a temporarily build, the build will be published to a temp folder:$TEMP_PUBLISH_DIR. If email is specified, only build_maintainer is notified."
	echo "  ccache: using ccache to speedup the build process."
	echo "  mgcc: enable to build targets with Marvell GCC."
	echo "  force: no matter if there is any change since last build, always rebuild."
	echo "  autotest: use submitBuildInfo.pl to inform QA a build is ready."
	echo "  nobuild:don't build any targets."
	echo "  help: print this list."
}

source buildhost.def

if [ -z "$ABS_BOARD" ] || [ -z "$ABS_DROID_BRANCH" ] || [ -z "$ABS_PRODUCT_NAME" ]; then
  echo "Any of the variable:ABS_BOARD,ABS_DROID_BRANCH,ABS_PRODUCT_NAME is not set."
  return 1
fi

PRODUCT_CODE=${ABS_BOARD}-${ABS_DROID_BRANCH}
MAKEFILE=${PRODUCT_CODE}.mk
PRODUCT_NAME="$ABS_PRODUCT_NAME"

PUBLISH_DIR="PUBLISH_DIR-Not-Defined"
BUILD_NUM="BUILD_NUM-Not-Defined"

build_maintainer=$(cat ${ABS_BOARD}/maintainer)
dev_team=$(cat ${ABS_BOARD}/dev_team )
announce_list=$(cat ${ABS_BOARD}/announce_list )
envelopesend="-f $build_maintainer"

#remove the new line character
dev_team=$(echo $dev_team)
announce_list=$(echo $announce_list)

#the value of this variable will be prefixed as the email subject
BUILD_TAG=[autobuild-dev]

FLAG_CLOBBER=false
FLAG_PUBLISH=false
FLAG_EMAIL=false
FLAG_PKGSRC=false
FLAG_SOURCE=false
FLAG_TEMP=false
FLAG_CCACHE=false
FLAG_MGCC=false
FLAG_FORCE=false
FLAG_BUILD=true
FLAG_AUTOTEST=false
RELEASE_NAME=
RLS_SUFFIX=

for flag in $*; do
	case $flag in
		clobber) FLAG_CLOBBER=true;;
		email) FLAG_EMAIL=true;;
		publish)FLAG_PUBLISH=true;;
		pkgsrc)FLAG_PKGSRC=true;;
		source)FLAG_SOURCE=true;;
		temp)FLAG_TEMP=true;;
		ccache)FLAG_CCACHE=true;;
		mgcc)FLAG_MGCC=true;;
		force)FLAG_FORCE=true;;
		nobuild)FLAG_BUILD=false;;
		autotest)FLAG_AUTOTEST=true;;
		help) print_usage; exit 2;;
		*) 
		if [ ! "${flag%%:*}" == "${flag}" ] && [ "${flag%%:*}" == "rls" ]; then
			RELEASE_NAME=${flag##*:}
			RLS_SUFFIX=_${RELEASE_NAME}
			export RELEASE_NAME
		else
			echo "Unknown flag: $flag"; 
			print_usage; 
			exit 2
		fi;;
	esac
done

#enable pipefail so that if make fail the exit of whole command is non-zero value.
set -o pipefail

#manifest branch name is same as product name if it is not release
MANIFEST_BRANCH=${PRODUCT_CODE}
if [ ! -z "$RELEASE_NAME" ]; then
	MANIFEST_BRANCH=rls_${MANIFEST_BRANCH/-/_}_${RELEASE_NAME}
fi
LAST_BUILD=LAST_BUILD.${MANIFEST_BRANCH}
STD_LOG="build-${PRODUCT_CODE}${RLS_SUFFIX}.log"

#TEMP_PUBLISH_DIR_BASE and OFFICIAL_PUBLISH_DIR_BASE should be defined buildhost.def
if [ "$FLAG_TEMP" = "true" ]; then
	PUBLISH_DIR_BASE=$TEMP_PUBLISH_DIR_BASE
	dev_team=$build_maintainer
	announce_list=""
	PUBLISH_DIR_BASE=${PUBLISH_DIR_BASE}/${ABS_BOARD}
	mkdir -p ${PUBLISH_DIR_BASE}
else
	PUBLISH_DIR_BASE=$OFFICIAL_PUBLISH_DIR_BASE
	PUBLISH_DIR_BASE=${PUBLISH_DIR_BASE}/${ABS_BOARD}
	mkdir -p ${PUBLISH_DIR_BASE}
fi
LAST_BUILD=$PUBLISH_DIR_BASE/$LAST_BUILD

if [ "$FLAG_TEMP" = "true" ]; then
	BUILD_TAG=[autobuild-temp]
else
	if [ ! -z "$RELEASE_NAME" ]; then
		BUILD_TAG=[autobuild-rls]
	fi
fi

echo "[$(date)]:starting build ${PRODUCT_CODE}${RLS_SUFFIX} ..." > $STD_LOG

if [ "$FLAG_CCACHE" = "true" ]; then
	export USE_CCACHE=true
	echo "ccache is enabled."
fi &&

export BUILD_VARIANTS=droid-gcc
if [ "$FLAG_MGCC" = "true" ]; then
	BUILD_VARIANTS="$BUILD_VARIANTS mrvl-gcc"
fi &&

if [ "$FLAG_CLOBBER" = "true" ]; then 
	make -f ${MAKEFILE} clobber 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_SOURCE" = "true" ]; then
	make -f ${MAKEFILE} "source" 2>&1 | tee -a $STD_LOG
fi &&

LAST_BUILD_LOC=$PUBLISH_DIR_BASE make -f ${MAKEFILE} changelog 2>&1 | tee -a $STD_LOG &&

change_since_last_build=$(make -f ${MAKEFILE} get_change_summary_since_last_build) &&

if [ -z "$change_since_last_build" ]; then
	echo "No significant change is identified since last build." | tee -a $STD_LOG 
	if [ "$FLAG_FORCE" = "true" ]; then
		echo "force flag is set, continue build."
	else
		echo "~~<result>PASS</result>"
		echo "~~<result-details>No build</result-details>"
		if [ "$FLAG_EMAIL" = "true" ]; then
			echo "    sending nobuild email notification..." 2>&1 | tee -a $STD_LOG
			send_nobuild_notification "$(make -f ${MAKEFILE} get_changelog_build)"
		fi
		exit 0
	fi
fi &&

if [ "$FLAG_BUILD" = "true" ]; then
	make -f ${MAKEFILE} build_droid-gcc 2>&1 | tee -a $STD_LOG 
fi &&

if [ "$FLAG_MGCC" = "true" ]; then
	make -f ${MAKEFILE} clean 2>&1 | tee -a $STD_LOG &&
	#build with marvell gcc
	echo "[$(date)]:starting to build targets with marvell toolchain ..." | tee -a $STD_LOG &&
	#TODO: to specify the path of marvell toolchain
	export EXTERNAL_TOOLCHAIN_PREFIX=
	make -f ${MAKEFILE} build_mrvl-gcc 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_PKGSRC" = "true" ]; then
	make -f ${MAKEFILE} pkgsrc 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_PUBLISH" = "true" ]; then
	get_new_publish_dir
	export PUBLISH_DIR
	make -f ${MAKEFILE} publish -e 2>&1 | tee -a $STD_LOG &&
	cp ${ABS_BOARD}/README $PUBLISH_DIR &&
	
	update_changelogs $PUBLISH_DIR $BUILD_NUM &&
		
	#saving the build info to file:$LAST_BUILD
	echo "Project:$PRODUCT_NAME" > $LAST_BUILD &&
	echo "Build-Num:$BUILD_NUM" >> $LAST_BUILD &&
	echo "Package:$PUBLISH_DIR" >> $LAST_BUILD 
fi &&

if [ "$FLAG_PUBLISH" = "true" ] && [ "$FLAG_TEMP" = "false" ] && [ "$FLAG_AUTOTEST" = "true" ]; then
	perl tools/submitBuildInfo.pl -link \\\\$(get_publish_server_ip)${PUBLISH_DIR//\//\\} 2>&1 | tee -a $STD_LOG
fi

if [ $? -ne 0 ]; then #auto build fail, send an email
	echo "error encountered!" 2>&1 | tee -a $STD_LOG
	echo "~~<result>FAIL</result>"
	if [ "$FLAG_EMAIL" = "true" ]; then
		echo "    sending email notification..." 2>&1 | tee -a $STD_LOG
		send_error_notification "$(make -f ${MAKEFILE} get_changelog_build)"
	fi
else
	echo "build successfully. Cheers!Package:$PUBLISH_DIR " 2>&1 | tee -a $STD_LOG
	echo "~~<result>PASS</result>"
	echo "~~<result-dir>http://$(get_publish_server_ip)${PUBLISH_DIR}</result-dir>"
	if [ "$FLAG_EMAIL" = "true" ]; then
		echo "    sending email notification..." 2>&1 | tee -a $STD_LOG
		send_success_notification
	fi
fi




