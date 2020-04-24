# SQLite bindings

This native module proves sqlite bindings for janet.

## Building

To build, use the `jpm` tool and make sure you have janet installed.

```
jpm build
```

## Example Usage

Next, enter the repl and create a database and a table.
By default, the generated module will be in the build folder.

```
janet:1:> (import build/sqlite3 :as sql)
nil
janet:2:> (def db (sql/open "test.db"))
<sqlite3.connection 0x5561A138C470>
janet:3:> (sql/eval db `CREATE TABLE customers(id INTEGER PRIMARY KEY, name TEXT);`)
@[]
janet:4:> (sql/eval db `INSERT INTO customers VALUES(:id, :name);` {:name "John" :id 12345})
@[]
janet:5:> (sql/eval db `SELECT * FROM customers;`)
@[{"id" 12345 "name" "John"}]
```

Finally, close the database connection when done with it.

```
janet:6:> (sql/close db)
nil
```
