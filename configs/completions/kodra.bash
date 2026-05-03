#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  Kodra WSL — Bash Completions                               ║
# ╚══════════════════════════════════════════════════════════════╝

_kodra() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    commands="doctor repair update setup fetch version help install uninstall backup restore resume migrate cleanup refresh menu welcome motd dev extensions shortcuts db"

    case "$prev" in
        kodra)
            COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
            return 0
            ;;
        doctor)
            COMPREPLY=( $(compgen -W "--fix --verbose --json" -- "$cur") )
            return 0
            ;;
        repair)
            COMPREPLY=( $(compgen -W "--all --force --dry-run" -- "$cur") )
            return 0
            ;;
        update)
            COMPREPLY=( $(compgen -W "--force --channel" -- "$cur") )
            return 0
            ;;
        --channel)
            COMPREPLY=( $(compgen -W "stable beta nightly" -- "$cur") )
            return 0
            ;;
        setup)
            COMPREPLY=( $(compgen -W "--minimal --force" -- "$cur") )
            return 0
            ;;
        backup)
            COMPREPLY=( $(compgen -W "create list restore delete" -- "$cur") )
            return 0
            ;;
        install|uninstall)
            COMPREPLY=( $(compgen -W "all shell tools azure kubernetes docker git" -- "$cur") )
            return 0
            ;;
        dev)
            COMPREPLY=( $(compgen -W "lint test build clean" -- "$cur") )
            return 0
            ;;
        extensions)
            COMPREPLY=( $(compgen -W "install list sync export import" -- "$cur") )
            return 0
            ;;
        shortcuts)
            COMPREPLY=( $(compgen -W "list add remove reset" -- "$cur") )
            return 0
            ;;
        db)
            COMPREPLY=( $(compgen -W "init migrate reset status" -- "$cur") )
            return 0
            ;;
        cleanup)
            COMPREPLY=( $(compgen -W "--all --dry-run" -- "$cur") )
            return 0
            ;;
        *)
            # Complete flags that start with --
            if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "--help --version --verbose" -- "$cur") )
            fi
            return 0
            ;;
    esac
}

complete -F _kodra kodra
