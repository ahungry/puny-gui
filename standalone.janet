(defn get-ip []
  (def c (curl-easy-init))

  (def chunk (new-curl-slist-null))
  (def chunk2 (curl-slist-append chunk "Content-Type: application/json"))
  (def chunk3 (curl-slist-append chunk2 "Accept:")) # nulls out the accept, so we take any

  (curl-easy-setopt-pointer c (const-CURLOPT-HTTPHEADER) chunk3)

  # For the Windows stuff, doesn't seem to work well with crt bundle atm
  # on a wine install at least..
  (curl-easy-setopt c (const-CURLOPT-SSL-VERIFYHOST) 0)
  (curl-easy-setopt c (const-CURLOPT-SSL-VERIFYPEER) 0)
  ##

  # Use this url, as it does send a 302 from http to https
  #(curl-easy-setopt-string c (const-CURLOPT-URL) "https://httpbin.org/post")
  (curl-easy-setopt-string c (const-CURLOPT-URL) "http://127.0.0.1:8000")
  (curl-easy-setopt c (const-CURLOPT-FOLLOWLOCATION) 1)
  #(curl-easy-setopt c (const-CURLOPT-POST) 1)

  # Enable to see lots of output
  #(curl-easy-setopt c (const-CURLOPT-VERBOSE) 1)

  (pp "About to set data")

  (def data "{\"x\": 1}")
  (curl-easy-setopt-string c (const-CURLOPT-POSTFIELDS) data)
  (curl-easy-setopt c (const-CURLOPT-POSTFIELDSIZE) (length data))


  (pp "About to perform ")

  (def res (curl-easy-perform c))

  (pp "Performed it...")

  (curl-easy-cleanup c)
  (curl-slist-free-all chunk)

  (pp res)

  (pp "Greetings!"))

(defn main []
  (pp "You rang?")
  (get-ip)
  (pp "All done"))
