#!/bin/bash

function cmd_list {
	echo -e "LINES\tLAST ACCESS      \tNAME"
	contexts=$(find "$HOME/.bash_history.d" -type f)
	tmp_contexts=$(find "/tmp/histctx" -type f)
	for context in $contexts $tmp_contexts; do
		printf "%5d\t%s\t%s\n" $(wc -l $context | awk '{ print $1}') "$(stat -c %y $context | cut -c1-19)" $(basename $context)
	done
}

function cmd_rename {
	local original_name="$1"
	local new_name="$2"
	mv -i "$HOME/.bash_history.d/$original_name" "$HOME/.bash_history.d/$new_name"
}

function cmd_delete {
	local context="$1"
	if [ -f /tmp/histctx/$context ]; then
		rm -vi "/tmp/histctx/$context"
	else
		rm -vi "$HOME/.bash_history.d/$context"
	fi
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
	if [[ "$context" == "" ]]; then
		local HISTFILE="$HOME/.bash_history"
		local HISTORY_SESSION=""
	else
		local HISTFILE="$context"
		local HISTORY_SESSION="$(basename $context)"
	fi

	touch "$HISTFILE"
	HISTFILE="$HISTFILE" HISTORY_SESSION="$HISTORY_SESSION" bash
}

command="$1"
case "$command" in
set)
	mkdir -p "$HOME/.bash_history.d"
	set_context "$HOME/.bash_history.d/$2"
	;;
temporary | tmp)
	mkdir -p /tmp/histctx
	set_context $(mktemp -p /tmp/histctx)
	;;
list | ls)
	cmd_list
	;;
rename | mv)
	cmd_rename ${@:2}
	;;
delete | del | remove | rm )
	cmd_delete ${@:2}
	;;
help | '')
	show_usage
	;;
esac
