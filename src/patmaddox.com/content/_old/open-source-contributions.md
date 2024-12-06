+++
title = "Open source contributions"
path = "doc/trunk/www/open-source-contributions/"
+++

# Open source contributions

- **FreeBSD ports**: currently maintaing [16 ports](https://portscout.freebsd.org/pat@patmaddox.com.html), and have submitted updates to others ([commits](https://github.com/search?q=repo%3Afreebsd%2Ffreebsd-ports+author%3Apatmaddox&type=commits))
  - [Pending ports updates](https://bugs.freebsd.org/bugzilla/buglist.cgi?bug_status=__open__&component=Individual%20Port%28s%29&f1=short_desc&f2=attachments.ispatch&f3=reporter&f4=assigned_to&f5=assigned_to&list_id=682347&o1=notsubstring&o2=matches&o3=equals&o4=notequals&o5=notequals&order=Bug%20Number&product=Ports%20%26%20Packages&query_format=advanced&v1=NEW%20PORT&v3=pat%40patmaddox.com&v4=erlang%40FreeBSD.org&v5=portmgr%40FreeBSD.org)
  - [Pending new ports](https://bugs.freebsd.org/bugzilla/buglist.cgi?bug_status=__open__&component=Individual%20Port%28s%29&f1=short_desc&f2=attachments.ispatch&f3=reporter&list_id=682349&o1=substring&o2=matches&o3=equals&order=Bug%20Number&product=Ports%20%26%20Packages&query_format=advanced&v1=NEW%20PORT&v3=pat%40patmaddox.com)
- **Tailscale**: add Tailscale SSH (server) support on FreeBSD ([commit](https://github.com/tailscale/tailscale/commit/9bf3ef416745ae28464e43f0a0f5dd6abc7350cb) | [PR](https://github.com/tailscale/tailscale/pull/6155))
- **u-root**: termios: Support FreeBSD ([commit](https://github.com/u-root/u-root/commit/18fd0ce36891fd1e84ca9e1e26b2b3cd2c3d3b57) | [PR](https://github.com/u-root/u-root/pull/2544)) - this was a dependency for Tailscale SSH
- **poudriere**: avoid unnecessary package building ([PR](https://github.com/freebsd/poudriere/pull/1064))
