+++
title = "sh: Relative shell script includes with realpath on FreeBSD"
+++

# sh: Relative shell script includes with realpath on FreeBSD

_Published on December 2, 2023_

_Discuss:
[FreeBSD forum](https://forums.freebsd.org/threads/article-relative-shell-script-includes-with-realpath-on-freebsd.91270/)
\|
[reddit](https://www.reddit.com/r/freebsd/comments/189k7d8/sh_relative_shell_script_includes_with_realpath/)_

_View this article's [example files](/dir?ci=trunk&name=www/sh-relative-shell-script-includes-with-realpath-on-freebsd)_

---

I like writing shell scripts, but one thing that has bugged me for years is that I don't reliably know how to include relative scripts.
I run into three key problems:

1. `. relative/script.sh` depends on the invocation dir.
2. Symlinking the command results in inconsistent command name and location.
3. Almost all internet discussion about shell scripting is about Bash, whereas I'm using [`sh(1)`](https://man.freebsd.org/cgi/man.cgi?sh(1\)) on FreeBSD (aka Bourne shell).

## tl;dr: The Solution

Use `$(dirname $(realpath $0))` in your command files. [`realpath(1)`](https://man.freebsd.org/cgi/man.cgi?realpath(1\))

## Problem 1: The invocation dir matters

_([example files](/dir?ci=trunk&name=www/sh-relative-shell-script-includes-with-realpath-on-freebsd/1-naive-broken))_

The obvious way to include relative files is `. relative/script.sh`.
We have the following file structure:

```
.
├── bin
│   └── hello.sh
└── lib
    └── libhello.sh
```

**bin/hello.sh:**

```sh
#!/bin/sh
. lib/libhello.sh

hello
```

**lib/libhello.sh:**

```sh
hello() {
    echo hello, world
}
```

Running `./bin/hello.sh` works as expected, whereas `cd bin && ./hello.sh` fails:

```
./bin/hello.sh
hello, world
cd bin && ./hello.sh
.: cannot open lib/libhello.sh: No such file or directory
```

We need some way of sourcing relative to the script path, rather than the invocation directory.

## Naive solution: Use `$0` to find the script location

_([example files](/dir?ci=trunk&name=www/sh-relative-shell-script-includes-with-realpath-on-freebsd/2-dirname))_

`$0` returns the name of the invoked command, including any directory prefixing.
We can use it to require relative files:

**bin/hello.sh:**

```sh
#!/bin/sh
LIB=$(dirname $0)/../lib
. $LIB/libhello.sh

hello
```

Now the command succeeds, regardless of which dir we invoke it from:

```
./bin/hello.sh
hello, world
cd bin && ./hello.sh
hello, world
```

However, `$0` is the name of the command passed to the shell - which may not be the actual command file when using symlinks.

## Problem 2: Symlinks make the script name unreliable

_([example files](/dir?ci=trunk&name=www/sh-relative-shell-script-includes-with-realpath-on-freebsd/3-symlink-broken))_

Referencing `$0` works, until we symlink the file.
This is the new file structure:

```
.
├── actual-hello
│   ├── actual-hello.sh
│   └── libhello.sh
└── bin
    └── hello.sh -> ../actual-hello/actual-hello.sh
```

Now running `./bin/hello.sh` tries to include the file relative to `bin/hello.sh`, when it should be relative to `actual-hello/actual-hello.sh`.

Fortunately, FreeBSD gives us [`realpath(1)`](https://man.freebsd.org/cgi/man.cgi?realpath(1\)) to identify the real file referenced by a symlink.

## Solution: Use [`realpath(1)`](https://man.freebsd.org/cgi/man.cgi?realpath(1\)) to source relative to the real file

_([example files](/dir?ci=trunk&name=www/sh-relative-shell-script-includes-with-realpath-on-freebsd/4-symlink-realpath))_

**actual-hello/actual-hello.sh:**

```sh
#!/bin/sh
LIB=$(dirname $(realpath $0))
. $LIB/libhello.sh

hello
```

`$(realpath $0)` returns the path of the real file, so now we can source relative to it.
Our symlink works, regardless the invocation dir:

```
./bin/hello.sh
hello, world
cd bin && ./hello.sh
hello, world
```

## Bonus solution: A lib helper function

_([example files](/dir?ci=trunk&name=www/sh-relative-shell-script-includes-with-realpath-on-freebsd/5-libhelper))_

Now that we know the basic technique, we can define a `BASE` var and write our shell library relative to it.
Here's the file structure:

```
.
├── actual-hello
│   ├── bin
│   │   └── actual-hello.sh
│   └── lib
│       ├── libhello.sh
│       └── libhelper.sh
└── bin
    └── hello.sh -> ../actual-hello/bin/actual-hello.sh
```

**actual-hello/bin/actual-hello.sh:**

```sh
#!/bin/sh
BASE=$(dirname $(realpath $0))/..
. $BASE/lib/libhelper.sh
require_lib "hello"

hello
```

**actual-hello/lib/libhelper.sh:**

```sh
: ${BASE:?}
LIB=$BASE/lib

require_lib() {
    . $LIB/lib${1}.sh
}
```

## Conclusion

It's possible to write [extremely](https://github.com/freebsd/poudriere) [powerful](https://github.com/churchers/vm-bhyve) [tools](https://github.com/BastilleBSD/bastille) using shell scripts, and modularize your code.
Bourne shell doesn't provide a clear mechanism for referencing relative files.
By establishing a command file's base dir, you can reliably reference relative shell scripts.
