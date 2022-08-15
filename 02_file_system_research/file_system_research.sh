#!/bin/bash

TIME_START=$(date +"%s.%N")
dir=$1

function top_folders {
  echo -n "Total number of folders, including subfolders: "
  find $dir -type d | wc -l

  echo -e \\n"Top 5 folders with largest size in descending order: "
  find $dir -type d -exec du -s {} \; | sort -nr | head -n 6 | awk '{print $2}' >top_folders.tmp

  for ((i = 1; i <= 5; i++)); do
    folder=$(awk 'NR == '$(($i + 1))'' top_folders.tmp)
    if [[ -n $folder ]]; then
      echo -ne " $i) "
      echo -n "${folder}/   "
      echo $(du -sh $folder | awk '{print $1}')
    fi
  done

  rm top_folders.tmp
}

function find_files {
  echo -ne "\\nTotal number of files: "
  find $dir -type f | wc -l

  find $dir -type f -exec file {} \; >list_of_files.tmp

  echo -e "\\nNumber of:"

  echo -n " Configuration files = "
  find $dir -name "*.conf" | wc -l

  echo -n " Text files = "
  grep -c "text" list_of_files.tmp

  echo -n " Executable files = "
  find $dir -executable -type f | wc -l

  echo -n " Log files = "
  find $dir -name "*.log" | wc -l

  echo -n " Archive files = "
  grep -c "archive" list_of_files.tmp

  echo -n " Symbolic links = "
  ls -Rl $dir | grep ^l | wc -l

  rm list_of_files.tmp
}

function top_files {
  find $dir -type f -exec du {} \; | sort -nr | head -n 10 | awk '{print $2}' >top_files.tmp

  echo -e "\\nTop files of maximum size:"

  for ((i = 1; i <= 10; i++)); do
    filename=$(awk 'NR == '$i'' top_files.tmp)
    if [[ -n $filename ]]; then
      echo -n " $i) "
      echo -n $filename
      echo -n "   "
      echo -n $(du -h "$filename" | awk '{print $1}')
      echo "   ${filename##*.}"
    fi
  done

  rm top_files.tmp
}

function top_executable {
  find $dir -type f -executable -exec du {} \; | sort -nr | head -n 10 | awk '{print $2}' >top_executable.tmp

  echo -e "\\nTop executable files of maximum size:"
  for ((i = 1; i <= 10; i++)); do
    filename=$(awk 'NR == '$i'' top_executable.tmp)
    if [[ -n $filename ]]; then
      echo -n " $i) "
      echo -n $filename
      echo -n "   "
      echo -n $(du -h "$filename" | awk '{print $1}')
      echo -n "   "
      echo $(md5sum $filename | awk '{print $1}')
    fi
  done

  rm top_executable.tmp
}

if [ $# -ne 1 ]; then
  echo "Invalid number of parameters!"
  echo "You need to use 1: path to a directory"
elif [[ $dir =~ /$ ]] && [ -d $dir ]; then
  top_folders
  find_files
  top_files
  top_executable

  TIME_END=$(date +"%s.%N")
  echo -ne "\\nScript execution time: "
  awk BEGIN'{printf "%0.3f seconds\n", '$TIME_END'-'$TIME_START'}'
else
  echo "Folder $1 does not exist"
fi
