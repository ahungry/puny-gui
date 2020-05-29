# Puny GUI


This is a small cross-platform (native) GUI setup (GNU/Linux + Windows).

To start creating GUIs requires NO compilation, installation, or large
downloads (entire bin/exe setup is less than 5 MB).

You can see the complete source for a GUI to fetch a random dog
picture on a single screen (with said resultant app):

![ahubu](https://raw.githubusercontent.com/ahungry/puny-gui/master/dog-sample.png)

Everything you need to get started can be found on the releases tab
here:

  https://github.com/ahungry/puny-gui/releases

Simply download the appropriate release bundles and start modifying
the app.janet and/or other .janet files to adjust the basic template
to fit your needs.

For iterative development, you can run 'super-repl' instead of 'app'.

The kit supports the following, thanks to the underlying software being
bundled with it (via dll for Windows or dynamic linking for GNU/Linux):

- Script Language (via https://janet-lang.org)
- Native GUI (via IUP http://webserver2.tecgraf.puc-rio.br/iup/en/)
- Web Client (via cURL https://curl.haxx.se/)
- Web Server (via Mongoose https://github.com/cesanta/mongoose)
- Persistence (via sqlite https://sqlite.org/index.html)
- JSON (via https://github.com/janet-lang/json)

# Installation

None - just download, inflate, and start hacking a new app together
for some users to enjoy.

Due to the shared linking, you/your users *will* need to ensure you
have the appropriate shared libs/packages installed on your host *nix
system, as such:

- gtk+-3
- curl
- sqlite

For very lazy Ubuntu users, they can simply run the included
'./ubuntu-packages.sh' script.

# Building

See Makefile for GNU/Linux and Wakefile for Windows (I built the
release things for Windows using mingw64).

Running 'make' depends on having a nested Janet source code in the
build directory.

The nested Janet source code depends upon having IUP files in the
build directory.

Building anything at all requires the necessary build files.

If you want a widely distributable GNU/Linux build, you may want to
copy me and do so in an Ubuntu 18.04 docker image, by using the
attached dockerfile with the following make commands:

```sh
make docker-build docker-run docker-get
```

This will pull a produced tarball out of the docker image and into
your root repository directory.

If you like doing things manually, ensure you have done the following
in this order:

```sh
./ubuntu-build-packages.sh # For Ubuntu users only!
./get-iup-linux-files.sh   # Will download IUP GNU/Linux files
./get-janet.sh             # Will download + build a custom Janet runtime
make -Bj                   # Will force build app.bin + super-repl.bin
```

Now enjoy your custom build.


# License

All linked/included works that are not my own are subject to their
original licenses (the majority are MIT, Mongoose is GPLv2).

You can find the original sources on the associated links above.

All original works are copyright Matthew Carter <m@ahungry.com> and
licensed under GPLv3.

If you make a derivative work, you need to adhere to the license here
(as well as those in the dependencies, which may be GPLv2 in the case
of the mongoose/circlet stuff).
