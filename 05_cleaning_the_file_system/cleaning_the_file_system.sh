#!/bin/bash

function remove_by_log {
	echo "Enter the log file:"
	read log_file

	if [ -f $log_file ] 
		then
			for file in $(awk '{ if ($1 != "###") print $1}' $log_file)
		do
			rm -rf $(dirname $file)
		done
	else
		echo "This file does not exist"
	fi
}

function remove_by_time {
	echo "Enter start time in format 'YYYY-MM-DD hh:mm':"
	read start_time
	echo "Enter end time in format 'YYYY-MM-DD hh:mm':"
	read end_time
 
	find / -type d -regextype posix-egrep\
				 -regex ".*/[A-z]{5,}_[0-9]{6}"\
				 -newerat "$start_time" -not -newerat "$end_time"\
				 -exec rm -rf {} \;
}

function remove_by_mask {
	echo "Enter folder mask ('chars_ddmmyy')"
	read mask
	
	if [[ $mask =~ ^[A-z]{1,7}_[0-9]{6}$ ]]
	then
		chars=$(echo $mask | awk -F_ '{print $1}')
		date=$(echo $mask | awk -F_ '{print $2}')

		find / -type d -regextype posix-egrep\
					 -regex ".*/${chars}+_${date}"\
					 -exec rm -rf {} \;
	else
		echo "Invalid mask"
	fi
}

if [ $# -gt 1 ] || ! [[ $1 =~ ^[1-3]$ ]]
then
	echo "Invalid input!"
	echo "You must write method of removing files after file generation :"
	echo "1. By log file"
  echo "2. By creation date and time"
  echo "3. By name mask (i.e. characters, underlining and date)."
elif [ $1 -eq 1 ]
then
	remove_by_log
elif [ $1 -eq 2 ]
then
	remove_by_time
elif [ $1 -eq 3 ]
then
	remove_by_mask
fi
