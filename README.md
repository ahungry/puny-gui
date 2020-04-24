# Super app/repl

So far the following builds in both/works in one or the other:

- IUP (GUI) - GNU/Linux (.so) / Windows (static)
- cURL - GNU/Linux (.so) / Windows (dll)
- circlet (HTTP server) - GNU/Linux (static) / Windows (static)
- sqlite3 - GNU/Linux (shared) / Windows (dll)
- json - GNU/Linux (static) / Windows (static)

The process had to be updated from modifying/including in app level to
recompiling the amalg janet source, otherwise non BIF will not work in
the thread callbacks due to symbol missing in global resolution stuff.

# License

Copyright Matthew Carter <m@ahungry.com>

Some works are under MIT license, some are GPLv2.

All source is available at this repository you fetched the file from.

If you make a derivative work, you need to ahdere to the license here
(as well as those in the dependencies, which may be GPLv2 in the case
of the mongoose/circlet stuff).


# TODO

Try out these:

    "https://github.com/janet-lang/sqlite3.git"
    "https://github.com/janet-lang/argparse.git"
    "https://github.com/janet-lang/path.git"
    "https://github.com/andrewchambers/janet-uri.git"
    "https://github.com/andrewchambers/janet-jdn.git"
    "https://github.com/andrewchambers/janet-flock.git"
    "https://github.com/andrewchambers/janet-process.git"
    "https://github.com/andrewchambers/janet-sh.git"
    "https://github.com/andrewchambers/janet-base16.git"

# Getting IUP Files (iup, im, cd)

On GNU/Linux and/or Windows, iup works with static or dynamic linking,
im only works with dynamic because it has cpp only stuff in the
archive file, and cd was not required.

# TODO Cleanup

Perhaps remove mongoose/circlet - it segfaults on Windows (probably
requires windows special flags to be set in source, which are not
being set)...
