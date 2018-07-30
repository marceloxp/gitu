#!/bin/bash

source "inc_tag.sh"

menu_main()
{
	clear
	draw_line
	draw_logo
	print_project_and_git_info
	current_branch=`utils_get_current_branch`

	echo "0 - Git diff GUI                5 - Commit files"
	echo "1 - Get git status              6 - Undo commit"
	echo "2 - Stage all pending files     7 - V Pull files from orign ("$current_branch")"
	echo "3 - Unstage commited files      8 - ^ Push files to   orign ("$current_branch")"
	echo "4 - Discard changes             9 - Tags"
	draw_line
	echo "BU - Branches utilities         ENTER - Exit"
	echo "ZP - Generate Zip"
	draw_line
	read -p "Choose a GIT command: " opcao;
	case $opcao in
		"0"|"gitk") menu_git_k ;;
		"1") menu_git_status ;;
		"2") menu_git_add_all ;;
		"3") menu_unstage_files ;;
		"4") menu_discard_changes ;;
		"5") menu_commit_files ;;
		"6") menu_undo_last_commit ;;
		"7") menu_pull_files ;;
		"8") menu_push_files ;;
		"9") menu_git_tag ;;
		"ZP"|"zp") menu_zip_files ;;
		"BU"|"bu") menu_branches ;;
	esac
}

print_project_and_git_info()
{
	draw_line
	package_name=`utils_get_package_name`
	if [ "$package_name" != "" ]
	then
		package_version=`utils_get_package_version`
		echo -n "Project:" $package_name "("$package_version")"
	else
		echo -n "No Project"
	fi
	current_branch=`utils_get_current_branch`
	echo " - Current Branch: "$current_branch
	draw_line
}

utils_get_package_version()
{
	if [ -e "package.json" ]
	then
		PACKAGE_VERSION=$(sed -nE 's/^\s*"version": "(.*?)",$/\1/p' package.json)
		echo $PACKAGE_VERSION
	else
		echo ""
	fi
}

utils_get_package_name()
{
	if [ -e "package.json" ]
	then
		PACKAGE_NAME=$(sed -nE 's/^\s*"name": "(.*?)",$/\1/p' package.json)
		echo $PACKAGE_NAME
	else
		echo ""
	fi
}

# functions
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function utils_get_current_branch()
{
	ref=$(git symbolic-ref HEAD 2> /dev/null) || \
	ref=$(git rev-parse --short HEAD 2> /dev/null) || return
	echo ${ref#refs/heads/}
}

menu_branches()
{
	clear
	draw_line
	draw_logo
	print_project_and_git_info

	echo "1 - List local branchs"
	echo "2 - List remote branchs"
	echo "3 - List local and remote branchs"
	draw_line
	echo "ENTER - Back"
	draw_line
	echo ""
	read -p "Choose a BRANCH command: " opcao;
		case $opcao in
		 "1")
			clear
			begin_script "LIST LOCAL BRANCHES"
			git branch
			end_script "LIST LOCAL BRANCHES"
			wait_key
			menu_branches
			;;
		 "2")
			clear
			begin_script "LIST REMOTE BRANCHES"
			git branch -r
			end_script "LIST REMOTE BRANCHES"
			wait_key
			menu_branches
			;;
		 "3")
			clear
			begin_script "LIST LOCAL AND REMOTE BRANCHES"
			git branch -a
			end_script "LIST LOCAL AND REMOTE BRANCHES"
			wait_key
			menu_branches
			;;
		 "")
			menu_main
		 ;;
	esac
}

git_status()
{
	begin_script "GIT STATUS"
	git status
	end_script "GIT STATUS"
}

wait_key()
{
	read -p "Press any key to continue... " -n1 -s
	echo ""
	echo ""
}

separator()
{
	echo ""
	draw_line
	echo ""
}

draw_line()
{
	echo "---------------------------------------------------------------------------------------------"
}

draw_logo()
{
	echo "   ________________   __________  __  _____  ______    _   ______  _____"
	echo "  / ____/  _/_  __/  / ____/ __ \/  |/  /  |/  /   |  / | / / __ \/ ___/"
	echo " / / __ / /  / /    / /   / / / / /|_/ / /|_/ / /| | /  |/ / / / /\__ \ "
	echo "/ /_/ // /  / /    / /___/ /_/ / /  / / /  / / ___ |/ /|  / /_/ /___/ / "
	echo "\____/___/ /_/     \____/\____/_/  /_/_/  /_/_/  |_/_/ |_/_____//____/  "
}

begin_script()
{
	draw_line
	echo "BEGIN" $1
	draw_line
}

end_script()
{
	draw_line
	echo "END" $1
	draw_line
}

menu_git_k()
{
	clear
	gitk &
	menu_main
}

menu_git_status()
{
	clear
	begin_script "GIT STATUS"
	git status
	end_script "GIT STATUS"
	wait_key
	menu_main
}

menu_git_add_all()
{
	clear
	begin_script "GIT ADD ALL"
	git add --all
	end_script "GIT ADD ALL"
	git_status
	wait_key
	menu_main
}

menu_discard_changes()
{
	git_status
	read -e -p "Discard file [empty to all/cancel]: " file_name
	if [ "$file_name" == "cancel" ]
	then
		menu_main
		return
	elif [ "$file_name" == "" ]
	then
		begin_script "DISCARD CHANGES ALL FILES"
		git checkout -- .
		end_script "DISCARD CHANGES ALL FILES"
		git_status
	else
		if [ -e $file_name ]
		then
			begin_script "DISCARD CHANGE IN FILE"
			git checkout $file_name
			end_script "DISCARD CHANGE IN FILE"
			git_status
		else
			echo "File not found!"
		fi
	fi
	wait_key
	menu_main
}

menu_commit_files()
{
	clear
	commit_message=""
	get_line="endline"

	until [[ $get_line = "" ]];do
		read -p "Commit message [done]: " get_line
		if [[ $get_line == "" ]]
		then
			echo $commit_message
			git commit -m"$(echo -e "$commit_message")"
			wait_key
			menu_main
			return
		else
			if [[ $commit_message == "" ]]
			then
				commit_message=$get_line
			else
				commit_message=$commit_message$"\n"$get_line
			fi
		fi
	done
	exit 0
}

menu_unstage_files()
{
	clear
	git_status
	read -e -p "File to unstage [empty to all/cancel]: " file_name
	if [ "$file_name" == "" ]
	then
		begin_script "GIT UNSTAGE ALL"
		git reset HEAD -- .
		end_script "GIT UNSTAGE ALL"
		git status
		wait_key
		menu_main
		return
	elif [ "$file_name" == "cancel" ]
	then
		menu_main
		return
	else
		if [ "$file_name" == "" ]
		then
			menu_main
			return
		else
			if [ -e $file_name ]
			then
				begin_script "GIT UNSTAGE FILE"
				git reset HEAD $file_name
				end_script "GIT UNSTAGE FILE"
				git_status
			else
				echo "File not found!"
			fi
		fi
	fi
	wait_key
	menu_main
}

menu_undo_last_commit()
{
	clear
	begin_script "LAST COMMIT"
	git log -1
	end_script "LAST COMMIT"
	read -e -p "Undo last commit [empty to last/first/none]: " last_commit_type

	if [ "$last_commit_type" == "" ]
	then
		begin_script "GIT UNDO LAST COMMIT"
		git_status
		git reset --soft HEAD~
		end_script "GIT UNDO LAST COMMIT"
		wait_key
		menu_main
	elif [ "$last_commit_type" == "first" ]
	then
		begin_script "UNDO FIRST COMMIT"
		git update-ref -d HEAD
		end_script "UNDO FIRST COMMIT"
		wait_key
		menu_main
	else
		menu_main
	fi
}

menu_pull_files()
{
	current_branch=`utils_get_current_branch`

	if [ "$current_branch" != "" ]
	then
		git pull origin $current_branch
	else
		echo -n "Current branch not found!"
	fi
	wait_key
	menu_main
}

menu_push_files()
{
	current_branch=`utils_get_current_branch`

	if [ "$current_branch" != "" ]
	then
		git pull origin $current_branch && git push origin $current_branch
	else
		echo -n "Current branch not found!"
	fi
	wait_key
	menu_main
}

utils_get_last_commit()
{
	echo $(git log -n1 --format="%h")
}

menu_zip_files()
{
	git log --oneline --decorate --color --graph

	last_commit=$(utils_get_last_commit)
	zip_file_name="package_"$(date '+%Y%m%d_%H%M%S')".zip"

	read -e -p "Second SHA1 commit [cancel]: " commit_name
	if [ "$commit_name" != "" ]
	then
		git archive -o $zip_file_name HEAD $(git diff --name-only $commit_name $last_commit)
		echo $zip_file_name " generated."
	fi

	wait_key
	menu_main
}

case $1 in
	"branches") menu_branches ;;
	*) menu_main ;;
esac