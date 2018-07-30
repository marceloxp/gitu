#!/bin/bash

BOOL_SUCCESS=0
BOOL_FAIL=1

menu_git_tag()
{
	clear
	draw_line
	draw_logo
	print_project_and_git_info
	current_branch=`utils_get_current_branch`

	echo "TAGS"
	draw_line
	echo "1 - List"
	echo "2 - Add"
	echo "3 - Remove"
	draw_line
	echo "ENTER - Back"
	draw_line
	read -p "Choose a option: " opcao;
	case $opcao in
		"1") menu_git_tag_lst ;;
		"2") menu_git_tag_add ;;
		"3") menu_git_tag_del ;;
		"" ) menu_git_tag_back ;;
	esac
}

has_remote()
{
	remotes=$(git branch -r)
	if [ $remotes=="" ]
	then
		return $BOOL_FAIL
	else
		return $BOOL_SUCCESS
	fi
}

menu_git_tag_add()
{
	clear
	git tag --list
	read -e -p "Tag name [cancel]: " tag_name
	if [ "$tag_name" == "" ]
	then
		wait_key
		menu_git_tag
		return
	fi

	begin_script "GIT ADD TAG"

		git tag -d $tag_name
		if has_remote; then
			git push --delete origin $tag_name
		fi

		git tag $tag_name

		if has_remote; then
			git push origin :$tag_name
		fi
	end_script "GIT ADD TAG"

	wait_key
	menu_git_tag
}

menu_git_tag_del()
{
	clear
	draw_line
	echo "List Tags:"
	draw_line
	git tag --list
	draw_line
	read -e -p "Tag name [cancel]: " tag_name
	if [ "$tag_name" == "" ]
	then
		wait_key
		menu_git_tag
		return
	fi

	begin_script "GIT DEL TAG"

		git tag -d $tag_name
		if has_remote; then
			git push --delete origin $tag_name
			git push origin :$tag_name
		fi

	end_script "GIT DEL TAG"

	draw_line
	echo "List Tags:"
	draw_line
	git tag --list
	draw_line

	wait_key
	menu_git_tag
}

menu_git_tag_lst()
{
	clear
	draw_line
	echo "List Tags:"
	draw_line
	git tag --list
	draw_line

	wait_key
	menu_git_tag
}

menu_git_tag_back()
{
	menu_main
}