#!/bin/bash
#read -p "enter source branch name you want to cherry-pick from: "  branch_name
branch_name='rel4_master'

git log --oneline --reverse $branch_name | while read LINE
do
	# Bypass merge commit
	if [[ $LINE =~ 'Merge branch' ]]; then
		echo "Bypass merge commit"
	else
		# Go thru rest of commits
		commit_id=`echo $LINE | awk '{print $1}'`

		# Check if this commit exist is from ancestor branch
		git merge-base --is-ancestor $commit_id HEAD
		if [ $? -eq 0 ]; then
			echo "$commit_id is from ancestor"
		else
			echo "Cherry-pick $commit_id..."
			git cherry-pick -X $commit_id theirs
			# Fix conflicts
			if [ $? -ne 0 ]; then
				git status | sed -n 's/deleted by us://p' | xargs git add
				git status | sed -n 's/both modified://p' | xargs git checkout --theirs
				git cherry-pick --continue
			fi			
		fi
	fi
done
