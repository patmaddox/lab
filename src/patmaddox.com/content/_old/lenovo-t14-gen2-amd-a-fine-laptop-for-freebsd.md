+++
title = "Lenovo T14 Gen 2 AMD - a fine laptop for FreeBSD (with a wifi caveat)"
path = "doc/trunk/www/2023-04-lenovo-t14-gen2-amd-a-fine-laptop-for-freebsd.md"
aliases = [
  "doc/trunk/www/lenovo-t14-gen2-amd-a-fine-laptop-for-freebsd.md"
]
+++

# Lenovo T14 Gen 2 AMD - a fine laptop for FreeBSD (with a wifi caveat)

_Published on April 20, 2023_

_Discuss:
[FreeBSD forum](https://forums.freebsd.org/threads/lenovo-thinkpad-t14-gen-2-amd-a-fine-laptop-for-freebsd-with-a-wifi-caveat.88856/)
\|
[reddit](https://www.reddit.com/r/freebsd/comments/12tiqas/lenovo_t14_gen_2_amd_a_fine_laptop_for_freebsd/)_

---

I've been on the hunt for a FreeBSD laptop for about 6 months.
I wanted at least 6 cores and 32 GB RAM.
That's not a particularly high-end config, considering the current CPU generation.
It did require a lot of effort to find though.

Today, I'm happy to report that the Lenovo T14 Gen 2 AMD is a fine machine for FreeBSD, with one caveat: you need to replace the wireless card.
The good news for us FreeBSD users is that Lenovo Outlet seems to regularly have the T14 in different configurations... for now.
So, head on over to the Outlet and find one with the specs you want, replace the wireless card, and have fun.

**I ended up with Part # 20XK0019US**, which has an 8-core 5850U CPU, 16 GB soldered RAM, and 400 nits low power display.
I've upgraded it with an additional 16 GB RAM, replaced the SSD with a 2 TB Samsung 980 Pro, and replaced the wireless card with an Intel Wireless AC 9260.
_Note: Lenovo incorrectly describes that Part # as having a 6-core 5650U (see "Things I learned along the way")._

## What do I mean by "works"?

I mean general laptop usage:

1. Power it on, unplugged.
2. Log in.
3. Start xfce.
4. Do my stuff - write code, browse internet, etc.
5. [Suspend](https://man.freebsd.org/cgi/man.cgi?query=zzz).
6. Shut the lid.
7. Go somewhere else.
8. Open the lid (resume).
9. Keep working.

I know it's weird that I'd have to describe how people use laptops. I've just found some interesting claims about laptops that "work" on the FreeBSD forums, that can't do what I described above.

## Things that might work

Here's what I haven't tried yet:

- **function keys** - I believe they'll work with some configuration, because emacs complains `<XF86AudioMute> is undefined` when I press one. So apparently they're already sending a key code that means something useful.
- **webcam and microphone** - I don't really care about this for this machine, but I'll get around to trying it at some point.
- **fingerprint reader** - I'm skeptical that this will work, but would like to try because it would be useful for MFA.
- **HDMI** - I have a desktop machine for that.

## Pleasant surprises

**Audio works out of the box.**
I was pretty certain I would need to configure some stuff, but YouTube just worked with no issue.

**It got quieter / cooler after I upgraded RAM and SSD.**
This is a huge one for me.
Once I got a machine that worked (other than wi-fi), there was only one thing I didn't like about it: the fan noise.
It's not terrible - it's quieter than my 2015 MacBook Pro - I'm just very sensitive to noise, and I knew that it would irritate me.
In the end I, I decided that I could live with a little fan noise if it meant I could use FreeBSD, so I popped it open to add another 16GB of RAM and replace the 512GB SSD with a 2TB one.

That's where the surprise came in.
I don't know if it's because the machine has more RAM, or if a Samsung 980 Pro runs cooler than the drive Lenovo ships...
but I haven't heard the fan since I upgraded those parts.
It spins up when I'm compiling stuff - as it should - but it's silent when just browsing and editing.

**Lenovo returns are easy as can be.**
I buy a lot of stuff from Amazon, because it's so easy to return things if they don't work out.
It turns out that Lenovo has no-hassle returns as well.
The main thing to know is that the Outlet (which has the slightly older machines that work well with FreeBSD) has a different policy than the main website.
You need to initiate a return within 14 days of invoice, rather than 30 days on the main site.

## Things I learned along the way

...so much stuff that I really don't care about.
I'm sharing it here in the hopes that it saves other people time and energy.

**GPUs and wireless cards are the killers.**
There's not a conclusive list of GPUs that [drm-kmod](https://www.freshports.org/graphics/drm-kmod) supports.
You can get clues by looking at the list of flavors that e.g. [gpu-firmware-amd-kmod](https://www.freshports.org/graphics/gpu-firmware-amd-kmod) installs, but it's not a guarantee.
For one, at least one of the flavors (`dimgrey_cavefish`) is included in preparation for a future release, but isn't supported.
Beyond that, the list is just the list of drivers supported by the Linux 5.10 kernel - but it's possible they are crappy early experiments that don't actually work.

Likewise, wireless cards may just not be supported at all.
If they are, they may be buggy.
I was initially pleased with an AX200 using the [iwlwifi](https://man.freebsd.org/cgi/man.cgi?query=iwlwifi&sektion=4&format=html) driver - until reloading the driver caused the machine to power off right away.

You probably want a replaceable wireless card, so that you can upgrade to an AX200 whenever iwlwifi stabilizes.
To do that, you need to read [the specs](https://psref.lenovo.com/syspool/Sys/PDF/ThinkPad/ThinkPad_T14_Gen_2_AMD/ThinkPad_T14_Gen_2_AMD_Spec.pdf) to determine if the wireless card is replaceable, or if it's soldered onto the main board.

Bottom line: GPU and wireless card are the main limiting factor when it comes to finding a FreeBSD-compatible laptop.
Find a GPU and wireless card that work, and you're probably good to go.

**Screen nits are a thing.**
I had NO idea about this, and it caused me some of the most frustration and disappointment in this whole process.
As far as I can tell, "nits" is the term for what people call "brightness."
Lenovo is happy to ship laptops with extremely dim screens.

250 nits is shit.
300 nits is slightly less shit.
400 nits is good.
500 nits is probably good / very good. I never ordered one. They are all glossy touch screens, which I don't want.

**Lenovo Outlet sometimes gets the description wrong.**
The most reliable way to know the specs of a machine you order are to look up the part number, and then search for it on other retailers like Newegg and Amazon.
A couple times, Lenovo has sent me a laptop that had different specs from what they listed.
The part number matched, and the specs matched the description of that part number on other sites, but the specs were different from Lenovo's own site.
So just be careful when you order, that you get what you think you're getting.

**Components are becoming less upgradeable / replaceable.**
The "slim" version (T14s) has a soldered wireless card.
So, you'll need to use a USB wireless dongle if you want wi-fi.
Similarly, more recent machines often have RAM entirely soldered on, with no slot for additional RAM.

## Other Thinkpads to consider

As I mentioned, you need to make sure you have a GPU and wireless card that work.
You're stuck with the GPU that Lenovo ships, and you want to make sure you can replace the wireless card.

Basically I'd say anything with a 5000-series Ryzen - 5850U, 5650U, etc - will work great.
10th gen intel also works well, but is limited to 4-core models.
11th gen intel might also work, but might not, and I believe is similarly limited to 4 cores.

The two other models I'd consider, based on my research, are the P14s Gen 2 AMD and L14 Gen 3 AMD.
The P14s is apparently the same exact machine as the T14, with some additional certification about robustness claims.
The L14 is surprisingly interesting, because it has 4 RAM slots supporting a total of 64 GB.
However, I haven't found any with a 400 nits display, and 300 is too dim for my liking.

## Good luck!

According to my Lenovo and Amazon purchase histories, I have bought 9 Thinkpads to try out.
I am ecstatic to be typing this on the keeper - a T14 Gen 2 AMD running FreeBSD 13.2.
