#compdef nx

zstyle ':completion::complete:nx:*:commands' group-name commands
zstyle ':completion::complete:nx:*:nx_projects' group-name nx_projects
zstyle ':completion::complete:nx:*:nx_projects:nx_targets' group-name nx_targets
zstyle ':completion::complete:nx::' list-grouped

__nx_tool_complete() {
  local ret=1

  local -a commands
  local suf args aopts=( -A '-*' )

  _arguments -C \
    '1:command:->command'\
    '2:subcommand:->subcommand'\
    '*::args:->args' && ret=0

  case $state in
    (command)
      commands=(
        "run[Run a target for a project]"
        "affected[Run task for affected projects]"
      )
      _values 'nx tool commands' ${commands[@]} && ret=0
    ;;
    (subcommand)
      case $words[2] in
        run)
          if compset -P '*[:.]'; then
            _nx_targets "${words[3]%:*}" && ret=0
          else
            if compset -S '[.:]*'; then
              suf=()
            else
              suf=( -qS ':' )
            fi
            _nx_projects "$suf[@]" && ret=0
          fi
        ;;
        affected)
          aopts=()
          args=(
            '--all[All projects]'
            '--base[Base of the current branch (usually master)]'
            '--configuration[This is the configuration to use when performing tasks on projects]'
            '--exclude[Exclude certain projects from being processed]'
            '--head[Latest commit of the current branch (usually HEAD)]'
            '--maxParallel[Max number of parallel processes. This flag is ignored if the parallel option is set to false.]'
            '--only-failed[Isolate projects which previously failed]'
            '--parallel[Parallelize the command]'
            '--runner[This is the name of the tasks runner configured in nx.json]'
            '--skip-nx-cache[Rerun the tasks even when the results are available in the cache]'
            '--target[Task to run for affected projects]'
            '--uncommitted[Uncommitted changes]'
            '--untracked[Untracked changes]'
            '--verbose[Print additional error stack trace on failure]'
            '--version[Show version number]'
          )

          _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
      esac
    ;;

    (args)
      case $words[1] in
        run)
          aopts=()
          args=(
            '--prod[Prod]'
          )
          _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
        ;;
      esac
    ;;
  esac

  return $ret
}

_nx_projects() {
  local expl projects
  projects=("${(@f)$(jq -r '.projects|keys|.[]' workspace.json)}")
  _wanted projects expl project compadd "$@" -k - projects
}

_nx_targets() {
  local expl targets
  targets=("${(@f)$(jq -r ".projects[\"$@\"].architect|keys|.[]" workspace.json)}")
  _wanted targets expl group compadd -a "$@" - targets
}

compdef __nx_tool_complete nx
