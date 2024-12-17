#!/bin/bash

function _histctx_completions {
	local cur contexts
	cur="${COMP_WORDS[COMP_CWORD]}"

	mapfile -t contexts < <(histctx ls | awk '{print $4}' | tail -n +2 | sort)

	case $COMP_CWORD in
		1)
			local commands=(
				"set"
				"temporary" "tmp"
				"list" "ls"
				"show" "cat"
				"rename" "mv"
				"delete" "del" "remove" "rm"
				"help"
			)
			mapfile -t COMPREPLY < <(compgen -W "${commands[*]}" -- "$cur")
			;;
		2)
			case "${COMP_WORDS[1]}" in
				set|rename|mv|delete|del|remove|rm|show|cat)
					mapfile -t COMPREPLY < <(compgen -W "${contexts[*]}" -- "$cur")
					;;
				*)
					COMPREPLY=()
					;;
			esac
			;;
		3)
			case "${COMP_WORDS[1]}" in
				rename|mv)
					COMPREPLY=()
					;;
				delete|del|remove|rm|show|cat)
					mapfile -t COMPREPLY < <(compgen -W "${contexts[*]}" -- "$cur")
					;;
				*)
					COMPREPLY=()
					;;
			esac
			;;
		*)
			case "${COMP_WORDS[1]}" in
				delete|del|remove|rm|show|cat)
					mapfile -t COMPREPLY < <(compgen -W "${contexts[*]}" -- "$cur")
					;;
				*)
					COMPREPLY=()
					;;
			esac
			;;
	esac
}

complete -F _histctx_completions histctx
