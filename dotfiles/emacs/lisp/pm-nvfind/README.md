# pm-nvfind

nvALT-style full-text search for emacs using ripgrep.
Searching "foo bar" finds files containing both "foo" and "bar" anywhere in the file, in any order.

## Usage

### Basic search

`M-x pm-nvfind` prompts for a query and searches the default scope.
Type a query and press enter to see matching files.
Select a file to open it, or press `C-r` to refine your query.

Refinement is iterative - narrow results by adding words, then select when ready.

### Search scopes

pm-nvfind supports named search scopes - predefined directories to search.
Configure them via `pm-nvfind-scopes`:

```elisp
(setq pm-nvfind-scopes
      '(("docs"    . ("~/lab.jj/doc"))
        ("notes"   . ("~/lab.jj/notes"))
        ("infra"   . ("~/lab.jj/infra"))
        ("man"     . ("~/lab.jj/oss/freebsd-src/main.jj/share/man"))
        ("all"     . ("~/lab.jj/doc" "~/lab.jj/notes" "~/lab.jj/infra"))))
```

`M-x pm-nvfind-scope` prompts for scope names (with completion), then a query.
Select multiple scopes to search their union - directories are deduplicated.

### Default scope

Set `pm-nvfind-default-scope` to control what `M-x pm-nvfind` searches:

```elisp
(setq pm-nvfind-default-scope "docs")
```

This can also be a list of scope names:

```elisp
(setq pm-nvfind-default-scope '("docs" "notes"))
```

### Search a specific directory

`M-x pm-nvfind-in` prompts for a directory, then a query.
Useful for one-off searches outside your configured scopes.

## Dependencies

- ripgrep (`rg`)
- [consult](https://github.com/minad/consult) (optional) - file preview during result selection

## How it works

Splits the query on whitespace and chains ripgrep calls:

```sh
rg -l word1 dir1 dir2 | xargs rg -l word2 | xargs rg -l word3
```

Each stage narrows the file list.
Only files containing every word survive.
