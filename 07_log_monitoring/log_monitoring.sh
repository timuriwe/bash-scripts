#!/bin/bash

function sort_by_response_code {
  echo "Enter response code:"
  read response_code
  awk '{if ($7 == '$response_code') print $0}' ${directory}*.log
}

function get_unique_ip {
  awk '{print $1}'  ${directory}*.log | sort --unique
}

function get_requests_with_errors {
  awk '{if ($7 >= 400 && $7 < 600) print $9}'  ${directory}*.log
}

function get_unique_ip_with_error_requests {
  awk '{if ($7 >= 400 && $7 < 600) print $1}'  ${directory}*.log | sort --unique
}

if [ $# -gt 1 ] || ! [[ $1 =~ ^[1-4]$ ]]
then
	echo "Invalid input!"
	echo "You must enter output parameter:"
	echo "1. All entries sorted by response code"
  echo "2. All unique IPs found in the entries"
  echo "3. All requests with errors (response code - 4xx or 5xx)"
  echo "4. All unique IPs found among the erroneous requests"
else
  echo "Enter path to directory with logs:"
  read directory
  
  if ! [[ $directory =~ /$ ]]
  then
    directory="$directory/"
  fi

  if [[ -d $directory ]]
  then
    if [ $1 -eq 1 ]
    then
	    sort_by_response_code
    elif [ $1 -eq 2 ]
    then
	    get_unique_ip
    elif [ $1 -eq 3 ]
    then
	    get_requests_with_errors
    elif [ $1 -eq 4 ]
    then
      get_unique_ip_with_error_requests
    fi
  else
    echo "This directory does not exist"
  fi
fi
