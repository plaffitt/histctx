#!/bin/bash

function _histctx_completions {
	local contexts=$(histctx ls | awk '{print $4}' | tail -n +2)

	case "$COMP_CWORD" in
	1)
		local commands="set"
		commands+=" temporary tmp"
		commands+=" list ls"
		commands+=" rename mv"
		commands+=" delete del remove rm"
		commands+=" help"
		COMPREPLY+=($(compgen -W "$commands" "${COMP_WORDS[1]}"))
		;;
	2)
		case "${COMP_WORDS[1]}" in
		set | \
			rename | mv | \
			delete | del | remove | rm)
			COMPREPLY=($(compgen -W "$contexts" "${COMP_WORDS[2]}"))
			;;
		*) ;;
		esac
		;;
	*) ;;
	esac

}

complete -F _histctx_completions histctx
