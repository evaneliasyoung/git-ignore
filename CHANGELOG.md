# Changelog

## 0.2.0

> 2025-04-06

This is a small update, which mainly adds supporting help and version options for the CLI.

- [[`4c57593`](https://github.com/evaneliasyoung/git-ignore/commit/4c57593)] - refactor(exe): :recycle: don't silently fail on `cli.print.err` errors
- [[`3a194ce`](https://github.com/evaneliasyoung/git-ignore/commit/3a194ce)] - ci(meta): :construction_worker: remove write permissions from `build` step
- [[`3806512`](https://github.com/evaneliasyoung/git-ignore/commit/3806512)] - ci(meta): :construction_worker: only run `build` and `release` on version tag
- [[`10f2482`](https://github.com/evaneliasyoung/git-ignore/commit/10f2482)] - chore(meta): :memo: add issue templates
- [[`745f084`](https://github.com/evaneliasyoung/git-ignore/commit/745f084)] - refactor(exe): :speech_balloon: make version output one line
- [[`1076c5f`](https://github.com/evaneliasyoung/git-ignore/commit/1076c5f)] - style(exe): :coffin: remove unused imports
- [[`d23f6da`](https://github.com/evaneliasyoung/git-ignore/commit/d23f6da)] - refactor(exe): :art: move version writing into `cli.main`
- [[`bd6f886`](https://github.com/evaneliasyoung/git-ignore/commit/bd6f886)] - fix(exe): :adhesive_bandage: restore `help` functionality
- [[`405c68e`](https://github.com/evaneliasyoung/git-ignore/commit/405c68e)] - refactor(exe): :art: move more argument handling into `cli.main`
- [[`eee2be3`](https://github.com/evaneliasyoung/git-ignore/commit/eee2be3)] - refactor(exe): :recycle: add `--version` flag verbosity levels (1, 2, and 3)
- [[`d53cb14`](https://github.com/evaneliasyoung/git-ignore/commit/d53cb14)] - feat(exe): :sparkles: write base help and exit if no command or flag specified
- [[`06f569c`](https://github.com/evaneliasyoung/git-ignore/commit/06f569c)] - feat(exe): :sparkles: add help command
- [[`004611b`](https://github.com/evaneliasyoung/git-ignore/commit/004611b)] - feat(exe): :sparkles: add version flag to retrieve `git-ignore` version
- [[`ef45daf`](https://github.com/evaneliasyoung/git-ignore/commit/ef45daf)] - feat(lib): :sparkles: add version to library through build
- [[`9dc47f6`](https://github.com/evaneliasyoung/git-ignore/commit/9dc47f6)] - ci(meta): :green_heart: change artifact names
- [[`0009add`](https://github.com/evaneliasyoung/git-ignore/commit/0009add)] - ci(meta): :construction_worker: add release generation
- [[`652dd8f`](https://github.com/evaneliasyoung/git-ignore/commit/652dd8f)] - ci(meta): :green_heart: use correct build path
- [[`bcc8d0f`](https://github.com/evaneliasyoung/git-ignore/commit/bcc8d0f)] - ci(meta): :construction_worker: add build step to CI
- [[`ce6b6d8`](https://github.com/evaneliasyoung/git-ignore/commit/ce6b6d8)] - ci(meta): :construction_worker: rename `check` job to `test`
- [[`b9f6b00`](https://github.com/evaneliasyoung/git-ignore/commit/b9f6b00)] - build(meta): :wrench: add `exe_name` build parameter for executable name
- [[`f7050ba`](https://github.com/evaneliasyoung/git-ignore/commit/f7050ba)] - chore(meta): :memo: make commit ids code blocks in `CHANGELOG.md`

## 0.1.1

> 2025-04-03

This is a hotfix release, which fixes a memory access issue when using `-Doptimize=ReleaseSafe`.

- [[`d874abf`](https://github.com/evaneliasyoung/git-ignore/commit/d874abf)] refactor(exe): :label: add error scope to `cli.fs.getCachePath`
- [[`2715c04`](https://github.com/evaneliasyoung/git-ignore/commit/2715c04)] refactor(lib): :label: add error scopes
- [[`1d9124b`](https://github.com/evaneliasyoung/git-ignore/commit/1d9124b)] fix(lib): :bug: resolve #1

## 0.1.0

> 2025-04-03

This is the initial release of `git-ignore`, a tool to list and use templates on www.gitignore.io.

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
