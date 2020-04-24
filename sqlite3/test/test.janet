(import build/sqlite3 :as sql)

#
# Testing
#

(defn assert [c]
  (if (not c) (error "failed assertion")))
(def db (sql/open "build/test.db"))
(try (sql/eval db `DROP TABLE people`) ([_]))
(sql/eval db `CREATE TABLE people(name TEXT, age INTEGER);`)
(sql/eval db `INSERT INTO people values(:name, :age)` {:name "John" :age 20})
(sql/eval db `INSERT INTO people values(:name, :age)` {:name "Paul" :age 30})
(sql/eval db `INSERT INTO people values(:name, :age)` {:name "Bob" :age 40})
(sql/eval db `INSERT INTO people values(:name, :age)` {:name "Joe" :age 50})
(def results (sql/eval db `SELECT * FROM people`))
(assert (= (length results) 4))
