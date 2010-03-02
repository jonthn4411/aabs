#! /bin/bash
#$1: original branch, such as shgit/mrvl-eclair
#$2: original base, such as shgit/eclair or android-2.1_r2
#$3: new base, such as android-2.1_r2

org_branch=$1
org_base=$2
new_base=$3
push=$4

if [ -z "$org_branch" ] || [ -z "$org_base" ] || [ -z "$new_base" ]; then
	echo 
	echo " Usage: $0 <orginal-branch> <orginal-base> <new-base> [push]"
	echo "      original-branch: original branch, such as shgit/mrvl-eclair"
	echo "      original-base: original base, such as shgit/eclair or android-2.1_r2"
	echo "      new-base: such as android-2.1_r2"
	echo "	    push: if you specify this word, the script will push the HEAD to <original-branch>. If not specifying this word, only rebase is done locally."
	echo " Sample: $0 shgit/mrvl-eclair shgit/eclair android-2.1_r2 "
	exit -1
fi


projects=$(repo forall -c 'echo $(pwd)' | sort)

for prj_path in $projects; do
	
	cd $prj_path > /dev/null
	git rev-parse $org_base >/dev/null 2>&1

	if [ $? -ne 0 ]; then
		cd - > /dev/null
		continue
	fi
	echo
	echo "====handling project:$prj_path"

	git rev-parse $org_branch > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "    orginal branch:$org_branch doesn't exist."
		exit -1
	fi

	git rev-parse $new_base > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "    new base:$new_base doesn't exist."
		exit -1
	fi

	if [ -z "$(git status | grep 'working directory clean')" ]; then
		echo "working tree is not clean"
		exit -1
	fi

	need_rebase=true
	merge_base=$(git merge-base $new_base HEAD)
	newbase_is_tag=$(git tag | grep $new_base)
	if [ ! -z "$newbase_is_tag" ]; then
		desc=$(git describe $merge_base 2>/dev/null)
		if [ "$desc" == "$new_base" ]; then
			echo "    already rebased to new base:$new_base"
			need_rebase=false	
		else
			if [ "$(git describe $new_base 2>/dev/null)" == "$desc" ]; then
				echo "    already rebased to new base:$new_base"
				need_rebase=false
			fi
		fi
	else
		if [ "$merge_base" == "$(git rev-parse $new_base 2>/dev/null)" ]; then
			echo "    already rebased to new base:$new_base"
			need_rebase=false
		fi
	fi

	if [ $need_rebase == "true" ]; then
		git rebase --onto $new_base $org_base

		if [ $? -ne 0 ]; then
			exit -1
		fi
	fi

	if [ "$push" == "push" ]; then
		rmt=${org_branch%%\/*}
		br=${org_branch##*\/}
		echo "    Pushing:git push $rmt +HEAD:$br"
		git push $rmt +HEAD:$br
		if [ $? -ne 0 ]; then
			exit -1
		fi
	fi
	cd - >/dev/null
done

