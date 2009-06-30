#! /bin/bash
#
# This script must be executed in the folder where this script locats.
# It generates the final package from scratch. 
#
# paramters: 
#   clean: force to have a completely clean build. All the source code, intermediate files are removed.
#   email: generate email notification after the build.

function get_ip()
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

function get_new_publish_dir()
{
	DATE=$(date +%Y-%m-%d)
	PUBLISH_DIR=$PUBLISH_DIR_BASE/${DATE}_avlite
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
	  PUBLISH_DIR=$PUBLISH_DIR_BASE/${DATE}_${index}_avlite
	done
}

generate_error_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team
	Subject: [$project_name] autobuild failed! please check

	This is an automated email from the autobuild script. It was
	generated because an error encountered while building the code.
	The error can be resulted from newly updated source codes. 
	Please check the change log (if it is generated successfully) 
    and build log below and fix the error as early as possible.

	=========================== Change LOG ====================

	$(cat out/changelog.day 2>/dev/null)
	
	===========================================================

	=========================== Build LOG =====================

	$(cat $STD_LOG 2>/dev/null)
	
	===========================================================
	
	---
	$project_name	
	EOF
}

generate_success_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team;$announce_list
	Subject: [$project_name] new release package is available.

	This is an automated email from the autobuild script. It was
	generated because a new package is generated successfully and
	the package is changed since last day.

	You can get the package from:
		\\\\$(get_ip)${PUBLISH_DIR//\//\\}
	or
		http://$(get_ip)${PUBLISH_DIR}
	or
		mount -t nfs $(get_ip):${PUBLISH_DIR} /mnt

	The change log since last day is:

	$(cat ${PUBLISH_DIR}/changelog.day)

	---
	$project_name	
	EOF
}

generate_build_complete_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $build_maintainer
	Subject: [$project_name] a new build is completed.

	This is an automated email from the autobuild script. It was
	generated because the autobuild is completed successfully and
	no change is found since last day.

	You can get the package from:
		\\\\$(get_ip)${PUBLISH_DIR//\//\\}
	or
		http://$(get_ip)${PUBLISH_DIR}
	or
		mount -t nfs $(get_ip):${PUBLISH_DIR} /mnt

	---
	$project_name	
	EOF
}

send_error_notification()
{
	generate_error_notification_email | /usr/sbin/sendmail -t $envelopesender
}

send_success_notification()
{
	if [ -s "${PUBLISH_DIR}/changelog.day" ]; then
		echo "    changes found since last day, notify all..."
		generate_success_notification_email | /usr/sbin/sendmail -t $envelopesender
	else
		echo "    no change since last day, notify maintainer..."
		generate_build_complete_email | /usr/sbin/sendmail -t $envelopesender
	fi

}

function print_usage()
{
	echo "Usage: $0 [clean] [source] [pkgsrc] [publish] [email] [temp] [ccache] [help]"
	echo "  clean: do a clean build. Before build starts, the source code and output directory is removed first."
	echo "  source: download the source code from GIT server."
	echo "  publish:if build success, copy the result to publish dir."
	echo "  email:once build is completed, either successfully or interrupted due to an error, generate an email notification."
	echo "  pkgsrc: package the source code into a tarball."
	echo "  temp: indicate a temporarily build, the build will be published to a temp folder:$TEMP_PUBLISH_DIR."
	echo "  ccache: using ccache to speedup the build process."
	echo "  help: print this list."
}

STD_LOG=autobuild.log

build_maintainer=$(cat maintainer)
dev_team=$(cat dev_team )
announce_list=$(cat announce_list )
project_name="Android for AVLite"
envelopesend="-f $build_maintainer"

PUBLISH_DIR="Not Published"
OFFICIAL_PUBLISH_DIR=/autobuild/android
TEMP_PUBLISH_DIR=/autobuild/temp
PUBLISH_DIR_BASE=$OFFICIAL_PUBLISH_DIR

FLAG_CLEAN=false
FLAG_PUBLISH=false
FLAG_EMAIL=false
FLAG_PKGSRC=false
FLAG_SOURCE=false
FLAG_TEMP=false
FLAG_CCACHE=false
for flag in $*; do
	case $flag in
		clean) FLAG_CLEAN=true;;
		email) FLAG_EMAIL=true;;
		publish)FLAG_PUBLISH=true;;
		pkgsrc)FLAG_PKGSRC=true;;
		source)FLAG_SOURCE=true;;
		temp)FLAG_TEMP=true;;
		ccache)FLAG_CCACHE=true;;
		help) print_usage; exit 2;;
		*) echo "Unknown flag: $flag"; print_usage; exit 2;;
	esac
done

if [ "$FLAG_TEMP" = "true" ]; then
	PUBLISH_DIR_BASE=$TEMP_PUBLISH_DIR
fi

#enable pipefail so that if make fail the exit of whole command is non-zero value.
set -o pipefail

echo "Starting autobuild @$(date)..." > $STD_LOG

if [ "$FLAG_CCACHE" = "true" ]; then
	export USE_CCACHE=true
	echo "ccache is enabled."
fi

if [ "$FLAG_CLEAN" = "true" ]; then 
	make clean 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_SOURCE" = "true" ]; then
	make "source" 2>&1 | tee -a $STD_LOG
fi &&

make all 2>&1 | tee -a $STD_LOG &&

if [ "$FLAG_PKGSRC" = "true" ]; then
	make pkgsrc 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_PUBLISH" = "true" ]; then
	get_new_publish_dir
	export PUBLISH_DIR
	make publish -e 2>&1 | tee -a $STD_LOG &&
	cp README.avlite $PUBLISH_DIR 
fi

if [ $? -ne 0 ]; then #auto build fail, send an email
	echo "error encountered!" 
	if [ "$FLAG_EMAIL" = "true" ]; then
		echo "    sending email notification..."
		send_error_notification
	fi
else
	echo "build successfully. Cheers! "
	if [ "$FLAG_EMAIL" = "true" ]; then
		echo "    sending email notification..." 
		send_success_notification
	fi
fi




