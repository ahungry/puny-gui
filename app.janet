(import standalone :as s)
(import iup :as gui)
(import circlet_lib :as web)
(import auctions :as a)

(defn handler [req]
  (pp "Got a request..")
  (pp req)
  {
   :status 200
   :headers {"Content-Type" "application/json"}
   :body "42"
   })

(defn make-json-response [status body]
  {:status status :headers {"Content-Type" "application/json"} :body body})
(def response-stub (make-json-response 200 "42"))
(def response-404 (make-json-response 404 "NOT FOUND"))

(defn worker-server
  "Run the webserver in the background?"
  [parent]
  (web/server (web/logger (web/router {"/" response-stub
                                       :default response-404 })) 8000)
  )
(defn worker-client
  "Run the webserver in the background?"
  [parent]
  (os/sleep 1)
  (s/get-ip))

(defn main [_]
  (thread/new worker-server)
  (thread/new worker-client)
  # (thread/new (fn [p] (s/get-ip)))
  (pp (a/exec-db))
  #(s/get-ip)
  (pp (json/encode {:a 1 :b 2}))
  (gui/main)
  #(web/server handler 8000)
  (pp "Hello"))
