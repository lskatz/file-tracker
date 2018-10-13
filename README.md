# file-tracker
Track where your files have come from, where they're going to, where they are.  I am in process of converting this from the proof-of-concept shell scripts to a perl project.  Executable names will chance from the `ce_` prefix to something else in the future.

## Installation

Copy the files to your local drive and set your `PATH` to the scripts folder

## Examples

    ce_createDb.sh test.sqlite
    # Add three files
    for i in 1 2 3; do
      touch $i.txt
      ce_addFile.sh test.sqlite $i.txt
    done
    
    # Make a few move operations
    ce_mvFile.sh test.sqlite 1.txt 4.txt
    ce_mvFile.sh test.sqlite 4.txt 5.txt
    ce_mvFile.sh test.sqlite 5.txt 54.txt
    
    # check out the file's history
    ce_history.sh 54.txt
    # => should see a few entries describing previous names of the file
 
