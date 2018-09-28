#!/bin/bash

set -e

db=$1
path=$2
newpath=$3

set -u

if [ "$newpath" == "" ]; then
  echo "Moves or renames a file in the CE database. Also moves the file in the filesystem." >&2
  echo "Usage: $0 database.sqlite path/to/file.fastq.gz new/path/to/file.fastq.gz" >&2
  exit 0
fi

path=$(realpath $path)
newpath=$(realpath $newpath)

if [ -d "$newpath" ]; then
  newpath="$newpath/$(basename $path)"
fi

from_filename=$(basename $path)
from_dirname=$(dirname $path)
to_filename=$(basename $newpath)
to_dirname=$(dirname $newpath)

# Directory IDs
from_dir_id=$(ce_addDir.sh "$db" "$from_dirname")
to_dir_id=$(ce_addDir.sh "$db" "$to_dirname")

file_id=$(sqlite3 "$db" "
  SELECT file_id FROM FILE
  WHERE filename='$from_filename'
  AND dir_id='$from_dir_id';
  "
)
if [ ! "$file_id" ]; then
  echo "ERROR: file ID was not found in the database" >&2
  exit 1
fi

# Some internal sanity checks should be made in this script: md5sum and filesize
filesize=$(wc -c < "$path")
md5sum=$(md5sum < "$path" | awk '{print $1}')
dbMd5sum=$(sqlite3 "$db" "
  SELECT md5sum FROM FILE
  WHERE filename='$from_filename';
  "
)
dbFilesize=$(sqlite3 "$db" "
  SELECT filesize FROM FILE
  WHERE filename='$from_filename';
  "
)

if [ "$filesize" != "$dbFilesize" ]; then
  echo "ERROR: cannot move the file because the file size does not match. Should be $dbFilesize but is $filesize" >&2
  exit 1
fi
if [ "$md5sum" != "$dbMd5sum" ]; then
  echo "ERROR: cannot move the file because the md5sum does not match. Should be $dbMd5sum but is $md5sum." >&2
  exit 1
fi

# Make sure the destination file does not exist
if [ -e "$newpath" ]; then
  echo "ERROR: destination already exists!" >&2
  exit 1
fi
# See if the destination dir is writable
if [ ! -w "$to_dirname" ]; then
  echo "ERROR: cannot write to the destination directory!" >&2
  exit 1
fi


# File table
sqlite3 "$db" "
  PRAGMA foreign_keys=ON;
  UPDATE FILE
  SET   dir_id='$to_dir_id',
        filename='$to_filename'
  WHERE filename='$from_filename'
  AND   dir_id='$from_dir_id';
"

# Insert a new file operation
op_id=$(
  sqlite3 "$db" "
    PRAGMA foreign_keys=ON;
    INSERT INTO OPERATION(file_id, date, time, operation, to_name, to_dir)
      VALUES ($file_id, 
        (SELECT DATE('now','localtime')), 
        (SELECT TIME('now','localtime')),
        (SELECT op_enum_id FROM OPERATION_ENUM WHERE operation='mv'),
        '$to_filename', $to_dir_id
      );
  "
);

# Move the file
mv -nv "$path" "$newpath" >&2

# Print the operations ID
echo "$op_id"

