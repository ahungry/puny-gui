(def db-name "dummy.db")

(defn create-db []
  (def db (sqlite3/open db-name))
  (sqlite3/eval db "create table users (user text, pass text)")
  (sqlite3/eval db "INSERT INTO users (user, pass) VALUES ('dummy', 'dummy')")
  (sqlite3/close db))

(defn exec-db []
  (or (os/stat db-name)
      (create-db))
  # Open up the db
  (def db (sqlite3/open db-name))
  (def r (sqlite3/eval db "select count(*) from users"))
  (sqlite3/close db)
  r)

# (def peg-remove-non-numbers
#   '{:num (capture :d)
#     :main (some (+ :num :D))})

# (defn strip-non-numbers [s]
#   (-> (peg/match peg-remove-non-numbers s)
#       (string/join "")))

# (t/deftest
#  {:what "Stripping non-nums out works" :cost 1}
#  (t/eq "12345" (strip-non-numbers "a b c123a b c45 e f g")))
