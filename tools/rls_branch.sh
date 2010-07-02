#!/bin/bash
#This script is used to create or delete release branch. It should be excuted in the root directory of android source code.
#When you delete a release branch, make sure you do want to delete the release branch.
#Before you run this script, make sure you have do the following configuration on your dev machine:
# your .ssh/id_dsa file has been added to androidadm,oseadm and pieadm
#
#$1: create or delete
#$2: release branch name
#$3: actual-run

function print_usage()
{
	echo "    Usage: rls_branch.sh <create|delete> <release-branch-name> <actual-run>"
	echo "    action: create or delete the release branch"
	echo "    release-branch-name: it should take the below format:"
	echo "        rls_<board>_<android version>_<ver> "
	echo "    e.g: rls_ttcdkb_eclair_alpha1"
	echo "    actual-run: by default it just dry-runs, so everything is doen except updating the branch on server. By specifying actual-run, the server is updated"
}

function get_account_to_use()
{
	if [ "$1" == "shgit" ]; then
		echo "releaseadm"
		return
	fi

	if [ "$1" == "osegit" ]; then
		echo "releaseadm"
		return
	fi

	if [ "$1" == "piegit" ]; then
		echo "releaseadm"
		return
	fi

	if [ "$1" == "ptkgit" ]; then
		echo "releaseadm"
		return
	fi

	if [ "$1" == "origin" ]; then
		echo "releaseadm"
		return
	fi
	return
}

if [ -z "$1" ] || [ -z "$2" ]; then
	print_usage
	exit 1
fi

if [ "$1" == "create" ] || [ "$1" == "delete" ]; then
	action=$1
else
	echo "The first argument is inavlid:$1."
	print_usage
	exit 1
fi

dryrun_flag=--dry-run
if [ ! -z "$3" ]; then
	if [ "$3" == "actual-run" ]; then
		dryrun_flag=
	else
		echo "Invalid argument: $3."
		print_usage
		exit 1
	fi
fi

CWD=$(pwd)
rls_branch=$2
projects=$(repo forall -c "echo \$(pwd):\$REPO_REMOTE" | sort)

if [ -z "$projects" ]; then
	echo "You should run this script in the root directory of android source code."
	exit 2
fi

if [ ! -z "$dryrun_flag" ]; then
	echo
	echo "    !!! DRY_RUN !!!"
	echo "    Specify actual-run in command line to really update the server."
	echo 
else
	echo
	echo "    !!! Actual RUN !!!"
	echo
fi

#hack for specifying user name in ssh
mkdir -p $HOME/bin
cat >$HOME/bin/git-ssh <<-EOF
	#!/bin/sh
	ssh -l \$GIT_SSH_USER "\$@"
EOF
chmod a+x $HOME/bin/git-ssh

for prj in $projects; do
	prj_path=${prj%%:*}
	rmt=${prj##*:}
	cd $prj_path
	echo "Handling project:$prj_path" 
	if [ -z "$rmt" ]; then
		echo "git remote returns nothing"
		exit -1
	fi
	account=$(get_account_to_use $rmt)
	if [ -z "$account" ]; then
		echo "unreconized remote:$rmt"
		exit -1
	fi
	if [ "$action" == "create" ]; then
		head=HEAD
	else
		head=
	fi

	GIT_SSH=$HOME/bin/git-ssh GIT_SSH_USER=$account git push $dryrun_flag $rmt $head:refs/heads/$rls_branch

	if [ $? -ne 0 ]; then
		echo "git push error."
		exit -1
	fi
	echo 
done

echo "Update manifest branch..."
manifest_prj="${CWD}/.repo/manifests"
if [ "$action" == "create" ]; then
	cd ${manifest_prj}
	if [ -z "$dryrun_flag" ]; then
		sed -i "/revision=\"[^[:blank:]]*\"/s/revision=\"[^[:blank:]]*\"/revision=\"${rls_branch}\"/"  ./default.xml  &&
		git add ./default.xml &&
		git commit -s -m "${rls_branch}:enter release cycle"
	fi
	rmt=origin
	account=$(get_account_to_use $rmt)
	GIT_SSH=$HOME/bin/git-ssh GIT_SSH_USER=$account git push $dryrun_flag $rmt $head:refs/heads/$rls_branch

	if [ $? -ne 0 ]; then
		if [ -z "$dryrun_flag" ]; then
			echo "pushing manifest branch failed, please do it manually, branch name ${rls_branch}."
		else
			echo "pushing manifest branch failed"
		fi
		exit -1
	fi
else
	cd ${manifest_prj} 
	rmt=origin
	account=$(get_account_to_use $rmt)
	GIT_SSH=$HOME/bin/git-ssh GIT_SSH_USER=$account git push $dryrun_flag $rmt :refs/heads/$rls_branch

	if [ $? -ne 0 ]; then
		if [ -z "$dryrun_flag" ]; then
			echo "deleting manifest branch failed, please do it manually, branch name ${rls_branch}."
		else
			echo "deleting manifest branch failed"
		fi
		exit -1
	fi
fi

echo "Success!"


