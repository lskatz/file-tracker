#!/bin/bash

set -e

db=$1
path=$2

set -u

if [ "$path" == "" ]; then
  echo "Describes the history of a file" >&2
  echo "Usage: $0 db.sqlite path/to/file" >&2
  exit 0
fi

path=$(realpath $path)
filename=$(basename $path)

file_id=$(sqlite3 "$db" "
  SELECT file_id FROM FILE
  WHERE filename='$filename';
  "
)

if [ ! "$file_id" ]; then
  echo "ERROR: file ID was not found in the database" >&2
  exit 1
fi

filehistory=$(
  sqlite3 -separator $'\t' "$db" "
    SELECT * FROM OPERATION
    WHERE file_id='$file_id'
    ORDER BY op_id;
  "
)

spacing=""
echo "$filehistory" | \
  while read -r op_id file_id date time operation to_name to_dir; do 
    dirname=$(
      sqlite3 "$db" "
        SELECT path FROM DIRECTORY
        WHERE dir_id='$to_dir';
      "
    )
    echo "$spacing$dirname"
    spacing="  $spacing"
  done
