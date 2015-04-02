#! /bin/bash
#
# This script must be executed in the folder where this script locats.
# It generates the final package from scratch.
#
# paramters:
#   clobber: force to have a completely clean build. All the source code, intermediate files are removed.
#   email: generate email notification after the build.

source ${soc}/build-${platform}.sh

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
	PUBLISH_DIR=$PUBLISH_DIR_BASE/${BUILD_NUM}_${ABS_PRODUCT_CODE}${RLS_SUFFIX}
	index=0
	while [ 1 ]; do
	  if [ ! -d $PUBLISH_DIR ]; then
	    break
	  fi
	  index=$(( index + 1 ))
	  BUILD_NUM=${DATE}_${index}
	  PUBLISH_DIR=$PUBLISH_DIR_BASE/${BUILD_NUM}_${ABS_PRODUCT_CODE}${RLS_SUFFIX}
	done
	mkdir -p $PUBLISH_DIR
}
#$1: changelog.build
generate_error_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team
	Subject: $BUILD_TAG [$ABS_PRODUCT_CODE${RLS_SUFFIX}] autobuild failed! please check

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
	Team of $ABS_PRODUCT_CODE
	EOF
}

#
# virtual build only
#
vb_generate_error_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $dev_team
	Subject: $BUILD_TAG [$ABS_PRODUCT_CODE${RLS_SUFFIX}] autobuild failed! please check

	This is an automated email from the autobuild script. It was
	generated because an error encountered while building the code.

	Ending part of build log is followed:
	=========================== Build LOG =====================

	$(tail -200 $STD_LOG 2>/dev/null)

	===========================================================

	Complete Time: $(date)
	Build Host: $(hostname)
	---
	Team of $ABS_PRODUCT_CODE
	EOF
}

generate_success_notification_email()
{
	# --- Email (all stdout will be the email)
	# Generate header
	cat <<-EOF
	From: $build_maintainer
	To: $announce_list;
	Subject: $BUILD_TAG [$ABS_PRODUCT_CODE${RLS_SUFFIX}] build $BUILD_NUM is ready.

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
	Team of $ABS_PRODUCT_CODE
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
	Subject: $BUILD_TAG [$ABS_PRODUCT_CODE${RLS_SUFFIX}] no build today.

	This is an automated email from the autobuild script. You received
	this email because you are the maintainer of $ABS_PRODUCT_CODE. The
	email was generated because the script detects no significant change in
	source code since last build, please check the details of the change log
	since last build:
	========================================================================

	$(cat ${1} )

	---
	Team of $ABS_PRODUCT_CODE
	EOF
}

#$1: the file path of changelog.build
send_error_notification()
{
	generate_error_notification_email $1 | /usr/sbin/sendmail -t $envelopesender
}

# virtual build only
vb_send_error_notification()
{
	vb_generate_error_notification_email | /usr/sbin/sendmail -t $envelopesender
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
	LOG_FILES="changelog.build changelog.day changelog.week changelog.biweek changelog.month"
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
	echo "Usage: $0 [clobber] [source] [pkgsrc] [publish] [email] [temp] [ccache] [force] [autotest] [help]"
	echo "  clobber: do a clean build. Before build starts, the source code and output directory is removed first."
	echo "  source: download the source code from GIT server."
	echo "  publish:if build success, copy the result to publish dir."
	echo "  email:once build is completed, either successfully or interrupted due to an error, generate an email notification."
	echo "  pkgsrc: package the source code into a tarball."
	echo "  temp: indicate a temporarily build, the build will be published to a temp folder:$TEMP_PUBLISH_DIR. If email is specified, only build_maintainer is notified."
	echo "  ccache: using ccache to speedup the build process."
	echo "  force: no matter if there is any change since last build, always rebuild."
	echo "  autotest: it's temporarily not supported."
	echo "  nobuild:don't build any targets."
	echo "  help: print this list."
}

if [ -z "$ABS_SOC" ] || [ -z "$ABS_DROID_BRANCH" ]; then
  echo "Any of the variable:ABS_SOC,ABS_DROID_BRANCH is not set."
  return 1
fi

if [ -z "$ABS_BUILDHOST_DEF" ] || [ ! -e core/$ABS_BUILDHOST_DEF ]; then
  ABS_BUILDHOST_DEF=buildhost.def
fi
. core/${ABS_BUILDHOST_DEF}

if [ -z "$ABS_CHILD_NAME" ]; then
  ABS_PRODUCT_CODE=${ABS_SOC}-${ABS_DROID_BRANCH}
else
  ABS_PRODUCT_CODE=${ABS_SOC}-${ABS_DROID_BRANCH}${ABS_CHILD_NAME}
  ABS_PARENT_PRODUCT_CODE=${ABS_SOC}-${ABS_DROID_BRANCH}
fi
export ABS_PRODUCT_CODE

MAKEFILE=core/main.mk

export PUBLISH_DIR="PUBLISH_DIR-Not-Defined"
BUILD_NUM="BUILD_NUM-Not-Defined"

build_maintainer=$(cat ${ABS_SOC}/maintainer)
dev_team=$(cat ${ABS_SOC}/dev_team )
announce_list=$(cat ${ABS_SOC}/announce_list )
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
FLAG_FORCE=false
FLAG_BUILD=true
FLAG_AUTOTEST=false
ABS_RELEASE_NAME=
RLS_SUFFIX=
FLAG_DISTRIBUTED_BUILD=false

for flag in $*; do
	case $flag in
		clobber) FLAG_CLOBBER=true;;
		email) FLAG_EMAIL=true;;
		publish)FLAG_PUBLISH=true;;
		pkgsrc)FLAG_PKGSRC=true;;
		source)FLAG_SOURCE=true;;
		temp)FLAG_TEMP=true;;
		ccache)FLAG_CCACHE=true;;
		force)FLAG_FORCE=true;;
		nobuild)FLAG_BUILD=false;;
		autotest)FLAG_AUTOTEST=true;;
		help) print_usage; exit 2;;
		*)
		if [ ! "${flag%%:*}" == "${flag}" ] && [ "${flag%%:*}" == "rls" ]; then
			ABS_RELEASE_NAME=${flag##*:}
			RLS_SUFFIX=_${ABS_RELEASE_NAME}
			export ABS_RELEASE_NAME
			if [ -n "$ABS_UNIQUE_MANIFEST_BRANCH" ] && [ -z "$ABS_DROID_MANIFEST" ]; then
				export ABS_DROID_MANIFEST="${ABS_RELEASE_NAME}.xml"
			fi
		else
			echo "Unknown flag: $flag";
			print_usage;
			exit 2
		fi;;
	esac
done

#enable pipefail so that if make fail the exit of whole command is non-zero value.
set -o pipefail

#support distributed building
if [ ! -z "${ABS_BUILD_MANIFEST}" ];then
	TEMP_MANIFEST_FILE=${ABS_BUILD_MANIFEST##*/}
	ABS_MANIFEST_FILE=${TEMP_MANIFEST_FILE}
fi

if [ ! -z "${ABS_DEVICE_LIST}" ];then
	FLAG_DISTRIBUTED_BUILD=true
	FLAG_FORCE=true
fi

export FLAG_DISTRIBUTED_BUILD
export ABS_MANIFEST_FILE
export ABS_BUILD_MANIFEST

if [ ! -z "$ABS_RELEASE_NAME" ]; then
    RELEASE_FULL_NAME=rls_$(echo $ABS_PRODUCT_CODE | sed 's/-/_/g')_${ABS_RELEASE_NAME}
fi

if [ -z "$ABS_MANIFEST_BRANCH" ]; then
    if [ ! -z "$ABS_RELEASE_NAME" ]; then
        ABS_MANIFEST_BRANCH=$RELEASE_FULL_NAME
        if [ ! -z "$ABS_CHILD_NAME" ]; then
            ABS_PARENT_BRANCH=rls_$(echo $ABS_PARENT_PRODUCT_CODE | sed 's/-/_/g')_${ABS_RELEASE_NAME}
        fi
    else
        ABS_MANIFEST_BRANCH=$ABS_PRODUCT_CODE
        if [ ! -z "$ABS_CHILD_NAME" ]; then
            ABS_PARENT_BRANCH=$ABS_PARENT_PRODUCT_CODE
        fi
    fi
fi
export ABS_MANIFEST_BRANCH
export ABS_PARENT_BRANCH

LAST_BUILD=LAST_BUILD.${ABS_MANIFEST_BRANCH}
STD_LOG="build-${ABS_PRODUCT_CODE}${RLS_SUFFIX}.log"
DISTRIBUTED_BUILD=DISTRIBUTED_BUILD.${ABS_MANIFEST_BRANCH}


#TEMP_PUBLISH_DIR_BASE and OFFICIAL_PUBLISH_DIR_BASE should be defined buildhost.def
if [ -z "${ABS_PUBLISH_DIR_BASE}" ]; then
	if [ "$ABS_VIRTUAL_BUILD" = "true" ]; then
	    PUBLISH_DIR_BASE=$ABS_PUBLISH_DIR
		PUBLISH_DIR_BASE=${PUBLISH_DIR_BASE}/${ABS_SOC}
	elif [ "$FLAG_TEMP" = "true" ]; then
		PUBLISH_DIR_BASE=$TEMP_PUBLISH_DIR_BASE
		dev_team=$build_maintainer
		announce_list=""
		PUBLISH_DIR_BASE=${PUBLISH_DIR_BASE}/${ABS_SOC}
	else
		PUBLISH_DIR_BASE=$OFFICIAL_PUBLISH_DIR_BASE
		PUBLISH_DIR_BASE=${PUBLISH_DIR_BASE}/${ABS_SOC}
	fi
else
	PUBLISH_DIR_BASE=${ABS_PUBLISH_DIR_BASE}
fi

if [ "$FLAG_DISTRIBUTED_BUILD" = "true" ]; then
	FORMAL_PUBLISH_DIR_BASE=$PUBLISH_DIR_BASE
	PUBLISH_DIR_BASE=$TEMP_PUBLISH_DIR_BASE
	mkdir -p ${PUBLISH_DIR_BASE}
else
	mkdir -p ${PUBLISH_DIR_BASE}
fi

LAST_BUILD=$PUBLISH_DIR_BASE/$LAST_BUILD
DISTRIBUTED_BUILD=$PUBLISH_DIR_BASE/$DISTRIBUTED_BUILD

if [ "$FLAG_TEMP" = "true" ]; then
	BUILD_TAG=[autobuild-temp]
else
	if [ ! -z "$ABS_RELEASE_NAME" ]; then
		BUILD_TAG=[autobuild-rls]
	fi
fi

echo "[$(date)]:starting build ${ABS_PRODUCT_CODE}${RLS_SUFFIX} ..." > $STD_LOG
echo "AABS publishing dir base: ${PUBLISH_DIR_BASE}" > $STD_LOG

export LAST_BUILD_LOC=$PUBLISH_DIR_BASE

if [ "$FLAG_CCACHE" = "true" ]; then
	export USE_CCACHE=true
	echo "ccache is enabled."
fi &&

if [ "$FLAG_CLOBBER" = "true" ]; then
	make -f ${MAKEFILE} clobber 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_SOURCE" = "true" ]; then
	make -f ${MAKEFILE} "source" 2>&1 | tee -a $STD_LOG
fi &&

#
# Check changes from last build
# 1. build for new changes
# 2. always build if enforced
# 3. always build for virtual build
#
if [ "$ABS_VIRTUAL_BUILD" = "true" ]; then
    echo "Virtual Build: we'll skip checking changes"
else
    make -f ${MAKEFILE} changelog 2>&1 | tee -a $STD_LOG
    change_since_last_build=$(make -f ${MAKEFILE} get_change_summary_since_last_build)
fi

if [ -z "$change_since_last_build" -a "$ABS_VIRTUAL_BUILD" != "true" ]; then
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
	get_new_publish_dir
	export PUBLISH_DIR
	ABS_HAVE_ANDROID_BUILD_VERSION=true
	export ABS_HAVE_ANDROID_BUILD_VERSION
	ABS_ANDROID_BUILD_VERSION=${BUILD_NUM}_${ABS_PRODUCT_CODE}${RLS_SUFFIX}
	export ABS_ANDROID_BUILD_VERSION
	echo "ABS_ANDROID_BUILD_VERSION: $ABS_ANDROID_BUILD_VERSION"  | tee -a $STD_LOG
	make -f ${MAKEFILE} build 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_PKGSRC" = "true" ]; then
	make -f ${MAKEFILE} pkgsrc 2>&1 | tee -a $STD_LOG
fi &&

if [ "$FLAG_PUBLISH" = "true" ]; then
    if [ "$ABS_VIRTUAL_BUILD" = "true" ]; then
        BACKUP_DIR_BASE=/git/android/manifest_bkup/virtual_build/${ABS_SOC}
    else
        BACKUP_DIR_BASE=/git/android/manifest_bkup/${ABS_SOC}
    fi
	BACKUP_DIR=${BACKUP_DIR_BASE}${PUBLISH_DIR#*${PUBLISH_DIR_BASE}}
	export BACKUP_DIR
	cp ${ABS_SOC}/README $PUBLISH_DIR/README 
	make -f ${MAKEFILE} publish -e 2>&1 | tee -a $STD_LOG &&
    # Don't forget patches of the virtual build
    if [ "$ABS_VIRTUAL_BUILD" = "true" ]; then
        pushd $ABS_SOURCE_DIR
        repo forall -c ${ABS_TOP_DIR}/core/odvb_patches.sh ${ABS_SOURCE_DIR}/odvb_patches
        zip -r patches.zip odvb_patches
        cp patches.zip $PUBLISH_DIR
        popd
    fi

	update_changelogs $PUBLISH_DIR $BUILD_NUM &&

	if [ "$FLAG_DISTRIBUTED_BUILD" = "false" ]; then
		#saving the build info to file:$LAST_BUILD
		echo "Project:$ABS_SOC" > $LAST_BUILD &&
		echo "Build-Num:$BUILD_NUM" >> $LAST_BUILD &&
		echo "Package:$PUBLISH_DIR" >> $LAST_BUILD
	fi

fi


if [ $? -ne 0 ]; then #auto build fail, send an email
	echo "error encountered!" 2>&1 | tee -a $STD_LOG
    echo "[AABS]-----------------FAILED-------------------"
    if [ "$FLAG_EMAIL" = "true" ]; then
        echo "[AABS]sending email notification..." 2>&1 | tee -a $STD_LOG
        if [ "$ABS_VIRTUAL_BUILD" = "true" ]; then
            vb_send_error_notification
        else
            send_error_notification "$(make -f ${MAKEFILE} get_changelog_build)"
        fi
    fi

    #support distributed building
    if [ "$FLAG_DISTRIBUTED_BUILD" = "true" ]; then
    	touch $PUBLISH_DIR/FAILURE
    else
    	if [ -e "$PUBLISH_DIR" ]; then
    		if [ ! `ls -A $PUBLISH_DIR` ]; then
    			rm -rf $PUBLISH_DIR
    		fi
    	fi
    fi

else

	echo "build successfully. Cheers!Package:$PUBLISH_DIR " 2>&1 | tee -a $STD_LOG
	echo "~~<result>PASS</result>"
	echo "~~<result-dir>http://$(get_publish_server_ip)${PUBLISH_DIR}</result-dir>"
	if [ "$FLAG_DISTRIBUTED_BUILD" = "false" ]; then
		if [ "$FLAG_EMAIL" = "true" ]; then
			echo "    sending email notification..." 2>&1 | tee -a $STD_LOG
			send_success_notification
		fi
		if [ "$FLAG_PUBLISH" = "true" ] && [ "$FLAG_TEMP" = "false" ] && [ "$FLAG_AUTOTEST" = "true" ]; then
			echo "Sorry, autotest isn't supported temporarily."
		fi
	fi

	#support distributed building
	if [ "$FLAG_DISTRIBUTED_BUILD" = "true" ]; then
    	touch $PUBLISH_DIR/SUCCESS
  fi
fi

#support distributed building
if [ "$FLAG_DISTRIBUTED_BUILD" = "true" ]; then
	echo "XXXXXX----> save $PUBLISH_DIR to $DISTRIBUTED_BUILD"
	if [ ! -e "$DISTRIBUTED_BUILD" ]; then
		echo "$PUBLISH_DIR" > $DISTRIBUTED_BUILD
	else
		echo "$PUBLISH_DIR" >> $DISTRIBUTED_BUILD
	fi


	#support distributed building
	#merge distributed publish directories
	index=0
	device_list=$ABS_DEVICE_LIST
	if [ -n "$device_list" ]; then
		index=1
		while [ 1 ]; do
	  	if [ ! `echo $device_list | grep -e ','` ]; then
		  	break
			fi
			index=$(( index + 1 ))
			device_list=${device_list#*,}
	done
	fi

	publish_index=0
	publish_index=`cat $DISTRIBUTED_BUILD | wc -l`
	echo "XXXXXX----> index=${index}, publish_index=${publish_index}"

	build_failure=false
	if [ $index -eq $publish_index ]; then
		echo "XXXXXX----> all builds completed now, do release stuff..."
		for i in `cat $DISTRIBUTED_BUILD`;do
			if [ -e "${i}/FAILURE" ]; then
				build_failure=true
				break
			fi
		done

		if [ "$build_failure" = "true" ]; then
			for i in `cat  $DISTRIBUTED_BUILD`;do
				rm -rf $i
			done
		else
			#FORMAL_PUBLISH_DIR_BASE=$PUBLISH_DIR_BASE
			PUBLISH_DIR_BASE=$FORMAL_PUBLISH_DIR_BASE
			get_new_publish_dir
		  export PUBLISH_DIR
			pub=$PUBLISH_DIR
			for i in `cat  $DISTRIBUTED_BUILD`;do
				if [ "$i" = "$pub" ];then
					continue
				else
					#cp -rf ${i}/* $pub
					#if [ $? -eq 0 ];then
					#	rm -rf $i
					#fi
					mv -f ${i}/* $pub
					rm -rf $i
				fi
			done

			#send out final success notification mail
			rm -f ${pub}/SUCCESS
			echo "XXXXXX----> pub=${pub}"
			echo "XXXXXX----> PUBLISH_DIR=${PUBLISH_DIR}"
			PUBLISH_DIR=${pub}
			export PUBLISH_DIR
			echo "all builds successfully done. Cheers!Package:${PUBLISH_DIR} " 2>&1 | tee -a $STD_LOG
			echo "~~<result>PASS</result>"
			echo "~~<result-dir>http://$(get_publish_server_ip)${PUBLISH_DIR}</result-dir>"
			if [ "$FLAG_EMAIL" = "true" ]; then
				echo "    sending email notification..." 2>&1 | tee -a $STD_LOG
				send_success_notification
			fi
			if [ "$FLAG_PUBLISH" = "true" ] && [ "$FLAG_TEMP" = "false" ] && [ "$FLAG_AUTOTEST" = "true" ]; then
				echo "Sorry, autotest isn't supported temporarily."
			fi

			#saving the build info to file:$LAST_BUILD
			TEMP_NUM=$PUBLISH_DIR
			TEMP_NUM=${TEMP_NUM##*/}
			TEMP_NUM=${TEMP_NUM%_pxa*}
			BUILD_NUM=${TEMP_NUM}
			LAST_BUILD=${PUBLISH_DIR_BASE}/LAST_BUILD.${ABS_MANIFEST_BRANCH}
			echo "Project:$ABS_SOC" > $LAST_BUILD &&
			echo "Build-Num:$BUILD_NUM" >> $LAST_BUILD &&
			echo "Package:$PUBLISH_DIR" >> $LAST_BUILD

		fi
		cat $DISTRIBUTED_BUILD
		rm -f $DISTRIBUTED_BUILD
	fi
fi

echo "[AABS]-------------------END-------------------"

