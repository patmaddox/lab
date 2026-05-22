---
description: >
  Answer FreeBSD questions using authoritative sources. TRIGGER when
  the user asks about FreeBSD commands, syscalls, configuration,
  system administration, kernel, ports, jails, ZFS, networking, or
  any other FreeBSD topic.
user-invocable: true
allowed-tools: Read, Bash, Grep, Glob, WebFetch, WebSearch, Agent
---

# freebsd

Answer the user's FreeBSD question: $ARGUMENTS

## Source tiers

Consult sources in order of authority. Start with the tier most
likely to answer the question well. Move to the next tier only when
the current one is insufficient.

### Tier 1 - Official reference (prefer these)

- **Local man pages**: `man <page>` on the host. Fastest source.
- **man.freebsd.org**: Broader coverage including ports and other
  versions/OSes. Use ASCII format for clean output.

  URL format:
  ```
  https://man.freebsd.org/cgi/man.cgi?query=<name>&format=ascii
  ```

  Useful parameters:
  - `query` - page name or keyword
  - `sektion` - section number (1-9, omit for all)
  - `apropos=2` - keyword search instead of exact lookup
  - `manpath` - OS version, e.g. `FreeBSD+14.3-RELEASE`,
    `FreeBSD+15.0-RELEASE`. Omit for default.

  Examples:
  ```
  # Exact page
  https://man.freebsd.org/cgi/man.cgi?query=zfs&sektion=8&format=ascii
  # Apropos search
  https://man.freebsd.org/cgi/man.cgi?query=jail&apropos=2&format=ascii
  # Ports man page
  https://man.freebsd.org/cgi/man.cgi?query=nginx&manpath=FreeBSD+14.3-RELEASE+and+Ports&format=ascii
  ```

- **FreeBSD source code**: When the question is about internals or
  behavior not fully documented in man pages. Search or browse at
  https://cgit.freebsd.org/src/

- **FreeBSD Handbook**: https://docs.freebsd.org/en/books/handbook/
  Authoritative for system administration, setup, and best practices.

- **Other official docs**: Porter's Handbook, Developer's Handbook,
  Release Notes, etc. at https://docs.freebsd.org/

### Tier 2 - Community knowledge

Use when the question is about real-world experience, trade-offs,
or edge cases not covered by official docs.

- FreeBSD Forums: https://forums.freebsd.org/
- FreeBSD mailing list archives
- FreeBSD wiki: https://wiki.freebsd.org/
- FreeBSD-related blogs (e.g. vermaden, klara systems)

### Tier 3 - Broader search

Use when tiers 1-2 don't have enough. Cast a wider net.

- Web search for the specific question
- Reddit r/freebsd, r/bsd
- Stack Exchange / Unix & Linux SE

## How to pick the starting tier

- Command syntax, flags, config file format, syscall interface
  -> Tier 1, man pages
- How to set up / configure a subsystem (jails, ZFS, PF, networking)
  -> Tier 1, handbook first, then man pages for specifics
- Kernel internals, driver behavior, source-level questions
  -> Tier 1, source code
- "What do people use for X", "has anyone tried", "pros and cons"
  -> Tier 2
- Obscure errors, version-specific bugs, workarounds
  -> Tier 1 first (release notes, errata), then tier 2-3

## Response guidelines

- Cite sources. Say where the information came from.
- When referencing man pages, include the section: e.g. zfs(8).
- Distinguish between what the docs say and what community
  experience suggests.
- If information conflicts between sources, note the conflict and
  prefer the more authoritative/recent source.
- Be honest about confidence. If a question needs more research
  than you've done, say so.
