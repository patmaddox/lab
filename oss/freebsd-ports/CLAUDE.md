# freebsd-ports code review

Review code and commits to help prepare them for submission to the
freebsd ports tree.

Use `jj` instead of `git` to view commit messages. You may use git
commands if they are faster for querying history.

The working copy is in `default.jj` and is a separate repository from
`lab.jj`, even though it is nested below it.

- do NOT modify commit messages or code. Simply give me a list of
  issues to address.
- all feedback should be aligned with freebsd-ports rules and
  conventions
- My pending commits are identified by jj alias `diffs`. You can find
  them e.g. `jj log -r diffs`. You do not need to review any other
  commits or ports. You may look at other commits or ports to gather
  information that assists with the code review.
- Concise code review report, one per line. Write the results to
  screen, as well as to code-review.txt in `lab.jj/oss/freebsd-ports`.
- Only review commits that are missing from the report, or failed the
  last code review. Do not review commits that are marked as passing
  in the report. Always display the entire report.
- Always check to see if the report has been modified before doing
  another round of review. I may edit it offline.
- I can override your code review. If I tell you that something is
  good or bad, respect it.
- If I tell you to restart the code review, you MUST:
    - delete the report file
	- forget about any reviews you've done
	- code review as if from scratch
- You MUST NOT review any commits that have NOSUBMIT in the description

## code review: code

- use `portclippy` to determine formatting issues, e.g. `portclippy editors/emacs`
- use `portlint` to identify other formatting issues. It needs to know
  the PORTSDIR e.g. `PORTSDIR=$(pwd) portlint -C editors/emacs`.

## code review: commits

- All commits MUST have a "PR: <number>" trailer
- All commits MUST have subject line of: "<origin>/<portname>: <message>"
- All commits MUST have a meaningful body
- Message length is max 72 cols
- Ignore "Change-ID" trailer - that is used for gerrit
- New ports
    - COMMENT as the subject message (might be edited / truncated for
      space)
    - pkg-descr as the body (might be edited / truncated for space)
- Updated ports
    - subject message: "Update <old-version> => <new-version>"
	- SHOULD contain a changelog with link
	- MAY have multiple changelogs if it skips versions

Example new port:

```
editors/emacs: GNU Emacs Editor

This is an editor that everyone loves.
Well, most everyone.
```

Example port update:

```
editors/emacs: Update 1.0 => 1.1

Changelog: http://emacs.org
```

Example port update (skip versions)

```
editors/emacs: Update 1.0 => 1.2

Changelogs:
http://emacs.org/1.1
http://emacs.org/1.2
```

## code review: report format

Template: `status | change_id (colorized) | commit message | issue,<issue>,<...>` (colorized)

Example:

```
=== PASSING ===
+ | abc123 | editors/foo: some update
+ | def456 | editors/bar: another update

=== FAILING ===
- | cb1ido | editors/chicken: something something | pr,clippy,lint
- | adf879 | editors/another: still updating | pr,lint
```

Colorize good change IDs as green, bad change IDs as red. Also
colorize issue indicator as red.

Issue indicators:

| id        | reason                                          |
|-----------|-------------------------------------------------|
| pr        | Missing PR trailer                              |
| clippy    | failed portclippy                               |
| lint      | failed portlint                                 |
| changelog | missing / incomplete changelog                  |
| subject   | Doesn't match expected format for new / updates |
| body      | Doesn't match expected format for new / updates |
| len       | Message subject or body exceeds 72 columns      |

# SCRIPTS

## Check commit message line lengths

```sh
#!/bin/sh
# Check commit message line lengths
# Subject and body lines must be ≤72 chars

for id in "$@"; do
  printf "\n=== %s ===\n" "$id"
  jj log -r "$id" --no-graph -T 'description.first_line() ++ " | len=" ++ description.first_line().len()'
  printf "Body:\n"
  jj show -s "$id" 2>&1 | awk '
    /^    / {
      line = substr($0, 5)
      if (line !~ /^(PR:|Change-Id:|Approved|Reported|Obtained|Changelog)/) {
        len = length(line)
        if (len > 72) {
          printf "  OVER: %d | %s\n", len, substr(line, 1, 60)
        } else if (len > 0) {
          printf "  OK: %d\n", len
        }
      }
    }
  '
done
```
