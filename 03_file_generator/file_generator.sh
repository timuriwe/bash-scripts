#!/bin/bash

function check_input {
  local flag=0
  
  if [ ! -d $1 ]
  then
  	echo "Directory $1 does not exist"
  elif ! [[ $2 =~ ^[0-9]+$ ]]
  then
  	echo "$2 in not a number"
  elif ! [[ $3 =~ ^[a-zA-Z]+$ ]]
  then
  	echo "$3 in not a list of alphabet letters"
  elif [ ${#3} -gt 7 ]
  then
  	echo "$3 is more then 7 characters"
  elif ! [[ $4 =~ ^[0-9]+$ ]]
  then
  	echo "$4 in not a number"
  elif ! [[ $5 =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]
  then
  	echo "$5 must be no more than 7 characters for the name and no more than 3 characters for the extension"
  elif ! [[ $6 =~ ^[0-9]+kb$ ]]
  then
  	echo "$6 must be size in kilobytes"
  elif [ $(echo "$6" | grep -o -e "^[0-9]*") -gt 100 ]
  then
  	echo "$6 is more than 100kb"
  else
    flag=1
  fi

  return $flag
}

function check_names {
  local DIRNAME_LENGTH=$(echo -n "$NAMES_OF_SUBDIR" | wc -c)
  LAST_DIRNAME_CHAR=${NAMES_OF_SUBDIR: -1}

  if [ $DIRNAME_LENGTH -lt 4 ]
  then
    for ((k=0; k<$(( 4 - $DIRNAME_LENGTH )); k++))
    do
      NAMES_OF_SUBDIR=${NAMES_OF_SUBDIR}${LAST_DIRNAME_CHAR}
    done
  fi

  local FILENAME_LENGTH=$(echo -n "$NAMES_OF_FILES" | wc -c)
  LAST_FILENAME_CHAR=${NAMES_OF_FILES: -1}

  if [ $FILENAME_LENGTH -lt 4 ]
  then
    for ((k=0; k<$(( 4 - $FILENAME_LENGTH )); k++))
    do
      NAMES_OF_FILES=${NAMES_OF_FILES}${LAST_FILENAME_CHAR}
    done
  fi
}

function create_files {
  for ((i=0; i<$NUM_OF_SUBDIR; i++))
  do
    local DIRNAME=$NAMES_OF_SUBDIR
    for ((j=0; j<i; j++))
    do
      DIRNAME=$DIRNAME$LAST_DIRNAME_CHAR
    done
    DIRNAME="${DIRNAME}_${DATE}"
    mkdir $MAIN_DIR/$DIRNAME
    
    for ((k=0; k<$NUM_OF_FILES; k++))
    do
      local FILENAME=$NAMES_OF_FILES
      for ((l=0; l<k; l++))
      do
        FILENAME=${FILENAME}${LAST_FILENAME_CHAR}
      done
      FILENAME="${FILENAME}.${FILE_EXTENSIONS}_${DATE}"
      fallocate -l $FILE_SIZE $MAIN_DIR/$DIRNAME/$FILENAME
      echo -e "$MAIN_DIR/$DIRNAME/$FILENAME \\t $(date +"%d/%m/%y %T") \\t $FILE_SIZE bytes" >> file_generator.log
      
      if [ $(df --block-size=GB / | tail -n 1 | awk '{print $4}' | grep -o [0-9]*) -le 1 ]
      then
        echo "There is 1GB of free space left on the file system"
        return 1
      fi

    done
  done
}

if ! [ $# -eq 6 ]
then
  echo "Invalid number of input values"
else
  check_input $1 $2 $3 $4 $5 $6
  
  if [ $? -eq 1 ]
  then
    MAIN_DIR=$1
    NUM_OF_SUBDIR=$2
    NAMES_OF_SUBDIR=$3
    NUM_OF_FILES=$4
    NAMES_OF_FILES=$(echo $5 | awk -F. '{print $1}')
    FILE_EXTENSIONS=$(echo $5 | awk -F. '{print $2}')
    FILE_SIZE=$(echo "$6" | grep -o -e "^[0-9]*")
    FILE_SIZE=$(( $FILE_SIZE * 1024 ))
    DATE=$(date +"%d%m%y")

    check_names
    create_files
  fi
fi
