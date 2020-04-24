# This is embedded, so all circlet functions are available

(defn middleware
  "Coerce any type to http middleware"
  [x]
  (case (type x)
    :function x
    (fn [&] x)))

(defn router
  "Creates a router middleware"
  [routes]
  (fn [req]
    (def r (or
             (get routes (get req :uri))
             (get routes :default)))
    (if r ((middleware r) req) 404)))

(defn logger
  "Creates a logging middleware"
  [nextmw]
  (fn [req]
    (def {:uri uri
          :protocol proto
          :method method
          :query-string qs} req)
    (def start-clock (os/clock))
    (def ret (nextmw req))
    (def end-clock (os/clock))
    (def fulluri (if (< 0 (length qs)) (string uri "?" qs) uri))
    (def elapsed (string/format "%.3f" (* 1000 (- end-clock start-clock))))
    (def status (or (get ret :status) 200))
    (print proto " " method " " status " " fulluri " elapsed " elapsed "ms")
    ret))

(defn server
  "Creates a simple http server"
  [handler port &opt ip-address]
  (def mgr (circlet-manager))
  (def mw (middleware handler))
  #(default ip-address "localhost")
  # On windows, only IP works, not localhost - maybe getaddr stuff missing?
  (default ip-address "127.0.0.1")
  (def interface (if (peg/match "*" ip-address)
                   (string port)
                   (string/format "%s:%d" ip-address port)))
  (defn evloop []
    (print (string/format "Circlet server listening on [%s:%d] ..." ip-address port))
    (var req (yield nil))
    (while true
      (set req (yield (mw req)))))
  (circlet-bind-http mgr interface evloop)
  (while true (circlet-poll mgr 2000)))
