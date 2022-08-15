#!/bin/bash

# CHANGE TO YOUR NETWORK INTERFACE
network_interface=wlp4s0 # <------

function get_information {
  printf "%-18s" "HOSTNAME:"
  hostname
  printf "%-18s" "TIMEZONE:"
  echo $(timedatectl show --value | head -n 1) $(date +"UTC %-:::z")
  printf "%-18s" "USER:"
  whoami
  printf "%-18s" "OS:"
  cat /etc/issue.net

  printf "%-18s" "DATE:"
  date "+%d %B %Y %H:%M:%S"
  printf "%-18s" "UPTIME:"
  uptime -p
  printf "%-18s" "UPTIME_SEC:"
  cat /proc/uptime | awk '{print ($1)}'

  printf "%-18s" "IP:"
  ifconfig $network_interface | head -n 2 | tail -n 1 | awk '{print $2}'
  printf "%-18s" "MASK:"
  ifconfig $network_interface | head -n 2 | tail -n 1 | awk '{print $4}'
  printf "%-18s" "GATEWAY:"
  ip route | grep default | awk '{print $3}'

  printf "%-18s" "RAM_TOTAL:"
  ram_total=$(free --mega | grep Mem | awk '{print ($2)}')
  echo $ram_total | awk '{printf "%0.3fGB\n", ($1/1000) }'

  printf "%-18s" "RAM_USED:"
  ram_used=$(free --mega | grep Mem | awk '{print ($3)}')
  echo $ram_used | awk '{printf "%0.3fGB\n", ($1/1000) }'

  printf "%-18s" "RAM_FREE:"
  ram_free=$(free --mega | grep Mem | awk '{print ($4)}')
  echo $ram_free | awk '{printf "%0.3fGB\n", ($1/1000) }'

  printf "%-18s" "SPACE_ROOT:"
  space_root=$(df --block-size=KB / | tail -n 1 | awk '{print $2}')
  echo $space_root | awk '{printf "%0.2fMB\n", ($1/1000) }'

  printf "%-18s" "SPACE_ROOT_USED:"
  space_root_used=$(df --block-size=KB / | tail -n 1 | awk '{print $3}')
  echo $space_root_used | awk '{printf "%0.2fMB\n", ($1/1000) }'

  printf "%-18s" "SPACE_ROOT_FREE:"
  space_root_free=$(df --block-size=KB / | tail -n 1 | awk '{print $4}')
  echo $space_root_free | awk '{printf "%0.2fMB\n", ($1/1000) }'
}

if [ $# -eq 0 ]; then
  get_information
  echo -ne \\n"Do you want write the date to a file? [Y/n] "
  read answer

  if [ $answer = Y ] || [ $answer = y ]; then
    get_information >$(date +"%d_%m_%y_%H_%M_%S").status
  fi
else
  echo "Wrong input!"
fi
