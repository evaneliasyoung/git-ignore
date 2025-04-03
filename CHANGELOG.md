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
