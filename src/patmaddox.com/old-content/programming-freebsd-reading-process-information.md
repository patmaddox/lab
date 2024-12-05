+++
title = "First steps in programming FreeBSD: Reading process information"
+++

# First steps in programming FreeBSD: Reading process information

_Published on December 13, 2023_

_Discuss:
[FreeBSD forum](https://forums.freebsd.org/threads/article-first-steps-in-programming-freebsd-reading-process-information.91463/)
\|
[reddit](https://www.reddit.com/r/freebsd/comments/18i0hxz/first_steps_in_programming_freebsd_reading/)_

_View this article's [example files](/dir?ci=trunk&name=www/programming-freebsd-reading-process-information)_

---

I occasionally come across people on the FreeBSD forum and discord asking, "How do I get started developing on FreeBSD?"
I have wondered the same thing.
In this post, I'll share my experience dipping my toes in the water of FreeBSD development for the first time.

My [programming objective](#simple-c-program) for this post is to read process information - effectively, a stripped-down version of [ps(1)](https://man.freebsd.org/cgi/man.cgi?query=ps&sektion=1).
I will show you how I found the FreeBSD-specific information needed to do that.

## What do I mean by "FreeBSD development?"

By "FreeBSD development", I mean developing anything that could plausibly live in the [freebsd-src tree](https://cgit.freebsd.org/src/tree/):

- the kernel (including modules)
- user space programs
- libraries
- supporting infrastructure (e.g. [release tools](https://cgit.freebsd.org/src/tree/release))

Broadly speaking, I would classify the first three as "systems programming" - something I have no experience with, and which I would like to learn more about.

## What makes "FreeBSD development" different from "application development?"

It depends on your background.
For context, I've been programming professionally for 20 years.
I started with C++ and Java, and then moved primarily to web development.
I used Ruby for ~15 years, and have worked mostly with Elixir for the past several years.

The first thing I notice: the FreeBSD development ecosystem looks and feels very different from what I'm used to, especially when it comes to documentation.

Elixir has a package repo called [Hex](https://hex.pm), which lists [every Elixir package](https://hex.pm/packages) you might want to install, and a culture of high-quality, comprehensive documentation.
Each library typically comes with a [complete API reference](https://hexdocs.pm/jason/Jason.html), and [guides for how to use it](https://hexdocs.pm/jason/readme.html).

FreeBSD, on the other hand, has [man pages](https://man.freebsd.org/cgi/man.cgi).
Compared to Elixir docs, man pages tend to be fragmented and inconsistent.
Whereas some libraries have a single man page documenting all their functions (e.g. [libxo(3)](https://man.freebsd.org/cgi/man.cgi?query=libxo&sektion=3)), others document each function in separate man pages (e.g. there is no man page for [libfetch(3)](https://man.freebsd.org/cgi/man.cgi?query=libfetch&sektion=3), but there is one for its function [fetch(3)](https://man.freebsd.org/cgi/man.cgi?query=fetch&sektion=3)).
This means that, even if you know a library exists, you might not find its documentation right away using [man(1)](https://man.freebsd.org/cgi/man.cgi?query=man&sektion=1) or [apropos(1)](https://man.freebsd.org/cgi/man.cgi?query=apropos&sektion=1).

There is good news though: we have _all_ of the source code.
This gives us plenty of useful working examples, and can point the way to relevant documentation.

Before we look at how to find useful information, I want to take a brief look at the FreeBSD architecture from a developer's perspective.

## FreeBSD architecture for developers

If you don't know, the FreeBSD operating system is essentially divided into two parts: the kernel, and user space.
The kernel is a program that runs in privileged mode, and provides critical services: process management, memory management, and i/o.
User space programs are what you think of as "normal" programs, and make requests to the kernel for resources.

FreeBSD source code is roughly organized in the following layers, from higher-level to lower-level:

- programs
- libraries
- syscalls

In other words, programs typically call libraries, which invoke syscalls.
Often times, there is a collection of program / library / syscalls to work with the same underlying concept.
For example, [jail(8)](https://man.freebsd.org/cgi/man.cgi?query=jail&sektion=8) calls [jail(3)](https://man.freebsd.org/cgi/man.cgi?query=jail&sektion=3) which calls [jail(2)](https://man.freebsd.org/cgi/man.cgi?query=jail&sektion=2).

We can use this general architecture to our advantage, by starting at a promising place and then exploring outward from there.

I have found three main sources of information:

- man pages
- library source code
- program source code

Let's look at an example of how to explore them to find helpful information.

## A simple objective: Reading process information

Right, time to get down to brass tacks and write some code.
Where to start?

Well, I know two things: I'm interested in processes, and there are [existing](https://man.freebsd.org/cgi/man.cgi?query=ps&sektion=1) [utilities](https://man.freebsd.org/cgi/man.cgi?query=procstat&sektion=1) that report process information.

### Searching the man pages

I'll start with an [apropos search for "process"](https://man.freebsd.org/cgi/man.cgi?query=process&apropos=1&manpath=FreeBSD+14.0-RELEASE) and see if anything looks promising.
I'm not familiar with the results, but I know generally to focus on [section 3](https://man.freebsd.org/cgi/man.cgi?query=intro&sektion=3) items.
A few stand out to me:

- [kinfo_getallproc(3)](https://man.freebsd.org/cgi/man.cgi?query=kinfo_getallproc&sektion=3) - the description sounds promising: "function for getting process information	of all processes from kernel"
- [kvm_getprocs(3)](https://man.freebsd.org/cgi/man.cgi?query=kvm_getprocs&sektion=3) - I have no idea what "kvm" is, but it also sounds promising: "access user process state"
- [procstat_getprocs(3)](https://man.freebsd.org/cgi/man.cgi?query=procstat_getprocs&sektion=3) - mainly because I know that [procstat(1)](https://man.freebsd.org/cgi/man.cgi?query=procstat&sektion=1) exists, and probably calls this library

### Corroborating with program code

Does [ps(1)](https://man.freebsd.org/cgi/man.cgi?query=ps&sektion=1) use either of these?
Let's take a look...

Yep! A search of [ps.c](https://cgit.freebsd.org/src/tree/bin/ps/ps.c) for `kvm_getprocs` [reveals it being used](https://cgit.freebsd.org/src/tree/bin/ps/ps.c#n535).

Now we need to figure out what it's doing... but we're in a better spot, able to do more focused research.

Looking at [kvm_getprocs(3)](https://man.freebsd.org/cgi/man.cgi?query=kvm_getprocs&sektion=3), we see that we need to pass a `kvm_t` struct as the first argument.
I have no idea what that is, and [apropos doesn't help](https://man.freebsd.org/cgi/man.cgi?query=kvm_t&apropos=1).

[A bit further up](https://cgit.freebsd.org/src/tree/bin/ps/ps.c#n468), we see that a call to [kvm_openfiles(3)](https://man.freebsd.org/cgi/man.cgi?query=kvm_openfiles&sektion=3) initializes the struct.
Later on, we see `ps(1)` [accessing the process information from the struct](https://cgit.freebsd.org/src/tree/bin/ps/ps.c#n561).
What other data does the struct have?
A search for `kinfo_proc` leads me to [sys/sys/user.h](https://cgit.freebsd.org/src/tree/sys/sys/user.h#n118) which defines and documents the struct.
Based on that, I'm pretty sure that [`ki_pid`](https://cgit.freebsd.org/src/tree/sys/sys/user.h#n129) and [`ki_comm`](https://cgit.freebsd.org/src/tree/sys/sys/user.h#n179) are the properties I'm looking for.

### Interpreting the man page

There's one thing I don't quite grok, because my C skills are weak: how is `ps(1)` iterating over the processes?
I can see that it [increments the pointer location](https://cgit.freebsd.org/src/tree/bin/ps/ps.c#n573), but I'm not sure how to make sense of it.
[kvm_getprocs(3)](https://man.freebsd.org/cgi/man.cgi?query=kvm_getprocs&sektion=3) sheds light on it:

> The processes are returned as a contiguous array of kinfo_proc structures.

So while it doesn't look like an array that I'm familiar with, the underlying memory is an array.
That's how `ps(1)` can start with the initial pointer, and then `++` it to point to the next item.

There's one other thing to point out on the man page: it informs me of which headers I need to include to use the function.

<span id="simple-c-program"></span>

### The result: A simple C program

_([example files](/dir?ci=trunk&name=www/programming-freebsd-reading-process-information))_

Whew.
All of that leads me to an absolutely bare-bones, totally not production-ready program that requests process information from the kernel and prints it on screen:

```c
#include <limits.h>
#include <paths.h>
#include <fcntl.h>

#include <kvm.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <sys/user.h>

#include <stdio.h>

int main() {
  kvm_t *kd;
  struct kinfo_proc *procs;
  int num_procs = -1;
  char errbuf[_POSIX2_LINE_MAX];

  kd = kvm_openfiles(NULL, _PATH_DEVNULL, NULL, O_RDONLY, errbuf);
  procs = kvm_getprocs(kd, KERN_PROC_PROC, 0, &num_procs);

  for (int i = 0; i < num_procs; i++) {
    printf("%d\t%s\n", procs[i].ki_pid, procs[i].ki_comm);
  }
}
```

It basically cuts `ps(1)` down to the absolute minimum.
There were a few constants (`_PATH_DEVNULL`, `O_RDONLY`, etc) that I needed to search `freebsd-src` for to find the headers to include.

## Summary

Impressive?
Maybe, maybe not - it depends on who you are and what you know.
I hope it illustrates how someone with little-to-no systems programming knowledge can find the information they need to make progress.

A few things to keep in mind before we part ways:

1. All of the source code is there - the programs, libraries, and kernel.
2. Use your existing knowledge of FreeBSD to find your starting point.
3. Use the program / library / syscall layered architecture to guide your explorations.
4. The info you need is in some combination of man pages, library source, and program source.

With that, I hope this helps you along in your efforts to program FreeBSD!
