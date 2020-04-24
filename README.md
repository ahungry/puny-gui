# Puny GUI

This is a small cross-platform (native) GUI setup (GNU/Linux + Windows).

To start creating GUIs requires NO compilation, installation, or large
downloads.

Everything you need to get started can be found on the releases tab
here:

  https://github.com/ahungry/puny-gui/releases

Simply download the appropriate release bundles and start modifying
the app.janet and/or other .janet files to adjust the basic template
to fit your needs.

For iterative development, you can run 'super-repl' instead of 'app'.

The supports the following, thanks to the underlying software being
bundled with it:

- Script Language (via https://janet-lang.org)
- Native GUI (via IUP http://webserver2.tecgraf.puc-rio.br/iup/en/)
- Web Client (via cURL https://curl.haxx.se/)
- Web Server (via Mongoose https://github.com/cesanta/mongoose)
- Persistence (via sqlite https://sqlite.org/index.html)
- JSON (via https://github.com/janet-lang/json)

# License

All linked/included works that are not my own are subject to their
original licenses (the majority are MIT, Mongoose is GPLv2).

You can find the original sources on the associated links above.

All original works are copyright Matthew Carter <m@ahungry.com> and
licensed under GPLv3.

If you make a derivative work, you need to ahdere to the license here
(as well as those in the dependencies, which may be GPLv2 in the case
of the mongoose/circlet stuff).
