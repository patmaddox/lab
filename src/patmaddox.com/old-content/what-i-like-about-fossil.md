+++
title = "What I like about Fossil"
+++

# What I like about Fossil

## It's fully open source

I have wondered how they did certain things, like adding a search box to the documentation.

I don't have to dig through docs - I can look directly at their source code!

`fossil clone https://fossil-scm.org && head -n 10 fossil-scm/www/permutedindex` shows it.

I did have to modify the search settings, which was easy enough.

## It's the fastest way to develop and deploy a static site

The [embedded project documentation](https://fossil-scm.org/home/doc/trunk/www/embeddeddoc.wiki) lets me make a full website using simple Markdown files.
I can preview it locally with `fossil ui`.

As soon as I commit, it syncs my repo with [patmaddox.com](https://www.patmaddox.com).
My site is up-to-date by the time switch to my browser and reload.

## Amending commit messages

So nice!
It would be great if I got the commit message right every time, but I don't.
Sometimes I need a bit more work and context to find the best way to express it.
Sometimes I'm just lazy and tired and don't feel like doing it.
With Fossil, I can commit the content I have, and amend the message later.
