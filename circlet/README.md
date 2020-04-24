# circlet

Circlet is an HTTP and networking library for the [janet](https://github.com/janet-lang/janet) language.
It provides an abstraction out of the box like Clojure's [ring](https://github.com/ring-clojure/ring), which
is a server abstraction that makes it easy to build composable web applications.

Circlet uses [mongoose](https://cesanta.com/) as the underlying HTTP server engine. Mongoose
is a portable, low footprint, event based server library. The flexible build system requirements
of mongoose make it very easy to embed in other C programs and libraries.

## Building

Building requires [janet](https://github.com/janet-lang/janet) to be installed on the system, as
well as the `jpm` tool (installed by default with latest installs).

```sh
jpm build
```

You can also just run `jpm` to see a list of possible build commands.

## Testing

Run a server on localhost with the following command

```sh
jpm test
```

## Example

The below example starts a very simple web server on port 8000.

```lisp
(import circlet)

(defn myserver
 "A simple HTTP server"
 [req]
 {:status 200
  :headers {"Content-Type" "text/html"}
  :body "<!doctype html><html><body><h1>Hello.</h1></body></html>"})

(circlet/server myserver 8000)
```

## License

Unlike [janet](https://github.com/janet-lang/janet), circlet is licensed under
the GPL license in accordance with mongoose.
