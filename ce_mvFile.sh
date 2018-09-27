#!/bin/bash

set -e

db=$1
path=$2
newpath=$3

set -u

if [ "$newpath" == "" ]; then
  echo "Moves or renames a file in the CE database. Also moves the file in the filesystem."
  echo "Usage: $0 database.sqlite path/to/file.fastq.gz new/path/to/file.fastq.gz"
  exit 0
fi

from_filename=$(basename $path)
from_dirname=$(dirname $path)
to_filename=$(basename $newpath)
to_dirname=$(dirname $newpath)

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

if [ "$filesize" -ne "$dbFilesize" ]; then
  echo "ERROR: cannot move the file because the file size does not match. Should be $dbFilesize but is $filesize"
  exit 1
fi
if [ "$md5sum" != "$dbMd5sum" ]; then
  echo "ERROR: cannot move the file because the md5sum does not match. Should be $dbMd5sum but is $md5sum."
  exit 1
fi

# Make sure the destination file does not exist
if [ -e "$newpath" ]; then
  echo "ERROR: destination already exists!"
  exit 1
fi
# See if the destination dir is writable
if [ ! -w "$to_dirname" ]; then
  echo "ERROR: cannot write to the destination directory!"
  exit 1
fi

exit 0

# Get the new directory ID
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
      INSERT INTO DIRECTORY(path)
        VALUES ('$dirname');

      SELECT last_insert_rowid();
    "
  )
fi

# File operation table

# Insert a new file operation

# Move the file

# Print the operations ID

