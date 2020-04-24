(import build/circlet :as circlet)

(def body
  ````<!doctype html>
<html>
<body>
Not Found.
</body>
</html>
````)

# Now build our server
(circlet/server 
  (->
      {"/thing" {:status 200
                 :headers {"Content-Type" "text/html"}
                 :body "<!doctype html><html><body><h1>Is a thing.</h1></body></html>"}
       :default {:status 404
                 :headers {"Content-Type" "text/html"}
                 :body body}}
      circlet/router
      circlet/logger)
  8000)
