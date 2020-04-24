/*
* Copyright (c) 2018 Calvin Rose
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to
* deal in the Software without restriction, including without limitation the
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
* sell copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/

#include "sqlite3.h"
#include <janet.h>

#define FLAG_CLOSED 1

#define MSG_DB_CLOSED "database already closed"

typedef struct {
    sqlite3* handle;
    int flags;
} Db;

/* Close a db, noop if already closed */
static void closedb(Db *db) {
    if (!(db->flags & FLAG_CLOSED)) {
        db->flags |= FLAG_CLOSED;
        sqlite3_close_v2(db->handle);
    }
}

/* Called to garbage collect a sqlite3 connection */
static int gcsqlite(void *p, size_t s) {
    (void) s;
    Db *db = (Db *)p;
    closedb(db);
    return 0;
}

#if JANET_VERSION_MAJOR == 1 && JANET_VERSION_MINOR < 6
static Janet sql_conn_get(void *p, Janet key);
#else
static int sql_conn_get(void *p, Janet key, Janet *out);
#endif

static const JanetAbstractType sql_conn_type = {
    "sqlite3.connection",
    gcsqlite,
    NULL,
    sql_conn_get,
#ifdef JANET_ATEND_GET
    JANET_ATEND_GET
#endif
};

/* Open a new database connection */
static Janet sql_open(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 1);
    const uint8_t *filename = janet_getstring(argv, 0);
    sqlite3 *conn;
    int status = sqlite3_open((const char *)filename, &conn);
    if (status != SQLITE_OK) janet_panic(sqlite3_errmsg(conn));
    Db *db = (Db *) janet_abstract(&sql_conn_type, sizeof(Db));
    db->handle = conn;
    db->flags = 0;
    return janet_wrap_abstract(db);
}

/* Close a database connection */
static Janet sql_close(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 1);
    Db *db = janet_getabstract(argv, 0, &sql_conn_type);
    closedb(db);
    return janet_wrap_nil();
}

/* Check for embedded NULL bytes */
static int has_null(const uint8_t *str, int32_t len) {
    while (len--) {
        if (!str[len])
            return 1;
    }
    return 0;
}

/* Bind a single parameter */
static const char *bind1(sqlite3_stmt *stmt, int index, Janet value) {
    int res;
    switch (janet_type(value)) {
        default:
            return "invalid sql value";
        case JANET_NIL:
            res = sqlite3_bind_null(stmt, index);
            break;
        case JANET_BOOLEAN:
            res = sqlite3_bind_int(stmt, index, janet_unwrap_integer(value));
            break;
        case JANET_NUMBER:
            res = sqlite3_bind_double(stmt, index, janet_unwrap_number(value));
            break;
        case JANET_STRING:
        case JANET_SYMBOL:
        case JANET_KEYWORD:
            {
                const uint8_t *str = janet_unwrap_string(value);
                int32_t len = janet_string_length(str);
                if (has_null(str, len)) {
                    return "cannot have embedded nulls in text values";
                } else {
                    res = sqlite3_bind_text(stmt, index, (const char *)str, len, SQLITE_STATIC);
                }
            }
            break;
        case JANET_BUFFER:
            {
                JanetBuffer *buffer = janet_unwrap_buffer(value);
                res = sqlite3_bind_blob(stmt, index, buffer->data, buffer->count, SQLITE_STATIC);
            }
            break;
    }
    if (res != SQLITE_OK) {
        sqlite3 *db = sqlite3_db_handle(stmt);
        return sqlite3_errmsg(db);
    }
    return NULL;
}

/* Bind many parameters */
static const char *bindmany(sqlite3_stmt *stmt, Janet params) {
    /* parameters */
    const Janet *seq;
    const JanetKV *kvs;
    int32_t len, cap;
    int limitindex = sqlite3_bind_parameter_count(stmt);
    if (janet_indexed_view(params, &seq, &len)) {
        if (len > limitindex + 1) {
            return "invalid index in sql parameters";
        }
        for (int i = 0; i < len; i++) {
            const char *err = bind1(stmt, i + 1, seq[i]);
            if (err) {
                return err;
            }
        }
    } else if (janet_dictionary_view(params, &kvs, &len, &cap)) {
        for (int i = 0; i < cap; i++) {
            int index = 0;
            switch (janet_type(kvs[i].key)) {
                default:
                    /* Will fail */
                    break;
                case JANET_NIL:
                    /* Will skip as nil keys indicate empty hash table slot */
                    continue;
                case JANET_NUMBER:
                    if (!janet_checkint(kvs[i].key)) break;
                    index = janet_unwrap_integer(kvs[i].key);
                    break;
                case JANET_KEYWORD:
                    {
                        char *kw = (char *)janet_unwrap_keyword(kvs[i].key);
                        /* Quick hack for keywords */
                        char old = kw[-1];
                        kw[-1] = ':';
                        index = sqlite3_bind_parameter_index(stmt, kw - 1);
                        kw[-1] = old;
                    }
                    break;
                case JANET_STRING:
                case JANET_SYMBOL:
                    {
                        const uint8_t *s = janet_unwrap_string(kvs[i].key);
                        index = sqlite3_bind_parameter_index(
                                stmt,
                                (const char *)s);
                    }
                    break;
            }
            if (index <= 0 || index > limitindex) {
                return "invalid index in sql parameters";
            }
            const char *err = bind1(stmt, index, kvs[i].value);
            if (err) {
                return err;
            }
        }
    } else {
        return "invalid type for sql parameters";
    }
    return NULL;
}

/* Execute a statement but don't collect results */
static const char *execute(sqlite3_stmt *stmt) {
    int status;
    const char *ret = NULL;
    do {
        status = sqlite3_step(stmt);
    } while (status == SQLITE_ROW);
    /* Check for errors */
    if (status != SQLITE_DONE) {
        sqlite3 *db = sqlite3_db_handle(stmt);
        ret = sqlite3_errmsg(db);
    }
    return ret;
}

/* Execute and return values from prepared statement */
static const char *execute_collect(sqlite3_stmt *stmt, JanetArray *rows) {
    /* Count number of columns in result */
    int ncol = sqlite3_column_count(stmt);
    int status;
    const char *ret = NULL;

    /* Get column names */
    Janet *tupstart = janet_tuple_begin(ncol);
    for (int i = 0; i < ncol; i++) {
        tupstart[i] = janet_ckeywordv(sqlite3_column_name(stmt, i));
    }
    const Janet *colnames = janet_tuple_end(tupstart);

    do {
        status = sqlite3_step(stmt);
        if (status == SQLITE_ROW) {
            JanetKV *row = janet_struct_begin(ncol);
            for (int i = 0; i < ncol; i++) {
                int t = sqlite3_column_type(stmt, i);
                Janet value;
                switch (t) {
                    case SQLITE_NULL:
                        value = janet_wrap_nil();
                        break;
                    case SQLITE_INTEGER:
                        value = janet_wrap_integer(sqlite3_column_int(stmt, i));
                        break;
                    case SQLITE_FLOAT:
                        value = janet_wrap_number(sqlite3_column_double(stmt, i));
                        break;
                    case SQLITE_TEXT:
                        {
                            int nbytes = sqlite3_column_bytes(stmt, i);
                            uint8_t *str = janet_string_begin(nbytes);
                            memcpy(str, sqlite3_column_text(stmt, i), nbytes);
                            value = janet_wrap_string(janet_string_end(str));
                        }
                        break;
                    case SQLITE_BLOB:
                        {
                            int nbytes = sqlite3_column_bytes(stmt, i);
                            JanetBuffer *b = janet_buffer(nbytes);
                            memcpy(b->data, sqlite3_column_blob(stmt, i), nbytes);
                            b->count = nbytes;
                            value = janet_wrap_buffer(b);
                        }
                        break;
                }
                janet_struct_put(row, colnames[i], value);
            }
            janet_array_push(rows, janet_wrap_struct(janet_struct_end(row)));
        }
    } while (status == SQLITE_ROW);

    /* Check for errors */
    if (status != SQLITE_DONE) {
        sqlite3 *db = sqlite3_db_handle(stmt);
        ret = sqlite3_errmsg(db);
    }
    return ret;
}

/* Evaluate a string of sql */
static Janet sql_eval(int32_t argc, Janet *argv) {
    janet_arity(argc, 2, 3);
    const char *err;
    sqlite3_stmt *stmt = NULL, *stmt_next = NULL;
    Db *db = janet_getabstract(argv, 0, &sql_conn_type);
    if (db->flags & FLAG_CLOSED) janet_panic(MSG_DB_CLOSED);
    const uint8_t *query = janet_getstring(argv, 1);
    if (has_null(query, janet_string_length(query))) {
        err = "cannot have embedded NULL in sql statememts";
        goto error;
    }
    JanetArray *rows = janet_array(10);
    const char *c = (const char *)query;

    /* Evaluate all statements in a loop */
    do {
        /* Compile the next statement */
        if (sqlite3_prepare_v2(db->handle, c, -1, &stmt_next, &c) != SQLITE_OK) {
            err = sqlite3_errmsg(db->handle);
            goto error;
        }
        /* Check if we have found last statement */
        if (NULL == stmt_next) {
            /* Execute current statement and collect results */
            if (stmt) {
                err = execute_collect(stmt, rows);
                if (err) goto error;
            }
        } else {
            /* Execute current statement but don't collect results. */
            if (stmt) {
                err = execute(stmt);
                if (err) goto error;
            }
            /* Bind params to next statement*/
            if (argc == 3) {
                /* parameters */
                err = bindmany(stmt_next, argv[2]);
                if (err) goto error;
            }
        }
        /* rotate stmt and stmt_next */
        if (stmt) sqlite3_finalize(stmt);
        stmt = stmt_next;
        stmt_next = NULL;
    } while (NULL != stmt);

    /* Good return path */
    return janet_wrap_array(rows);

error:
    if (stmt) sqlite3_finalize(stmt);
    if (stmt_next) sqlite3_finalize(stmt_next);
    janet_panic(err);
    return janet_wrap_nil();
}

/* Gets the last inserted row id */
static Janet sql_last_insert_rowid(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 1);
    Db *db = janet_getabstract(argv, 0, &sql_conn_type);
    if (db->flags & FLAG_CLOSED) janet_panic(MSG_DB_CLOSED);
    sqlite3_int64 id = sqlite3_last_insert_rowid(db->handle);
    return janet_wrap_number((double) id);
}

/* Get the sqlite3 errcode */
static Janet sql_error_code(int32_t argc, Janet *argv) {
    janet_fixarity(argc, 1);
    Db *db = janet_getabstract(argv, 0, &sql_conn_type);
    if (db->flags & FLAG_CLOSED) janet_panic(MSG_DB_CLOSED);
    int errcode = sqlite3_errcode(db->handle);
    return janet_wrap_integer(errcode);
}

static JanetMethod conn_methods[] = {
    {"error-code", sql_error_code},
    {"close", sql_close},
    {"eval", sql_eval},
    {"last-insert-rowid", sql_last_insert_rowid},
    {NULL, NULL}
};

#if JANET_VERSION_MAJOR == 1 && JANET_VERSION_MINOR < 6
static Janet sql_conn_get(void *p, Janet key) {
    (void) p;
    if (!janet_checktype(key, JANET_KEYWORD)) {
        janet_panicf("expected keyword, get %v", key);
    }
    return janet_getmethod(janet_unwrap_keyword(key), conn_methods);
}
#else
static int sql_conn_get(void *p, Janet key, Janet *out) {
    (void) p;
    if (!janet_checktype(key, JANET_KEYWORD)) {
        janet_panicf("expected keyword, get %v", key);
    }
    return janet_getmethod(janet_unwrap_keyword(key), conn_methods, out);
}
#endif

/*****************************************************************************/

static const JanetReg sqlite3_cfuns[] = {
    {"sqlite3/open", sql_open,
        "(sqlite3/open path)\n\n"
        "Opens a sqlite3 database on disk. Returns the database handle if the database was opened "
        "successfully, and otheriwse throws an error."
    },
    {"sqlite3/close", sql_close,
        "(sqlite3/close db)\n\n"
        "Closes a database. Use this to free a database after use. Returns nil."
    },
    {"sqlite3/eval", sql_eval,
        "(sqlite3/eval db sql [,params])\n\n"
        "Evaluate sql in the context of database db. Multiple sql statements "
        "can be changed together, and optionally parameters maybe passed in. "
        "The optional parameters maybe either an indexed data type (tuple or array), or a dictionary "
        "data type (struct or table). If params is a tuple or array, then sqlite "
        "parameters are substituted using indices. For example:\n\n"
        "\t(sqlite3/eval db `SELECT * FROM tab WHERE id = ?;` [123])\n\n"
        "Will select rows from tab where id is equal to 123. Alternatively, "
        "the programmer can use named parameters with tables or structs, like so:\n\n"
        "\t(sqlite3/eval db `SELECT * FROM tab WHERE id = :id;` {:id 123})\n\n"
        "Will return an array of rows, where each row contains a table where columns names "
        "are keys for column values."
    },
    {"sqlite3/last-insert-rowid", sql_last_insert_rowid,
        "(sqlite3/last-insert-rowid db)\n\n"
        "Returns the id of the last inserted row."
    },
    {"sqlite3/error-code", sql_error_code,
        "(sqlite3/error-code db)\n\n"
        "Returns the error number of the last sqlite3 command that threw an error. Cross "
        "check these numbers with the SQLite documentation for more information."
    },
    {NULL, NULL, NULL}
};

/* JANET_MODULE_ENTRY(JanetTable *env) { */
/*     janet_cfuns(env, "sqlite3", cfuns); */
/* } */
