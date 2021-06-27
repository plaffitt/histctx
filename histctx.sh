#!/bin/bash

function cmd_list {
	echo -e "LINES\tLAST ACCESS      \tNAME"
	for context in $(find "$HOME/.bash_history.d" -type f -exec basename {} \;); do
		local history="$HOME/.bash_history.d/$context"
		printf "%5d\t%s\t%s\n" $(wc -l $history | awk '{ print $1}') "$(stat -c %y $history | cut -c1-19)" $context
	done
}

function cmd_rename {
	local original_name="$1"
	local new_name="$2"
	mv -i "$HOME/.bash_history.d/$original_name" "$HOME/.bash_history.d/$new_name"
}

function cmd_delete {
	local context="$1"
	rm -vi "$HOME/.bash_history.d/$context"
}

function show_usage {
	echo "usage: histctx <command|context> [<args>]

COMMANDS
  list       list existing history contexts
  rename     rename an history context
  delete     delete an history context
  help       show this help message

EXAMPLES
  $ histctx new-context
  $ histctx list
  $ histctx rename new-context my-context
  $ histctx delete my-context"
}

function set_context {
	local context="$1"
	if [[ "$context" == "" ]]; then
		HISTFILE="$HOME/.bash_history"
		HISTORY_SESSION=""
	else
		mkdir -p "$HOME/.bash_history.d"
		HISTFILE="$HOME/.bash_history.d/$context"
		HISTORY_SESSION="$context"
	fi

	touch "$HISTFILE"
	HISTFILE="$HISTFILE" HISTORY_SESSION="$HISTORY_SESSION" bash
}

command="$1"
case "$command" in
list)
	cmd_list
	;;
rename)
	cmd_rename ${@:2}
	;;
delete)
	cmd_delete ${@:2}
	;;
help)
	show_usage
	;;
'')
	show_usage
	;;
*)
	set_context ${@:1}
	;;
esac
