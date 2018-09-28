#!/bin/bash

set -e

db=$1
path=$2

set -u

if [ "$path" == "" ]; then
  echo "Adds a file to the CE database. The file should already be in the CE."
  echo "Usage: $0 database.sqlite path/to/file.fastq.gz"
  exit 0
fi

path=$(realpath $path)

filename=$(basename $path)
dirname=$(dirname $path)
filesize=$(wc -c < "$path")
md5sum=$(md5sum < "$path" | awk '{print $1}')

# Directory table
dir_id=$(
  sqlite3 "$db" "
    SELECT dir_id
    FROM DIRECTORY
    WHERE path='$dirname';
  "
)
if [ "$dir_id" == "" ]; then
  dir_id=$(
    sqlite3 "$db" "
      PRAGMA foreign_keys=ON;
      INSERT INTO DIRECTORY(path)
        VALUES ('$dirname');

      SELECT last_insert_rowid();
    "
  )
fi

# File table
file_id=$(
  sqlite3 "$db" "
    PRAGMA foreign_keys=ON;

    INSERT INTO FILE(filename, dir_id, filesize, md5sum)
      VALUES ('$filename', '$dir_id', '$filesize', '$md5sum');

    SELECT last_insert_rowid();
  "
)

# File operation table
op_id=$(
  sqlite3 "$db" "
    PRAGMA foreign_keys=ON;
    INSERT INTO OPERATION(file_id, date, time, operation, to_name, to_dir)
      VALUES ($file_id, 
        (SELECT DATE('now','localtime')), 
        (SELECT TIME('now','localtime')),
        (SELECT op_enum_id FROM OPERATION_ENUM WHERE operation='init'),
        '$filename', $dir_id
      );
      SELECT last_insert_rowid();
    "
  )

echo "Initialized file $path into $db" >&2
echo "$op_id"

