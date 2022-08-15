#!/bin/bash
TIME_START=$(date +"%s.%N")

function check_input {
  local flag=0
  
  if ! [[ $1 =~ ^[a-zA-Z]+$ ]]
  then
  	echo "$1 in not a list of alphabet letters"
  elif [ ${#1} -gt 7 ]
  then
  	echo "$1 is more then 7 characters"
  elif ! [[ $2 =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]
  then
  	echo "$2 must be no more than 7 characters for the name and no more than 3 characters for the extension"
  elif ! [[ $3 =~ ^[0-9]+Mb$ ]]
  then
  	echo "$3 must be size in Megabytes"
  elif [ $(echo "$3" | grep -o -e "^[0-9]*") -gt 100 ]
  then
  	echo "$3 is more than 100Mb"
  else
    flag=1
  fi

  return $flag
}

function generate_values {
  RANDOM_LINE=$(shuf -i 1-$NUMBER_OF_LINES -n 1)
  MAIN_DIR=$(awk 'NR=='$RANDOM_LINE'{print $0}' directories.list)
  NUM_OF_SUBDIR=$(( $RANDOM % 100 ))
  NUM_OF_FILES=$(( $RANDOM % 200 ))
}

function check_names {
  local DIRNAME_LENGTH=$(echo -n "$NAMES_OF_SUBDIR" | wc -c)
  LAST_DIRNAME_CHAR=${NAMES_OF_SUBDIR: -1}

  if [ $DIRNAME_LENGTH -lt 5 ]
  then
    for ((k=0; k<$(( 5 - $DIRNAME_LENGTH )); k++))
    do
      NAMES_OF_SUBDIR=${NAMES_OF_SUBDIR}${LAST_DIRNAME_CHAR}
    done
  fi

  local FILENAME_LENGTH=$(echo -n "$NAMES_OF_FILES" | wc -c)
  LAST_FILENAME_CHAR=${NAMES_OF_FILES: -1}

  if [ $FILENAME_LENGTH -lt 5 ]
  then
    for ((k=0; k<$(( 5 - $FILENAME_LENGTH )); k++))
    do
      NAMES_OF_FILES=${NAMES_OF_FILES}${LAST_FILENAME_CHAR}
    done
  fi
}

function create_files {
  for (( ; ; ))
  do
    generate_values
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

        FILENAME="${FILENAME}_${DATE}.${FILE_EXTENSIONS}"
        fallocate -l ${FILE_SIZE}MB $MAIN_DIR/$DIRNAME/$FILENAME
        echo -e "$MAIN_DIR/$DIRNAME/$FILENAME \\t $(date +"%d/%m/%y %T") \\t $FILE_SIZE Mb" >> file_generator.log

        if [ $(df --block-size=GB / | tail -n 1 | awk '{print $4}' | grep -o [0-9]*) -le 1 ]
        then
          echo "There is 1GB of free space left on the file system"
          return 1
        fi

      done
    done
  done
}

if ! [ $# -eq 3 ]
then
  echo "Invalid number of input values"
else
  check_input $1 $2 $3
  
  if [ $? -eq 1 ]
  then
    find / -type d | grep -v -e /sbin -e /bin > directories.list
    NUMBER_OF_LINES=$(wc -l directories.list | awk '{print $1}')

    NAMES_OF_SUBDIR=$1
    NAMES_OF_FILES=$(echo $2 | awk -F. '{print $1}')
    FILE_EXTENSIONS=$(echo $2 | awk -F. '{print $2}')
    FILE_SIZE=$(echo "$3" | grep -o -e "^[0-9]*")
    DATE=$(date +"%d%m%y")

    check_names
    create_files

    rm directories.list

    TIME_END=$(date +"%s.%N")
    echo -ne "\\nScript execution time: "
    awk BEGIN'{printf "%0.3f seconds\n", '$TIME_END'-'$TIME_START'}'

    echo -ne "### Script execution time: " >> file_generator.log
    awk BEGIN'{printf "%0.3f seconds", '$TIME_END'-'$TIME_START'}' >> file_generator.log
		
  fi
fi
