#!/bin/bash

set -e

db=$1

set -u

if [ "$db" == "" ]; then
  echo "Creates the CE Operations database"
  echo "Usage: $0 database.sqlite"
  exit 0
fi

if [ -e "$db" ]; then
  echo "ERROR: database already exists: $db"
  exit 1
fi

sqlite3 "$db" "
  PRAGMA foreign_keys=ON;

  CREATE TABLE IF NOT EXISTS FILE(
    file_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT,
    filesize INTEGER,
    md5sum   TEXT CHECK(length(md5sum) == 32)
  );

  CREATE TABLE IF NOT EXISTS DIRECTORY(
    dir_id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL
  );
  INSERT INTO DIRECTORY(path) VALUES('/dev/null');

  CREATE TABLE IF NOT EXISTS OPERATION_ENUM(
    op_enum_id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation TEXT
  );
  INSERT INTO OPERATION_ENUM(operation) VALUES ('init'), ('mv'), ('rm');

  CREATE TABLE IF NOT EXISTS OPERATION(
    op_id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_id INTEGER,
    date TEXT,
    time TEXT,
    operation INTEGER,
    to_name TEXT,
    to_dir INTEGER,
    FOREIGN KEY(to_dir) REFERENCES DIRECTORY(dir_id),
    FOREIGN KEY(file_id) REFERENCES FILE(file_id),
    FOREIGN KEY(operation) REFERENCES ENUM(op_enum_id)
  );

"

