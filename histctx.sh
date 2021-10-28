#!/bin/bash

function resolve_path {
	local context="$1"
	if [ -f /tmp/histctx/$context ]; then
		echo "/tmp/histctx/$context"
	else
		echo "$HOME/.bash_history.d/$context"
	fi
}

function get_current_context {
	current_context=$(cat $HOME/.histctx)
	if [ "$current_context" != "$HOME/.bash_history" ]; then
		echo $current_context
	fi
}

function cmd_list {
	echo -e "LINES\tLAST ACCESS      \tNAME"
	contexts=$(find "$HOME/.bash_history.d" -type f)
	tmp_contexts=$(find "/tmp/histctx" -type f)
	for context in $contexts $tmp_contexts; do
		local context_name=$(basename $context)
		if [ "$context_name" == "$HISTORY_CONTEXT" ]; then
			echo -n '*'
		else
			echo -n ' '
		fi
		printf "%5d\t%s\t%s\n" $(wc -l $context | awk '{ print $1}') "$(stat -c %y $context | cut -c1-19)" "$context_name"
	done
}

function cmd_rename {
	local original_name="$1"
	local new_name="$2"
	mv -i $(resolve_path $original_name) "$HOME/.bash_history.d/$new_name"
}

function cmd_delete {
	local context="$1"
	rm -vi $(resolve_path $context)
}

function show_usage {
	echo "usage: histctx <command|context> [<args>]

COMMANDS
  set                      set a context, create it if it doesn't exists yet
  temporary|tmp            create a temporary context and set it as current
  list|ls                  list existing history contexts
  rename|mv                rename an history context
  delete|del|remove|rm     delete an history context
  help                     show this help message

EXAMPLES
  $ histctx set new-context
  $ histctx tmp
  $ histctx list
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
	echo $histfile > ~/.histctx
	HISTFILE="$histfile" HISTORY_CONTEXT="$context_name" bash
}

touch ~/.histctx
mkdir -p /tmp/histctx

command="$1"
case "$command" in
set)
	mkdir -p "$HOME/.bash_history.d"
	set_context "$HOME/.bash_history.d/$2"
	;;
temporary | tmp)
	set_context $(mktemp -p /tmp/histctx)
	;;
list | ls)
	cmd_list
	;;
rename | mv)
	cmd_rename ${@:2}
	;;
delete | del | remove | rm)
	cmd_delete ${@:2}
	;;
'')
	current_context=$(get_current_context)
	if [ "$current_context" != "" ] && [ "$HISTORY_CONTEXT" != "$(basename "$current_context")" ]; then
		set_context "$current_context"
	fi
	;;
*)
	echo "histctx: $command command not found" 1>&2
	exit 1
	;;
esac
