# claude in jail

Run Claude in a jail so it doesn't have access to certain things -
keys, secret files, etc.

Another thing is running it with different modes. For example, I might
have a claude that has a zfs clone of the repo dir. It can commit to
the repo, but it can't actually modify my working tree. In that sense
it's like another developer, submitting patches for my integration and
review.

If I want to be paranoid, I can shut down the mutable claude jail
before I sign my commits. It's not really different from any other
rogue process (and I have firefox running in the same namespace).

Probably it makes the most sense to jail applications that have no
need to communicate with one another or share files. Ideally every
process that I run is in its own jail, and I integrate its output into
my system. Not specific to Claude, but Claude is a good use case for
it.
