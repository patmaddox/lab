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

See top-level `CLAUDE.md` for general version control rules.

The commit prefix for this directory is `[CLAUDE] emacs: ` (e.g. `[CLAUDE] emacs: Add org-capture template for notes`). Use the actual task name, not generic labels like "parent task".

## Vendored Code

Third-party code lives in `vendor/`, one subdirectory per package.

- **Import commits** contain an exact copy of upstream — no local
  modifications. One commit per import/update.
- **Local patches** go in separate commits on top of the import.
  Never squash local changes into the import commit.
- **Updating**: import the new upstream version (replaces the
  directory). Then create a new commit that re-applies any local
  patches still needed. The commit message should list which
  local changes were re-applied and which were dropped (e.g.
  because upstream incorporated the fix). Reference the original
  patch commits by git commit hash (stable, unlike change IDs).

  Example commit message:
  ```
  [CLAUDE] emacs: Re-apply local patches to claude-code.el

  Updated claude-code.el from upstream v2.1.0.

  Re-applied:
  - Accept absolute paths in claude-code-program (a1b2c3d)

  Dropped:
  - Fix buffer name uniqueness (d4e5f6a) — fixed upstream in v2.0.5
  ```

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
