# Small SDK to get a random dog picture and save it to disk
(import lib/net/curl :as client)

(def random-host "https://dog.ceo/api/breeds/image/random")

(defn get-random-dog [host]
  (-> (client/json-get host)
      (get "message")))

(defn get-image-content
  "Fetches remote dog picture and saves to disk."
  [url]
  (def img (client/http-get url))
  (spit "dog.jpg" img))

(-> (get-random-dog random-host)
    get-image-content)
