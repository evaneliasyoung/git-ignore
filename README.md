# git-ignore

**Create .gitignores with templates from [gitignore.io](https://www.gitignore.io/)**

- **Simple**: `git ignore node` to print the `node` template.
- **Offline first**: Automatically caches templates for offline support.
- **Aliases**: Create aliases for commonly combined templates.

## What and why

Tired of visiting [gitignore.io](https://www.gitignore.io/) to get templates for your `.gitignore` all the time?
I was.
So I [automated](https://xkcd.com/1319/) [it](https://xkcd.com/1205/).

`git ignore` allows you to easily and quickly get all the available templates from [gitignore.io](https://www.gitignore.io/), even while offline.
You can also define your own aliases for common combinations of templates.

## Installation

Currently, the only way to install this is to download the [latest release binary](https://github.com/evaneliasyoung/git-ignore/releases) for your platform and operating system.
To use this as demonstrated in the rest of this file, you'll need to assign an alias in your global `.gitconfig` file (usually `~/.gitconfig`).

```ini
[alias]
    ignore = !"path-to-binary"
```

## Usage

**NOTE:** Similar to the `nix-search` command, this program prints a message to `stderr` about using cached results.
This does _not_ interfere with piping and is purely informational.
You can also optionally use `--write` to automatically write the resulting ignores to `$CWD/.gitignore` instead of piping.

### Updating templates

To download and cache all available templates, use `--update`.
This can also be used in combination with any of the other flags/arguments, or be run as a standalone flag.

```sh
$ git ignore -u
info: Update successful!
```

### List templates

To list all the available templates:

```sh
$ git ignore --list
1c
1c-bitrix
a-frame
actionscript
ada
[...]
zukencr8000
```

The `--list` option is also used to search for templates matching your input. The
matching is done by doing `template.contains(phrase)`, so searching for `intellij`
will list all templates containing that phrase. You can also search for multiple
templates at once:

```sh
$ git ignore -l zig visualstudio

openframeworks+visualstudio
visualstudio
visualstudiocode
zig
```

### Printing templates

Once you've found your templates, you can print them by omitting `-l|--list`. **Note:**
listing and searching for templates is inexact, but printing them requires exact matches.

```sh
$ git ignore zig visualstudiocode

# Created by https://gitignore.io/api/visualstudiocode,zig
# Edit at https://gitignore.io/?templates=visualstudiocode,zig

### VisualStudioCode ###

[...]

### Zig ###

[...]

# End of https://gitignore.io/api/visualstudiocode,zig
```

### Aliases

Aliases are a way to combine common combinations of templates.
If you find yourself always using `node` and `svelte` in your frontend projects, you can create an alias for it for ease of access.
Aliases have higher priority than templates from [gitignore.io](https://www.gitignore.io/), so an alias named `node` will be used instead of the template.

#### Listing

```sh
$ git ignore alias -l
zig => [linux, macos, visualstudiocode, windows, zig]
```

#### Adding

```sh
$ git ignore alias -a node node, svelte, visualstudiocode
info: Added alias 'node' of [node, svelte, visualstudiocode]
```

#### Removing

```sh
$ git ignore alias -r node
info: Removed alias 'node'
```
