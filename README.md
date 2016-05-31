# Credits

Many thanks to [neil_townsend](https://community.netgear.com/t5/user/viewprofilepage/user-id/317565).  Neil's posts provided many hints for how to make this work.

# Overview
Back when the DGND3700v2 firmwale was originally built, the world was a different place.  I tried building the toolchain and firmware on a 64-bit Debian Jessie host, but ran into all sorts of symantic errors due to changes in current versions of gcc and various libraries.  Instead of trying to convince the old build system to work with new symantics, I stood up a 32-bit Debian Wheezy VM and do all my DGND3700v2 work there.  I highly recommend you do the same.  **This Makefile will not work on a modern up-to-date Linux system.**
