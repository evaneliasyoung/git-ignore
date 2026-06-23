# Changelog

## 0.4.2

> 2026-06-22

- [[`25de3d1`](https://github.com/evaneliasyoung/git-ignore/commit/25de3d1)] refactor(exe): :bulb: remove comemtns related to output file appending
- [[`f10b0b5`](https://github.com/evaneliasyoung/git-ignore/commit/f10b0b5)] fix(exe): :pencil2: fix typo when aliases file is not found
- [[`ab20734`](https://github.com/evaneliasyoung/git-ignore/commit/ab20734)] refactor: :recycle: upgrade to Zig 0.16
- [[`d0cf22e`](https://github.com/evaneliasyoung/git-ignore/commit/d0cf22e)] build(exe): :arrow_up: upgrade all dependencies
- [[`0fb38e1`](https://github.com/evaneliasyoung/git-ignore/commit/0fb38e1)] ci(meta): :art: make the action more readable
- [[`7410294`](https://github.com/evaneliasyoung/git-ignore/commit/7410294)] chore(meta): :see_no_evil: add `zig-pkg` to ignore file, prep for Zig 0.16

## 0.4.1

> 2025-12-07

- [[`99058ab`](https://github.com/evaneliasyoung/git-ignore/commit/99058ab)] build(meta): :construction_worker: bump Zig version to `0.15.2`
- [[`4f9b09e`](https://github.com/evaneliasyoung/git-ignore/commit/4f9b09e)] docs(meta): :memo: add dependencies to README
- [[`f8d00f8`](https://github.com/evaneliasyoung/git-ignore/commit/f8d00f8)] build(meta): :arrow_up: upgrade `zig-clap`
- [[`1eb0db0`](https://github.com/evaneliasyoung/git-ignore/commit/1eb0db0)] build(meta): :arrow_up: upgrade `known_folders`

## 0.4.0

> 2025-09-07

- [[`920fe0a`](https://github.com/evaneliasyoung/git-ignore/commit/920fe0a)] build(meta): :hammer: add nushell script to publish a new version
- [[`2518279`](https://github.com/evaneliasyoung/git-ignore/commit/2518279)] build(meta): upgrade `chameleon`
- [[`98fccb2`](https://github.com/evaneliasyoung/git-ignore/commit/98fccb2)] ci(meta): :construction_worker: use `actions/checkout@v5`
- [[`c0f9825`](https://github.com/evaneliasyoung/git-ignore/commit/c0f9825)] ci(meta): :green_heart: use `mlugg/setup-zig@v2`
- [[`1776270`](https://github.com/evaneliasyoung/git-ignore/commit/1776270)] fix(meta): :pencil2: remove commas from `git ignore alias -a` example
- [[`32ed7ec`](https://github.com/evaneliasyoung/git-ignore/commit/32ed7ec)] ci(meta): :construction_worker: bump CI Zig version to `0.15.1`
- [[`3432493`](https://github.com/evaneliasyoung/git-ignore/commit/3432493)] build(meta): :pushpin: switch to my fork of `chameleon` for PoC
- [[`69cf8e8`](https://github.com/evaneliasyoung/git-ignore/commit/69cf8e8)] refactor(lib): :recycle: address Writergate
- [[`a59e07a`](https://github.com/evaneliasyoung/git-ignore/commit/a59e07a)] refactor(exe): :recycle: address Writergate
- [[`4a2a924`](https://github.com/evaneliasyoung/git-ignore/commit/4a2a924)] refactor(lib): :recycle: use the new `std.json.Stringify` streamer
- [[`098f545`](https://github.com/evaneliasyoung/git-ignore/commit/098f545)] refactor(lib): :recycle: use new `std.http.Client.FetchError` type
- [[`282961f`](https://github.com/evaneliasyoung/git-ignore/commit/282961f)] refactor(lib): :recycle: use new `ArrayList` API
- [[`37f8ff1`](https://github.com/evaneliasyoung/git-ignore/commit/37f8ff1)] refactor(exe): :recycle: use new `ArrayList` API
- [[`d96d2de`](https://github.com/evaneliasyoung/git-ignore/commit/d96d2de)] refactor(exe): :recycle: refactor `clap` code from Writergate
- [[`48011b8`](https://github.com/evaneliasyoung/git-ignore/commit/48011b8)] build(meta): :hammer: update build script per `0.15.1` changes
- [[`fe02273`](https://github.com/evaneliasyoung/git-ignore/commit/fe02273)] build(meta): :arrow_up: upgrade `known_folders`
- [[`c8ebd15`](https://github.com/evaneliasyoung/git-ignore/commit/c8ebd15)] build(meta): :arrow_up: upgrade `clap`
- [[`ad8a5b7`](https://github.com/evaneliasyoung/git-ignore/commit/ad8a5b7)] build(meta): :hammer: add nushell script to generate the `CHANGELOG.md`
- [[`8ab2bf8`](https://github.com/evaneliasyoung/git-ignore/commit/8ab2bf8)] refactor(lib): :recycle: use `std` directly, rather than by assignment
- [[`47193b1`](https://github.com/evaneliasyoung/git-ignore/commit/47193b1)] refactor(exe): :recycle: use `std` directly, rather than by assignment
- [[`91099b1`](https://github.com/evaneliasyoung/git-ignore/commit/91099b1)] style(exe): :art: move imports to top of files
- [[`f22bffa`](https://github.com/evaneliasyoung/git-ignore/commit/f22bffa)] style(lib): :art: move imports to top of files

## 0.3.2

> 2025-07-25

- [[`978417a`](https://github.com/evaneliasyoung/git-ignore/commit/978417a)] build(exe): :arrow_up: upgrade `known_folders`
- [[`85e49f3`](https://github.com/evaneliasyoung/git-ignore/commit/85e49f3)] ci(meta): :construction_worker: output test summary in CI
- [[`44101c7`](https://github.com/evaneliasyoung/git-ignore/commit/44101c7)] ci(meta): :construction_worker: check format in CI
- [[`01cfdac`](https://github.com/evaneliasyoung/git-ignore/commit/01cfdac)] docs(meta): :memo: add installation instructions
- [[`8f97e51`](https://github.com/evaneliasyoung/git-ignore/commit/8f97e51)] docs(meta): :memo: add more alias info to the README

## 0.3.1

> 2025-04-08

- [[`e316618`](https://github.com/evaneliasyoung/git-ignore/commit/e316618)] fix(exe): :mute: remove debug logs

## 0.3.0

> 2025-04-08

- [[`229edd1`](https://github.com/evaneliasyoung/git-ignore/commit/229edd1)] docs(meta): :memo: add `git ignore alias` info to the README
- [[`b9f26da`](https://github.com/evaneliasyoung/git-ignore/commit/b9f26da)] refactor(exe): :loud_sound: write the templates used in a newly added alias
- [[`ca66ba2`](https://github.com/evaneliasyoung/git-ignore/commit/ca66ba2)] refactor(exe): :mute: remove "Found templates file!" message
- [[`1fdd0eb`](https://github.com/evaneliasyoung/git-ignore/commit/1fdd0eb)] feat(exe): :sparkles: add help info for the `git ignore alias` command
- [[`ecc4c93`](https://github.com/evaneliasyoung/git-ignore/commit/ecc4c93)] style(exe): :art: compact `meta` in `main`
- [[`086b1b7`](https://github.com/evaneliasyoung/git-ignore/commit/086b1b7)] style(exe): :art: group `cli` and `lib` imports together
- [[`d52dfa3`](https://github.com/evaneliasyoung/git-ignore/commit/d52dfa3)] test(exe): :white_check_mark: add previously unchecked tests
- [[`2455095`](https://github.com/evaneliasyoung/git-ignore/commit/2455095)] style(exe): :art: use fully qualified `cli.` prefixes even in same file
- [[`5e13d8d`](https://github.com/evaneliasyoung/git-ignore/commit/5e13d8d)] refactor(exe): :recycle: move help related functionality to `cli.help`
- [[`5f7f5d1`](https://github.com/evaneliasyoung/git-ignore/commit/5f7f5d1)] feat(exe): :sparkles: use ignore aliases if they're found
- [[`e2aa45c`](https://github.com/evaneliasyoung/git-ignore/commit/e2aa45c)] fix(lib): :bug: use built-in hash map until return from `cloneFromJSON`
- [[`3d91a30`](https://github.com/evaneliasyoung/git-ignore/commit/3d91a30)] fix(exe): :bug: close file handler when loading cache
- [[`f157af7`](https://github.com/evaneliasyoung/git-ignore/commit/f157af7)] feat(exe): :sparkles: add `git ignore alias` functionality
- [[`bdb41a1`](https://github.com/evaneliasyoung/git-ignore/commit/bdb41a1)] fix(lib): :bug: fix newly placed aliases triggering an invalid free
- [[`e28e762`](https://github.com/evaneliasyoung/git-ignore/commit/e28e762)] feat(lib): :sparkles: add `IgnoreAliases`
- [[`ce8c713`](https://github.com/evaneliasyoung/git-ignore/commit/ce8c713)] refactor(lib): :art: add `sortStringSlice` helper function to sort strings
- [[`ac6d801`](https://github.com/evaneliasyoung/git-ignore/commit/ac6d801)] feat(lib): :sparkles: add `getAliasesPath`
- [[`2db8abe`](https://github.com/evaneliasyoung/git-ignore/commit/2db8abe)] feat(exe): :construction: add preliminary support for `git ignore alias`
- [[`05b7712`](https://github.com/evaneliasyoung/git-ignore/commit/05b7712)] refactor(exe): :recycle: simplify `cli.main.invoke` branching
- [[`6229489`](https://github.com/evaneliasyoung/git-ignore/commit/6229489)] refactor(exe): :recycle: prettier help command
- [[`0c68b0d`](https://github.com/evaneliasyoung/git-ignore/commit/0c68b0d)] refactor(exe): :recycle: move main `cli.main` code to `cli.main.invoke`

## 0.2.2

> 2025-04-06

- [[`2e2041f`](https://github.com/evaneliasyoung/git-ignore/commit/2e2041f)] ci(meta): :green_heart: fix tag push detection for build step

## 0.2.1

> 2025-04-06

- [[`6e4d52b`](https://github.com/evaneliasyoung/git-ignore/commit/6e4d52b)] ci(meta): :green_heart: run CI on pushing tags

## 0.2.0

> 2025-04-06

- [[`4c57593`](https://github.com/evaneliasyoung/git-ignore/commit/4c57593)] refactor(exe): :recycle: don't silently fail on `cli.print.err` errors
- [[`3a194ce`](https://github.com/evaneliasyoung/git-ignore/commit/3a194ce)] ci(meta): :construction_worker: remove write permissions from `build` step
- [[`3806512`](https://github.com/evaneliasyoung/git-ignore/commit/3806512)] ci(meta): :construction_worker: only run `build` and `release` on version tag
- [[`10f2482`](https://github.com/evaneliasyoung/git-ignore/commit/10f2482)] chore(meta): :memo: add issue templates
- [[`745f084`](https://github.com/evaneliasyoung/git-ignore/commit/745f084)] refactor(exe): :speech_balloon: make version output one line
- [[`1076c5f`](https://github.com/evaneliasyoung/git-ignore/commit/1076c5f)] style(exe): :coffin: remove unused imports
- [[`d23f6da`](https://github.com/evaneliasyoung/git-ignore/commit/d23f6da)] refactor(exe): :art: move version writing into `cli.main`
- [[`bd6f886`](https://github.com/evaneliasyoung/git-ignore/commit/bd6f886)] fix(exe): :adhesive_bandage: restore `help` functionality
- [[`405c68e`](https://github.com/evaneliasyoung/git-ignore/commit/405c68e)] refactor(exe): :art: move more argument handling into `cli.main`
- [[`eee2be3`](https://github.com/evaneliasyoung/git-ignore/commit/eee2be3)] refactor(exe): :recycle: add `--version` flag verbosity levels (1, 2, and 3)
- [[`d53cb14`](https://github.com/evaneliasyoung/git-ignore/commit/d53cb14)] feat(exe): :sparkles: write base help and exit if no command or flag specified
- [[`06f569c`](https://github.com/evaneliasyoung/git-ignore/commit/06f569c)] feat(exe): :sparkles: add help command
- [[`004611b`](https://github.com/evaneliasyoung/git-ignore/commit/004611b)] feat(exe): :sparkles: add version flag to retrieve `git-ignore` version
- [[`ef45daf`](https://github.com/evaneliasyoung/git-ignore/commit/ef45daf)] feat(lib): :sparkles: add version to library through build
- [[`9dc47f6`](https://github.com/evaneliasyoung/git-ignore/commit/9dc47f6)] ci(meta): :green_heart: change artifact names
- [[`0009add`](https://github.com/evaneliasyoung/git-ignore/commit/0009add)] ci(meta): :construction_worker: add release generation
- [[`652dd8f`](https://github.com/evaneliasyoung/git-ignore/commit/652dd8f)] ci(meta): :green_heart: use correct build path
- [[`bcc8d0f`](https://github.com/evaneliasyoung/git-ignore/commit/bcc8d0f)] ci(meta): :construction_worker: add build step to CI
- [[`ce6b6d8`](https://github.com/evaneliasyoung/git-ignore/commit/ce6b6d8)] ci(meta): :construction_worker: rename `check` job to `test`
- [[`b9f6b00`](https://github.com/evaneliasyoung/git-ignore/commit/b9f6b00)] build(meta): :wrench: add `exe_name` build parameter for executable name
- [[`f7050ba`](https://github.com/evaneliasyoung/git-ignore/commit/f7050ba)] chore(meta): :memo: make commit ids code blocks in `CHANGELOG.md`

## 0.1.1

> 2025-04-03

- [[`d874abf`](https://github.com/evaneliasyoung/git-ignore/commit/d874abf)] refactor(exe): :label: add error scope to `cli.fs.getCachePath`
- [[`2715c04`](https://github.com/evaneliasyoung/git-ignore/commit/2715c04)] refactor(lib): :label: add error scopes
- [[`1d9124b`](https://github.com/evaneliasyoung/git-ignore/commit/1d9124b)] fix(lib): :bug: resolve #1

## 0.1.0

> 2025-04-03

- [[`b02a25f`](https://github.com/evaneliasyoung/git-ignore/commit/b02a25f)] ci(meta): :construction_worker: add CI pipeline
- [[`0723163`](https://github.com/evaneliasyoung/git-ignore/commit/0723163)] docs(meta): :memo: update `README`
- [[`e0417f5`](https://github.com/evaneliasyoung/git-ignore/commit/e0417f5)] feat(exe): :sparkles: write matching templates
- [[`6242bf2`](https://github.com/evaneliasyoung/git-ignore/commit/6242bf2)] feat(lib): :sparkles: add `writeTemplates` to `IgnoreFiles`
- [[`180ce3d`](https://github.com/evaneliasyoung/git-ignore/commit/180ce3d)] feat(exe): :sparkles: list matching template names
- [[`dc6128b`](https://github.com/evaneliasyoung/git-ignore/commit/dc6128b)] feat(lib): :sparkles: add `writeTemplateNames` to `IgnoreFiles`
- [[`eb29482`](https://github.com/evaneliasyoung/git-ignore/commit/eb29482)] fix(lib): :bug: fix `parseFromReader` memory leak
- [[`3b4635a`](https://github.com/evaneliasyoung/git-ignore/commit/3b4635a)] feat(exe): :sparkles: use chosen output paradigm (stdout or `.gitignore`)
- [[`5ac9fea`](https://github.com/evaneliasyoung/git-ignore/commit/5ac9fea)] refactor(exe): :art: move `MainArguments` and `SubCommands` to `cli.main` module
- [[`750ce89`](https://github.com/evaneliasyoung/git-ignore/commit/750ce89)] feat(exe): :sparkles: add ignore update logic
- [[`04ee710`](https://github.com/evaneliasyoung/git-ignore/commit/04ee710)] fix(lib): :bug: fix `pipeRequestToFile` memory scope
- [[`746d5ed`](https://github.com/evaneliasyoung/git-ignore/commit/746d5ed)] feat(exe): :sparkles: add `cli.fs` helper module
- [[`17b5e12`](https://github.com/evaneliasyoung/git-ignore/commit/17b5e12)] fix(lib): :bug: fix memory scope
- [[`a66170d`](https://github.com/evaneliasyoung/git-ignore/commit/a66170d)] feat(exe): :construction: add basic CLI
- [[`8563977`](https://github.com/evaneliasyoung/git-ignore/commit/8563977)] refactor(lib): :fire: remove filler from `root.zig`
- [[`0fec4cd`](https://github.com/evaneliasyoung/git-ignore/commit/0fec4cd)] style(lib): :label: add error scopes
- [[`4906412`](https://github.com/evaneliasyoung/git-ignore/commit/4906412)] style(lib): :fire: import only standard modules, not individual structures
- [[`f80a818`](https://github.com/evaneliasyoung/git-ignore/commit/f80a818)] feat(lib): :sparkles: add `parseFromReader` to `IgnoreFiles`
- [[`b2f02b1`](https://github.com/evaneliasyoung/git-ignore/commit/b2f02b1)] feat(lib): :sparkles: add `IgnoreSite` structure
- [[`8b056d5`](https://github.com/evaneliasyoung/git-ignore/commit/8b056d5)] feat(exe): :sparkles: add stderr print utility functions for Chameleon
- [[`588b3e7`](https://github.com/evaneliasyoung/git-ignore/commit/588b3e7)] feat(lib): :sparkles: add `IgnoreFiles`
- [[`89a614a`](https://github.com/evaneliasyoung/git-ignore/commit/89a614a)] feat(lib): :sparkles: add `IgnoreFile` structure
- [[`1f428d4`](https://github.com/evaneliasyoung/git-ignore/commit/1f428d4)] chore(meta): :wrench: add Conventional Commits scopes for VS Code
- [[`f4dcd35`](https://github.com/evaneliasyoung/git-ignore/commit/f4dcd35)] build(exe): :heavy_plus_sign: add `chameleon`
- [[`c28852b`](https://github.com/evaneliasyoung/git-ignore/commit/c28852b)] build(exe): :heavy_plus_sign: add `known_folders`
- [[`76124da`](https://github.com/evaneliasyoung/git-ignore/commit/76124da)] build(exe): :heavy_plus_sign: add `clap`
- [[`8a74fb0`](https://github.com/evaneliasyoung/git-ignore/commit/8a74fb0)] build(meta): :stethoscope: ensure minimum Zig version
- [[`a4e84f1`](https://github.com/evaneliasyoung/git-ignore/commit/a4e84f1)] chore(meta): :tada: add Zig template
- [[`3557eca`](https://github.com/evaneliasyoung/git-ignore/commit/3557eca)] chore(meta): :wrench: add `.gitattributes`
- [[`9784da9`](https://github.com/evaneliasyoung/git-ignore/commit/9784da9)] chore(meta): :see_no_evil: add `.gitignore`
- [[`e03542e`](https://github.com/evaneliasyoung/git-ignore/commit/e03542e)] chore(meta): :page_facing_up: add `LICENSE`
- [[`864723c`](https://github.com/evaneliasyoung/git-ignore/commit/864723c)] chore(meta): :memo: add `README.md`
