#!/bin/bash

set -e

db=$1
path=$2

set -u

if [ "$path" == "" ]; then
  echo "Adds a directory to the CE database. The directory should already be in the CE."
  echo "  If the directory is already listed in the database, does not add it again."
  echo "  Then, returns the database dir_id"
  echo "Usage: $0 database.sqlite path/to/dir"
  exit 0
fi

path=$(realpath $path)

# Directory table
dir_id=$(
  sqlite3 "$db" "
    SELECT dir_id
    FROM DIRECTORY
    WHERE path='$path';
  "
)
if [ "$dir_id" == "" ]; then
  dir_id=$(
    sqlite3 "$db" "
      PRAGMA foreign_keys=ON;
      INSERT INTO DIRECTORY(path)
        VALUES ('$path');

      SELECT last_insert_rowid();
    "
  )
  echo "Added $path to database" >&2
fi

echo "$dir_id"
