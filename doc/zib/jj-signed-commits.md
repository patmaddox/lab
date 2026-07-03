---
title: jj signed commits
---

jj supports signed commits

Workflow:

```sh
jj sign -r <rev>
jj unsign -r <rev>
jj log -r 'mutable() & signed()'
```

I can sign commits using the git commit hash instead of the jj change
id. That way I know that the commit I'm signing hasn't changed from
the one I've viewed.

```shell
jj show <rev>
jj sign -r <commit-id>
```

Example config:

``` toml
[signing]
behavior = "keep"
backend = "ssh"
key = "path/to/key.pub"

[signing.backends.ssh]
program = "/usr/bin/ssh-keygen"
allowed-signers = "path/to/allowed_signers"

[ui]
show-cryptographic-signatures = true
```

1Password CLI tool does not support commit signing - it requires the
desktop application.

One of my goals is to see if Claude has tampered with any
commits. Essentially when I sign a commit, I want to say "I have
looked at this and verified it, it's ready to be published." So it
does double duty: I can even use it just to identify my speculative
commits that aren't ready to ship. If I prompt Claude to do some work,
and it amends commits, I want to know.

The way this works is that I run Claude in a jail where it doesn't
have access to my private key.

jj signed commits have multiple modes:

- drop: always drop the signature when amending the commit; requires
  an explicit sign after each change
- keep: do not automatically sign commits; retain signature on changes
- own: auto-sign any commits that I author
- force: auto sign any commits that I modify

## notes

- `[git] sign-on-push = true` signs everything at push time
- jj doesn't have any mechanism for preventing pushing of unsigned
  commits. Need a wrapper script to enforce it.
- `allowed_signers` email must match `user.email` in jj config,
  otherwise the commits are displayed as `unknown` instead of `good`
