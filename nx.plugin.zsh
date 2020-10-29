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
          __nx_run_target
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

        serve)
          __nx_serve_args
        ;;

        lint)
          __nx_lint_args
        ;;

        test)
          __nx_test_args
        ;;

        e2e)
          __nx_e2e_args
        ;;

        build)
          __nx_build_args
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

__nx_run_target() {
  local ret=1
  if compset -P 1 '*:'; then
    local project="${${IPREFIX%:}##*:}"

    if compset -P 1 '*:'; then
      local architect="${${IPREFIX%:}##*:}"
      __nx_configurations $project $architect && ret=0
    else
      __nx_architects $project && ret=0
    fi
  else
    __nx_projects_with_suffix && ret=0
  fi

  return ret
}

__nx_projects() {
  local expl projects
  projects=("${(@f)$(jq -r '.projects|keys|.[]' workspace.json)}")
  _wanted projects expl project compadd -k - projects
}

__nx_projects_with_suffix() {
  local expl projects
  projects=("${(@f)$(jq -r '.projects|keys|.[]' workspace.json)}")
  _wanted projects expl project compadd -qS ':' -k - projects
}

__nx_architects() {
  local expl architects
  architects=("${(@f)$(jq -r ".projects[\"$1\"].architect|keys|.[]" workspace.json)}")
  _wanted architects expl architect compadd -qS ':' -k - architects
}

__nx_configurations() {
  local expl configurations
  configurations=("${(@f)$(jq -r ".projects[\"$1\"].architect[\"$2\"].configurations|keys|.[]" workspace.json)}")
  _wanted configurations expl group compadd -k - configurations
}

__nx_default_args() {
  local args aopts=()
  args=(
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" ':*'
}

__nx_run_args() {
  local args aopts=()
  args=(
    '--prod[Prod]'
  )
  _arguments -C -s -S $aopts "$args[@]" ':*'
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

  _arguments -C -s -S $aopts "$args[@]" ':*'
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

  _arguments -C -s -S $aopts "$args[@]" ':*'
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
    '--only-failed[Isolate projects which previously failed]:toggle:(true false)'
    '--runner[This is the name of the tasks runner configured in nx.json]'
    '--skip-nx-cache[Rerun the tasks even when the results are available in the cache]'
    '--uncommitted[Uncommitted changes]:toggle:(true false)'
    '--untracked[Untracked changes]:toggle:(true false)'
    '--verbose[Print additional error stack trace on failure]'
    '--version[Show version number]'
  )

  _arguments -C -s -S $aopts "$args[@]" ':*'
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
  _arguments -C -s -S $aopts "$args[@]" ':*'
}

__nx_list_args() {
  local args aopts=()
  args=(
    '--plugin[The name of an installed plugin to query]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" ':*'
}

__nx_migrate_args() {
  local args aopts=()
  args=(
    '--run-migrations[Run migrations from the migrations.json file]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" ':*'
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
  _arguments -C -s -S $aopts "$args[@]" ':*'
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
  _arguments -C -s -S $aopts "$args[@]" ':*'
}

__nx_workspace_schematic_args() {
  local args aopts=()
  args=(
    '--list-schematics[List the available workspace-schematics]'
    '--name[The name of your schematic]'
    '--help[Show help]'
    '--version[Show version number]'
  )
  _arguments -C -s -S $aopts "$args[@]" ':*'
}

__nx_serve_args() {
  local args common_args web_serve_args aopts=()
  args=(
    '--allowedHosts[This option allows you to whitelist services that are allowed to access the dev server.]'
    '--host[Host to listen on.]'
    '--liveReload[Whether to reload the page on change, using live-reload.]'
    '--open (-o)[Open the application in the browser.]'
    '--port[Port to listen on.]'
    '--publicHost[Public URL where the application will be served]'
    '--ssl[Serve using HTTPS.]'
    '--sslKey[SSL key to use for serving HTTPS.]'
    '--sslCert[SSL certificate to use for serving HTTPS.]'
    '--watch[Watches for changes and rebuilds application]'
    '--help[Show help]'
    '--version[Show version number]'
    '--buildTarget[Target which builds the application]'
    '--memoryLimit[Memory limit for type checking service process in MB.]'
    '--maxWorkers[Number of workers to use for type checking.]'
    '--aot[Build using Ahead of Time compilation.]'
    '--base-href[Base url for the application being built.]'
    '--browser-target[Target to serve.]'
    '--build-event-log[EXPERIMENTAL Output file path for Build Event Protocol events.]'
    '--common-chunk[Use a separate bundle containing code used across multiple bundles.]'
    '--configuration (-c)[A named build target, as specified in the \"configurations\" section of the workspace configuration.\nEach named target is accompanied by a configuration of option defaults for that target.\nSetting this explicitly overrides the --prod flag]'
    '--deploy-url[URL where files will be deployed.]'
    $'--disable-host-check[Don\'t verify connected clients are part of allowed hosts.]'
    '--eval-source-map[Output in-file eval sourcemaps.]'
    '--hmr[Enable hot module replacement.]'
    '--hmr-warning[Show a warning when the --hmr option is enabled.]'
    '--optimization[Enables optimization of the build output.]'
    '--poll[Enable and define the file watching poll time period in milliseconds.]'
    '--prod[Shorthand for --configuration=production.\nWhen true, sets the build configuration to the production target.\nBy default, the production target is set up in the workspace configuration such that all builds make use of bundling, limited tree-shaking, and also limited dead code elimination.]'
    '--progress[Log progress to the console while building.]'
    '--proxy-config[Proxy configuration file.]'
    '--public-host[The URL that the browser client (or live-reload client, if enabled) should use to connect to the development server. Use for a complex dev server setup, such as one with reverse proxies.]'
    '--serve-path[The pathname where the app will be served.]'
    '--serve-path-default-warning[Show a warning when deploy-url/base-href use unsupported serve path values.]'
    '--source-map[Output sourcemaps.]'
    '--vendor-chunk[Use a separate bundle containing only vendor libraries.]'
    '--vendor-source-map[Resolve vendor packages sourcemaps.]'
    '--verbose[Adds more details to output logging.]'
  )

  _arguments -C -s -S $args ':*'
}

__nx_lint_args() {
  local args common_args web_serve_args aopts=()
  args=(
    '--linter[The tool to use for running lint checks. (default: eslint)]'
    '--config[The name of the configuration file.]'
    '--tsConfig[The name of the TypeScript configuration file.]'
    '--format[ESLint Output formatter (https://eslint.org/docs/user-guide/formatters). (default: stylish)]'
    '--exclude[Files to exclude from linting. (default: )]'
    '--files[Files to include in linting. (default: )]'
    '--force[Succeeds even if there was linting errors.]'
    '--silent[Hide output text.]'
    '--fix[Fixes linting errors (may overwrite linted files).]'
    '--cache[Only check changed files.]'
    '--cacheLocation[Path to the cache file or directory.]'
    '--outputFile[File to write report to.]'
    '--maxWarnings[Number of warnings to trigger nonzero exit code - default: -1 (default: -1)]'
    '--quiet[Report errors only - default: false]'
    '--help[Show available options for project target.]'
  )

  _arguments -C -s -S $args ':*'
}

__nx_test_args() {
  local args common_args web_serve_args aopts=()
  args=(
    '--codeCoverage[Indicates that test coverage information should be collected and reported in the output. (https://jestjs.io/docs/en/cli#coverage)]'
    '--config[The path to a Jest config file specifying how to find and execute tests. If no rootDir is set in the config, the directory containing the config file is assumed to be the rootDir for the project. This can also be a JSON-encoded value which Jest will use as configuration]'
    $'--clearCache[Deletes the Jest cache directory and then exits without running tests. Will delete Jest\'s default cache directory. _Note: clearing the cache will reduce performance_.]'
    '--detectOpenHandles[Attempt to collect and print open handles preventing Jest from exiting cleanly (https://jestjs.io/docs/en/cli.html#--detectopenhandles)]'
    '--jestConfig[The path of the Jest configuration. (https://jestjs.io/docs/en/configuration)]'
    '--testFile[The name of the file to test.]'
    '--tsConfig[\[Deprecated\] The name of the Typescript configuration file. Set the tsconfig option in the jest config file.]'
    '--setupFile[\[Deprecated\] The name of a setup file used by Jest. (use Jest config file https://jestjs.io/docs/en/configuration#setupfilesafterenv-array)]'
    '--bail[Exit the test suite immediately after `n` number of failing tests. (https://jestjs.io/docs/en/cli#bail)]'
    '--ci[Whether to run Jest in continuous integration (CI) mode. This option is on by default in most popular CI environments. It will prevent snapshots from being written unless explicitly requested. (https://jestjs.io/docs/en/cli#ci)]'
    '--color[Forces test results output color highlighting (even if stdout is not a TTY). Set to false if you would like to have no colors. (https://jestjs.io/docs/en/cli#colors)]'
    '--findRelatedTests[Find and run the tests that cover a comma separated list of source files that were passed in as arguments. (https://jestjs.io/docs/en/cli#findrelatedtests-spaceseparatedlistofsourcefiles)]'
    '--json[Prints the test results in JSON. This mode will send all other test output and user messages to stderr. (https://jestjs.io/docs/en/cli#json)]'
    '--maxWorkers[Specifies the maximum number of workers the worker-pool will spawn for running tests. This defaults to the number of the cores available on your machine. Useful for CI. (its usually best not to override this default) (https://jestjs.io/docs/en/cli#maxworkers-num)]'
    $'--onlyChanged[Attempts to identify which tests to run based on which files have changed in the current repository. Only works if you\'re running tests in a git or hg repository at the moment. (https://jestjs.io/docs/en/cli#onlychanged)]'
    '--outputFile[Write test results to a file when the --json option is also specified. (https://jestjs.io/docs/en/cli#outputfile-filename)]'
    '--passWithNoTests[Will not fail if no tests are found (for example while using `--testPathPattern`.) (https://jestjs.io/docs/en/cli#passwithnotests)]'
    '--runInBand[Run all tests serially in the current process (rather than creating a worker pool of child processes that run tests). This is sometimes useful for debugging, but such use cases are pretty rare. Useful for CI. (https://jestjs.io/docs/en/cli#runinband)]'
    '--showConfig[Print your Jest config and then exits. (https://jestjs.io/docs/en/cli#--showconfig)]'
    '--silent[Prevent tests from printing messages through the console. (https://jestjs.io/docs/en/cli#silent)]'
    '--testNamePattern[Run only tests with a name that matches the regex pattern. (https://jestjs.io/docs/en/cli#testnamepattern-regex)]'
    '--testPathPattern[An array of regexp pattern strings that is matched against all tests paths before executing the test. (https://jestjs.io/docs/en/cli#testpathpattern-regex)]'
    '--colors[Forces test results output highlighting even if stdout is not a TTY. (https://jestjs.io/docs/en/cli#colors)]'
    '--reporters[Run tests with specified reporters. Reporter options are not available via CLI. Example with multiple reporters: jest --reporters="default" --reporters="jest-junit" (https://jestjs.io/docs/en/cli#reporters)]'
    '--verbose[Display individual test results with the test suite hierarchy. (https://jestjs.io/docs/en/cli#verbose)]'
    '--coverageReporters[A list of reporter names that Jest uses when writing coverage reports. Any istanbul reporter]'
    '--coverageDirectory[The directory where Jest should output its coverage files.]'
    '--testResultsProcessor[Node module that implements a custom results processor. (https://jestjs.io/docs/en/configuration#testresultsprocessor-string)]'
    '--updateSnapshot[Use this flag to re-record snapshots. Can be used together with a test suite pattern or with `--testNamePattern` to re-record snapshot for test matching the pattern. (https://jestjs.io/docs/en/cli#updatesnapshot)]'
    '--useStderr[Divert all output to stderr.]'
    '--watch[Watch files for changes and rerun tests related to changed files. If you want to re-run all tests when a file has changed, use the `--watchAll` option. (https://jestjs.io/docs/en/cli#watch)]'
    '--watchAll[Watch files for changes and rerun all tests when something changes. If you want to re-run only the tests that depend on the changed files, use the `--watch` option. (https://jestjs.io/docs/en/cli#watchall)]'
    '--testLocationInResults[Adds a location field to test results.  Used to report location of a test in a reporter. \{ "column": 4, "line": 5 \} (https://jestjs.io/docs/en/cli#testlocationinresults)]'
    '--help[Show available options for project target.]'
  )

  _arguments -C -s -S $args ':*'
}


__nx_e2e_args() {
  local args common_args web_serve_args aopts=()
  args=(
    "--baseUrl[Use this to pass directly the address of your distant server address with the port running your application.]"
    "--configuration (-c)[A named build target, as specified in the \"configurations\" section of angular.json. Each named target is accompanied by a configuration of option defaults for that target. Setting this explicitly overrides the --prod option.]"
    "--devServerTarget[Dev server target to run tests against.]"
    "--prod[Shorthand for --configuration=production. When true, sets the build configuration to the production target. By default, the production target is set up in the workspace configuration such that all builds make use of bundling, limited tree-shaking, and also limited dead code elimination.]"
    "--version[Show version number]"
    "--watch[Open the Cypress test runner &amp; autmatically run tests when files are updated]"
    "--browser[The browser to run tests in.]"
    "--ci-build-id[A unique identifier for a run to enable grouping or parallelization.]"
    "--ci-build-id[A unique identifier for a run to enable grouping or parallelization.]"
    "--cypress-config[The path of the Cypress configuration json file.]"
    "--exit[Whether or not the Cypress Test Runner will stay open after running tests in a spec file]"
    "--group[A named group for recorded runs in the Cypress dashboard.]"
    "--headless[Whether or not to open the Cypress application to run the tests. If set to 'true', will run in headless mode.]"
    "--help[Shows a help message for this command in the console.]"
    "--key[The key cypress should use to run tests in parallel/record the run (CI only).]"
    "--parallel[Whether or not Cypress should run its tests in parallel (CI only).]"
    "--record[Whether or not Cypress should record the results of the tests]"
    "--spec[A comma delimited glob string that is provided to the Cypress runner to specify which spec files to run. For example: examples/,actions.spec]"
    "--ts-config[The path of the Cypress tsconfig configuration json file.]"
    "--element-explorer[Start Protractor's Element Explorer for debugging.]"
    "--host[Host to listen on.]"
    "--port[The port to use to serve the application.]"
    "--protractor-config[The name of the Protractor configuration file.]"
    "--specs[Override specs in the protractor config.]"
    "--suite[Override suite in the protractor config.]"
    "--webdriver-update[Try to update webdriver.]"
  )

  _arguments -C -s -S $args ':*'
}

__nx_build_args() {
  local args common_args web_serve_args aopts=()

  args=(
    "--baseHref[Default: /]"
    "--commonChunk[Use a separate bundle containing code used across multiple bundles.]"
    "--budgets[Budget thresholds to ensure parts of your application stay within boundaries which you set.]"
    '--namedChunks'
    "--deployUrl[URL where the application will be deployed.]"
    "--es2015Polyfills[Conditional polyfills loaded in browsers which do not support ES2015.]"
    "--extractCss[Extract css into a .css file]"
    "--extractLicenses[Extract all licenses in a separate file, in the case of production builds only.]"
    "--index[HTML File which will be contain the application]"
    "--main[The name of the main entry-point file.]"
    "--tsConfig[The name of the Typescript configuration file.]"
    "--outputPath[The output path of the generated files.]"
    "--progress[Log progress to the console while building.]"
    "--optimization[Enables optimization of the build output.]"
    "--outputHashing[Default: none]"
    "--scripts[External Scripts which will be included before the main application entry.]"
    '--showCircularDependencies'
    '--sourceMap'
    "--statsJson[Generates a 'stats.json' file which can be analyzed using tools such as: webpack-bundle-analyzer]"
    "--styles[External Styles which will be included with the application]"
    "--subresourceIntegrity[Enables the use of subresource integrity validation.]"
    "--vendorChunk[Default: true]"
    "--verbose[Emits verbose output]"
    "--watch[Enable re-building when files change.]"
    "--help[Show help information]"
    "--version[Show version number]"
    "--assets[List of static application assets.]"
    "--fileReplacements[Replace files with other files in the build.]"
    "--maxWorkers[Number of workers to use for type checking.]"
    "--memoryLimit[Memory limit for type checking service process in MB.]"
    "--polyfills[Polyfills to load before application]"
    "--stylePreprocessorOptions[Options to pass to style preprocessors.]"
    "--webpackConfig[Path to a function which takes a webpack config, some context and returns the resulting webpack config]"
    "--aot[Build using Ahead of Time compilation.]"
    "--buildEventLog[EXPERIMENTAL Output file path for Build Event Protocol events]"
    "--buildOptimizer[Enables @angular-devkit/build-optimizer optimizations when using the --aot option.]"
    "--configuration[A named build target, as specified in the \"configurations\" section of angular.json]"
    "--crossOrigin[Define the crossorigin attribute setting of elements that provide CORS support.]"
    "--deleteOutputPath[Delete the output path before building.]"
    "--deployUrl[URL where files will be deployed.]"
    "--es5BrowserSupport[Enables conditionally loaded ES2015 polyfills.]"
    "--evalSourceMap[Output in-file eval sourcemaps.]"
    "--experimentalRollupPass[Concatenate modules with Rollup before bundling them with Webpack.]"
    "--forkTypeChecker[Run the TypeScript type checker in a forked process.]"
    "--i18nFile[Localization file to use for i18n.]"
    "--i18nFormat[Format of the localization file specified with --i18n-file.]"
    "--i18nLocale[Locale to use for i18n.]"
    "--i18nMissingTranslation[How to handle missing translations for i18n.]"
    "--localize[ngswConfigPath]"
    "--ngswConfigPath[Path to ngsw-config.json.]"
    "--poll[Enable and define the file watching poll time period in milliseconds.]"
    "--polyfills[The full path for the polyfills file, relative to the current workspace.]"
    "--preserveSymlinks[Do not use the real path when resolving modules.]"
    "--rebaseRootRelativeCssUrls[Change root relative URLs in stylesheets to include base HREF and deploy URL.]"
    "--resourcesOutputPath[The path where style resources will be placed, relative to outputPath.]"
    "--serviceWorker[Generates a service worker config for production builds.]"
    "--skipAppShell[Flag to prevent building an app shell.]"
    "--vendorSourceMap[Resolve vendor packages sourcemaps.]"
    "--verbose[Adds more details to output logging.]"
    "--webWorkerTsConfig[TypeScript configuration for Web Worker modules.]"
  )

  _arguments -C -s -S $args ':*'
}

compdef __nx_tool_complete nx
