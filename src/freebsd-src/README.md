# freebsd-src

Goals:

- build, package, distribute multiple trees
- track my contributions

Commands:

| `just ccache`         | Show ccache status                                    |
| `just ccache-watch`   | Refresh ccache stats every {wait} seconds             |
| `just clone`          | Clone the git repository                              |
| `just build`          | DWIM build - from scratch if needed, fast if possible |
| `just clean`          | Clean everything with the config (cleanworld)         |
| `just release`        | Build release tarballs (base.txz kernel.txz etc)      |
| `just clean-release`  | Clean release tarballs                                |
| `just objdir`         | print .OBJDIR for the build                           |
| `just objdir-release` | print .OBJDIR/release for the build                   |
| `just command-table`  | Print the command list in markdown table format       |

## Config

Builds are configured via config files and built with `scripts/build.sh`.
`just` provides convenience wrappers.

Most configs simply need to specify `TREE`, which is a source code checkout.
Configs that use a `CURRENT` tree may want to set `KERNCONF=GENERIC-NODEBUG`.
