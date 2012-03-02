#!/bin/sh
#This script is used to create or delete release branch. It should be excuted in the root directory of android source code.
#When you delete a release branch, make sure you do want to delete the release branch.
#Before you run this script, make sure you have do the following configuration on your dev machine:
# your .ssh/id_dsa file has been added to androidadm,oseadm and pieadm
#
#$1: create or delete
#$2: release branch name
#$3: mode of manifest.git (UNIQUE branch or multiple branches)
#$4: actual-run
#$5: project list ...

print_usage() {
	echo "    Usage: rls_branch.sh <create|delete> <release-branch-name> <unique|multiple> [<actual-run>] [<project> ...]"
	echo "    action: create or delete the release branch"
	echo "    release-branch-name: it should take the below format:"
	echo "        rls_<board>_<android version>_<ver> "
	echo "    e.g: rls_ttcdkb_eclair_alpha1"
	echo "    mode: the mode of manifest.git:"
	echo "         unique: there is one branch, and each branch of repo has an individual manifest file."
	echo "         multiple: each branch of repo takes one branch of manifest, but all of them use the same name of manifest file that default.xml"
	echo "    actual-run: by default it just dry-runs, so everything is doen except updating the branch on server. By specifying actual-run, the server is updated"
	echo "    projectX: only the given projects are impacted"
}

get_account_to_use() {
	echo "releaseadm"
}

branch_to_remote() {
	local branches="$(git branch -r)"
	local target_found=0
	local br

	for br in $branches
	do
		br=$(echo $br | awk -F/ '{ print $2 }')
		if [ "$br" = "$rls_branch" ]; then
			target_found=1
			break
		fi
	done
	if [ "$1" = "create" ]; then
		head=HEAD
	elif [ "$1" = "delete" ] && [ $target_found -ne 0 ]; then
		head=
	else
		return 0
	fi

	GIT_SSH=$HOME/bin/git-ssh GIT_SSH_USER=$account git push $dryrun_flag $rmt $head:refs/heads/$rls_branch
	return $?
}

if [ $# -lt 3 ] || [ "$1" != "create" -a "$1" != "delete" ] || [ "$3" != 'unique' -a "$3" != 'multiple' ]; then
	print_usage
	exit 1
fi

action=$1
unique=$3

projects=$(repo forall -c 'echo $(pwd):$REPO_REMOTE' | sort)
if [ -z "$projects" ]; then
	echo "You should run this script in the root directory of android source code."
	exit 2
fi
CWD=$(pwd)
rls_branch=$2

dryrun_flag=--dry-run
if [ ! -z "$4" ]; then
	if [ "$4" = "actual-run" ]; then
		dryrun_flag=
		if [ $# -ge 4 ]; then
			shift
		fi
	fi
	shift 3

	prj_list=
	i=$#
	prjs_num=$i
	while [ $i -gt 0 ]
	do
		prj=$(repo forall $1 -c 'echo $(pwd):$REPO_REMOTE')
		if [ -z "$prj" ]; then
			echo "Invalid project: $(($i))."
			print_usage
			exit 1
		else
			if [ $i = $prjs_num ]; then
				projects=$prj
			else
				projects=$projects" "$prj
			fi
			prj_path=$(echo $1 | sed 's/\//\\\//g' | sed 's/\/$//g')
			prj_list=$prj_path" "$prj_list
		fi
		i=$(($i-1))
		shift
	done
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

if [ ! -d $HOME/bin ]; then
#hack for specifying user name in ssh
	mkdir -p $HOME/bin
fi

if [ ! -f $HOME/bin/git-ssh ]; then
	cat >$HOME/bin/git-ssh <<-EOF
#!/bin/sh
ssh -l \$GIT_SSH_USER "\$@"
EOF
	chmod a+x $HOME/bin/git-ssh
fi

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
	branch_to_remote $action
	if [ $? -ne 0 ]; then
		echo "git push error."
		exit -1
	fi
	echo 
done

echo "Update manifest branch..."
manifest_prj="${CWD}/.repo/manifests"
cur_manifest="${CWD}/.repo/manifest.xml"
cd ${manifest_prj}
rmt=origin
account=$(get_account_to_use $rmt)
target="default.xml"
if [ "$unique" = "unique" ]; then
	push_target=$(awk '/merge/ { print $NF; exit }' ../manifests.git/config)
	push_target=HEAD:$push_target
	target=$(echo $rls_branch | awk -F_ '{ print $NF }')
	target=$target.xml
fi
if [ "$action" = "create" ]; then
	if [ -z "$dryrun_flag" ]; then
		if [ "$unique" = "unique" ]; then
			cp -f $cur_manifest $target
		fi
		sopt="-i"
		act="s/revision=\"[^[:blank:]]*\"/revision=\"${rls_branch}\"/"
		act1="s/\/>/revision=\"${rls_branch}\" \/>/"
		act2="s/>/revision=\"${rls_branch}\" >/"
	else
		target=$cur_manifest
		sopt="-n"
		act="s/revision=\"[^[:blank:]]*\"/revision=\"${rls_branch}\"/p"
		act1="s/\/>/revision=\"${rls_branch}\" \/>/p"
		act2="s/>/revision=\"${rls_branch}\" >/p"
	fi
	if [ -z "$prj_list" ]; then
		sed $sopt "/revision=\"[^[:blank:]]*\"/$act" $target
	else
		for prj in $prj_list
		do
			sed $sopt -e "/path=\"$prj\"/$act" -e ta \
				-e "/path=\"$prj\"/$act1" -e ta \
				-e "/path=\"$prj\"/$act2" -e :a $target
		done
	fi
	if [ "$unique" = "unique" ]; then
		message="Add $target"
	else
		message="${rls_branch}:enter release cycle"
		push_target=$head:refs/heads/$rls_branch
	fi
	if [ -z "$dryrun_flag" ]; then
		git add $target
		git commit -s -m "$message"
	fi
	GIT_SSH=$HOME/bin/git-ssh GIT_SSH_USER=$account git push $dryrun_flag $rmt $push_target

	if [ $? -ne 0 ]; then
		if [ -z "$dryrun_flag" ]; then
			echo "pushing manifest branch failed, please do it manually, branch name ${rls_branch}."
		else
			echo "pushing manifest branch failed"
		fi
		exit -1
	fi
else
	if [ "$unique" = "unique" ]; then
		if [ -z "$dryrun_flag" ]; then
			git rm $target
			git commit -s -m "Remove $target"
		fi
		GIT_SSH=$HOME/bin/git-ssh GIT_SSH_USER=$account git push $dryrun_flag $rmt
	else
		branch_to_remote $action
	fi
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

