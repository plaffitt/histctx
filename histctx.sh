#!/bin/bash

function resolve_path {
	local context="$1"
	if [ -f "/tmp/histctx/$context" ]; then
		echo "/tmp/histctx/$context"
	else
		echo "$HOME/.bash_history.d/$context"
	fi
}

function get_current_context {
	current_context=$(cat "$HOME/.histctx")
	if [ "$current_context" != "$HOME/.bash_history" ]; then
		echo "$current_context"
	fi
}

function list_contexts_names {
	contexts=$(find "$HOME/.bash_history.d" -type f)
	for context in $contexts; do
		basename "$context"
	done
}

function cmd_show {
	if [ $# -eq 0 ]; then
		set -- $(list_contexts_names)
	fi
	max_length=0
	for context in "$@"; do
		if [[ ! -f "$HOME/.bash_history.d/$context" ]]; then
			echo "invalid argument: \"$context\" doesn't exist"
			exit 1
		fi
		local length=${#context}
		if (( length > max_length )); then
			max_length=$length
		fi
	done
	for context in "$@"; do
		name_colunm=$(printf "%-${max_length}s" "$context")
		awk "{print \"$name_colunm | \" \$0}" "$HOME/.bash_history.d/$context"
	done
}

function cmd_list {
	echo -e "LINES\tLAST ACCESS      \tNAME"
	contexts=$(find "$HOME/.bash_history.d" -type f)
	for context in $contexts; do
		local context_name=$(basename $context)
		if [ "$context_name" == "$HISTORY_CONTEXT" ]; then
			echo -n '*'
		else
			echo -n ' '
		fi
		local last_access=$(stat -c %y "$context" | cut -c1-19)
		local lines=$(wc -l $context | awk '{ print $1}')
		printf "%5d\t%s\t%s\n" "$lines" "$last_access" "$context_name"
	done
}

function cmd_rename {
	local context_path=$(resolve_path $1)
	local new_name="$2"
	mv -i "$context_path" "$HOME/.bash_history.d/$new_name"
}

function cmd_delete {
	local context_path=$(resolve_path $1)
	rm -vi "$context_path"
}

function show_usage {
	echo "usage: histctx <command|context> [<args>]

COMMANDS
  set                      set a context, create it if it doesn't exists yet. \"$0 set .\" expands \".\" as the current folder name
  temporary|tmp            create a context in /tmp and set it as current
  list|ls                  list existing history contexts
  show|cat                 show history of given contexts, or all histories if no argument is given
  rename|mv                rename an history context
  delete|del|remove|rm     delete an history context
  help                     show this help message

EXAMPLES
  $ histctx set new-context
  $ histctx set .
  $ histctx tmp
  $ histctx list
  $ histctx show my-context another-context
  $ histctx rename new-context my-context
  $ histctx delete my-context"
}

function set_context {
	local context="$1"
	if [[ "$context" == "$HOME/.bash_history.d/" ]]; then
		local histfile="$HOME/.bash_history"
		local context_name=""
	else
		local histfile="$context"
		local context_name="$(basename $context)"
	fi

	touch "$histfile"
	echo "$histfile" > ~/.histctx
	HISTFILE="$histfile" HISTORY_CONTEXT="$context_name" bash
}

touch ~/.histctx
mkdir -p /tmp/histctx

command="$1"
case "$command" in
set)
	name="$2"
	if [[ "$name" == "." ]]; then
		name=$(basename "$(pwd)")
	fi
	mkdir -p "$HOME/.bash_history.d"
	set_context "$HOME/.bash_history.d/$name"
	;;
temporary | tmp)
	set_context /tmp/bash_history.tmp
	read -rn1 -p "clear this history? (Y/n): " confirmation
	if [[ "$confirmation" == "" ]]; then
		confirmation="y"
	else
		echo
	fi
	if [[ "$confirmation" =~ ^[Yy]$ ]]; then
		rm /tmp/bash_history.tmp
	fi
	;;
list | ls)
	cmd_list
	;;
show | cat)
	cmd_show "${@:2}"
	;;
rename | mv)
	cmd_rename "$2" "$3"
	;;
delete | del | remove | rm)
	cmd_delete "${@:2}"
	;;
help)
	show_usage
	;;
'')
	current_context=$(get_current_context)
	if [ "$current_context" != "" ] && [ "$HISTORY_CONTEXT" != "$(basename "$current_context")" ]; then
		set_context "$current_context"
	fi
	;;
*)
	echo "histctx: $command command not found" 1>&2
	show_usage
	exit 1
	;;
esac
