# emacs config

Emacs (X, not terminal) on FreeBSD. Dependencies from ports, not emacs package managers.

When the prompt is "dev", follow the development process defined in @spec.org

## File Structure

- `init.el` - main config
- `lisp/freebsd-style-ts.el` - FreeBSD style(9) for C and shell
- `lisp/pm-nirvana.el` - org-mode extensions
- `patmaddox-emacs.pkg.do` - redo script for package building
- `Justfile` - build/test/install commands

## Commands

- `just install` - build and install package to ~/.emacs.d/
- `just test` - build package and run kyua tests
- `just demo [file]` - install to tmpdir and launch emacs

## Version Control

Use `jj commit -m` to commit after successful work. Do not commit after errors.

Commit message style follows FreeBSD conventions:
- Subject line: ~50 chars, imperative mood, prefixed with "[CLAUDE] emacs: " (e.g. "[CLAUDE] emacs: Add org-capture template for notes")
- Wrap body at 72 characters
- Explain why, not what — the diff shows what changed
- Reference: https://docs.freebsd.org/en/articles/committers-guide/#commit-log-message

## FreeBSD Style

File: `lisp/freebsd-style-ts.el`

Both C and shell use:
- Primary indent: 8 spaces (1 tab)
- Continuation indent: 4 spaces

C uses tree-sitter indent rules extending the built-in BSD style.
Shell uses SMIE (bash-ts-mode doesn't have tree-sitter indentation).

## Tree-sitter Tips

- Debug indentation: `(setq treesit--indent-verbose t)`
- Explore AST: `M-x treesit-explore-mode`
- Grammars from port: `textproc/tree-sitter-grammars`
