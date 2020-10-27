#compdef nx

zstyle ':completion::complete:nx:*:commands' group-name commands
zstyle ':completion::complete:nx:*:nx_projects' group-name nx_projects
zstyle ':completion::complete:nx:*:nx_projects:nx_targets' group-name nx_targets
zstyle ':completion::complete:nx::' list-grouped

__nx_tool_complete() {
  local ret=1

  local -a commands
  local suf args aopts=()

  _arguments -C \
    '1:command:->command'\
    '2:subcommand:->subcommand'\
    '*::args:->args' && ret=0

  case $state in
    (command)
      __nx_commands
    ;;
    (subcommand)
      case $words[2] in
        run)
          if compset -P '*[:.]'; then
            __nx_targets "${words[3]%:*}" && ret=0
          else
            if compset -S '[.:]*'; then
              suf=()
            else
              suf=( -qS ':' )
            fi
            __nx_projects_with_suffix "$suf[@]" && ret=0
          fi
        ;;

        serve | build | test | lint | e2e)
          __nx_projects && ret=0
        ;;

        run-many)
          __nx_run_many_args
        ;;

        affected | affected:build | affected:test | affected:lint | affected:e2e | affected:apps | affected:libs)
          _nx_affected_args
        ;;

        affected:dep-graph)
          __nx_affected_dep_graph_args
        ;;

        dep-graph)
          __nx_dep_graph_args
        ;;

        list)
          __nx_list_args
        ;;

        report)
          __nx_default_args
        ;;

        migrate)
          __nx_migrate_args
        ;;

        format:check)
          __nx_format_args
        ;;

        format:write)
          __nx_format_args
        ;;

        print-affected)
          __nx_print_affected_args
        ;;

        workspace-lint)
          __nx_default_args
        ;;

        workspace-schematic)
          __nx_workspace_schematic_args
        ;;
      esac
    ;;

    (args)
      case $words[1] in
        run)
          __nx_run_args
        ;;

        run-many)
          __nx_run_many_args
        ;;

        affected | affected:build | affected:test | affected:lint | affected:e2e | affected:apps | affected:libs)
          _nx_affected_args
        ;;

        affected:dep-graph)
          __nx_affected_dep_graph_args
        ;;

        dep-graph)
          __nx_dep_graph_args
        ;;

        list)
          __nx_list_args
        ;;

        report)
          __nx_default_args
        ;;

        migrate)
          __nx_migrate_args
        ;;

        format:check)
          __nx_format_args
        ;;

        format:write)
          __nx_format_args
        ;;

        workspace-lint)
          __nx_default_args
        ;;

        workspace-schematic)
          __nx_workspace_schematic_args
        ;;
      esac
    ;;
  esac

  return $ret
}

__nx_commands() {
  local commands
  commands=(
    "run[Run a target for a project]"
    "run-many[Run task for multiple projects]"
    "generate[Runs a schematic that generates and/or modifies files based on a schematic from a collection.]"
    "serve[Builds and serves an application, rebuilding on file changes.]"
    "build[Compiles an application into an output directory named dist/ at the given output path. Must be executed from within a workspace directory.]"
    "test[Runs unit tests in a project using the configured unit test runner.]"
    "lint[Runs linting tools on application code in a given project folder using the configured linter.]"
    "e2e[Builds and serves an app, then runs end-to-end tests using the configured E2E test runner.]"
    "affected[Run task for affected projects]"
    "affected\:build[Build applications and publishable libraries affected by changes]"
    "affected\:test[Test projects affected by changes]"
    "affected\:lint[Lint projects affected by changes]"
    "affected\:e2e[Run e2e tests for the applications affected by changes]"
    "affected\:apps[Print applications affected by changes]"
    "affected\:libs[Print libraries affected by changes]"
    "affected\:dep-graph[Graph dependencies affected by changes]"
    "dep-graph[Graph dependencies within workspace]"
    "list[Lists installed plugins, capabilities of installed plugins and other available plugins.]"
    "report[Reports useful version numbers to copy into the Nx issue template]"
    "migrate[Creates a migrations file or runs migrations from the migrations file.]"
    "format\:check[Check for un-formatted files]"
    "format\:write[Overwrite un-formatted files]"
    "print-affected[Graph execution plan]"
    "workspace-lint[Lint workspace or list of files. Note: To exclude files from this lint rule, you can add them to the \".nxignore\" file]"
    "workspace-schematic[Runs a workspace schematic from the tools/schematics directory]"
  )
  _values 'nx commands' ${commands[@]} && ret=0
}

__nx_projects() {
  local expl projects
  projects=("${(@f)$(jq -r '.projects|keys|.[]' workspace.json)}")
  _wanted projects expl project compadd -k - projects
}

__nx_projects_with_suffix() {
  local expl projects
  projects=("${(@f)$(jq -r '.projects|keys|.[]' workspace.json)}")
  _wanted projects expl project compadd "$@" -k - projects
}

__nx_targets() {
  local expl targets
  targets=("${(@f)$(jq -r ".projects[\"$@\"].architect|keys|.[]" workspace.json)}")
  _wanted targets expl group compadd -a "$@" - targets
}

__nx_default_args() {
  local args aopts=()
  args=(
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_run_args() {
  local args aopts=()
  args=(
    '--prod[Prod]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_run_many_args() {
  local args aopts=()
  args=(
    '--all[All projects]'
    '--configuration[This is the configuration to use when performing tasks on projects]'
    '--maxParallel[Max number of parallel processes. This flag is ignored if the parallel option is set to false.]'
    '--only-failed[Isolate projects which previously failed]'
    '--parallel[Parallelize the command]'
    '--projects[Projects to run (comma delimited)]'
    '--runner[This is the name of the tasks runner configured in nx.json]'
    '--skip-nx-cache[Rerun the tasks even when the results are available in the cache]'
    '--target[Task to run for affected projects]'
    '--verbose[Print additional error stack trace on failure]'
    '--help[Show help]'
    '--version[Show version number]'
  )

  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_affected_args() {
  local args aopts=()
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
}

__nx_affected_dep_graph_args() {
  local args aopts=()
  args=(
    '--all[All projects]'
    '--base[Base of the current branch (usually master)]'
    '--configuration[This is the configuration to use when performing tasks on projects]'
    '--exclude[Exclude certain projects from being processed]'
    '--file[output file (e.g. --file=output.json or --file=dep-graph.html)]'
    '--files[Change the way Nx is calculating the affected command by providing directly changed files, list of files delimited by commas]'
    '--focus[Use to show the dependency graph for a particular project and every node that is either an ancestor or a descendant.]'
    '--groupByFolder[Group projects by folder in dependency graph]'
    '--head[Latest commit of the current branch (usually HEAD)]'
    '--host[Bind the dep graph server to a specific ip address]'
    '--only-failed[Isolate projects which previously failed]'
    '--runner[This is the name of the tasks runner configured in nx.json]'
    '--skip-nx-cache[Rerun the tasks even when the results are available in the cache]'
    '--uncommitted[Uncommitted changes]'
    '--untracked[Untracked changes]'
    '--verbose[Print additional error stack trace on failure]'
    '--version[Show version number]'
  )

  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_dep_graph_args() {
  local args aopts=()
  args=(
    '--exclude[List of projects delimited by commas to exclude from the dependency graph.]'
    '--file[output file (e.g. --file=output.json or --file=dep-graph.html)]'
    '--focus[Use to show the dependency graph for a particular project and every node that is either an ancestor or a descendant.]'
    '--groupByFolder[Group projects by folder in dependency graph]'
    '--host[Bind the dep graph server to a specific ip address]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_list_args() {
  local args aopts=()
  args=(
    '--plugin[The name of an installed plugin to query]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_migrate_args() {
  local args aopts=()
  args=(
    '--run-migrations[Run migrations from the migrations.json file]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_format_args() {
  local args aopts=()
  args=(
    '--all[All projects]'
    '--base[Base of the current branch (usually master)]'
    '--configuration[This is the configuration to use when performing tasks on projects]'
    '--exclude[Exclude certain projects from being processed]'
    '--files[Change the way Nx is calculating the affected command by providing directly changed files, list of files delimited by commas]'
    '--head[Latest commit of the current branch (usually HEAD)]'
    '--libs-and-apps'
    '--only-failed[Isolate projects which previously failed]'
    '--projects[Projects to format (comma delimited)]'
    '--runner[This is the name of the tasks runner configured in nx.json]'
    '--skip-nx-cache[Rerun the tasks even when the results are available in the cache]'
    '--uncommitted[Uncommitted changes]'
    '--untracked[Untracked changes]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_print_affected_args() {
  local args aopts=()
  args=(
    '--all[All projects]'
    '--base[Base of the current branch (usually master)]'
    '--configuration[This is the configuration to use when performing tasks on projects]'
    '--exclude[Exclude certain projects from being processed]'
    '--files[Change the way Nx is calculating the affected command by providing directly changed files, list of files delimited by commas]'
    '--head[Latest commit of the current branch (usually HEAD)]'
    '--only-failed[Isolate projects which previously failed]'
    '--runner[This is the name of the tasks runner configured in nx.json]'
    '--select'
    '--skip-nx-cache[Rerun the tasks even when the results are available in the cache]'
    '--uncommitted[Uncommitted changes]'
    '--untracked[Untracked changes]'
    '--verbose[Print additional error stack trace on failure]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

__nx_workspace_schematic_args() {
  local args aopts=()
  args=(
    '--list-schematics[List the available workspace-schematics]'
    '--name[The name of your schematic]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" '*:' && ret=0
}

compdef __nx_tool_complete nx
