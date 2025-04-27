#!/bin/bash

VMID=$1

send_command() {
  local cmd=$1
  for (( i=0; i<${#cmd}; i++ )); do
    char="${cmd:$i:1}"
    case "$char" in
      " ") key="spc" ;;
      "!") key="shift-1" ;;
      "\"") key="shift-apostrophe" ;;
      "#") key="shift-3" ;;
      "$") key="shift-4" ;;
      "%") key="shift-5" ;;
      "&") key="shift-7" ;;
      "'") key="apostrophe" ;;
      "(") key="shift-9" ;;
      ")") key="shift-0" ;;
      "*") key="shift-8" ;;
      "+") key="shift-equal" ;;
      ",") key="comma" ;;
      "-") key="minus" ;;
      ".") key="dot" ;;
      "/") key="slash" ;;
      "0") key="0" ;;
      "1") key="1" ;;
      "2") key="2" ;;
      "3") key="3" ;;
      "4") key="4" ;;
      "5") key="5" ;;
      "6") key="6" ;;
      "7") key="7" ;;
      "8") key="8" ;;
      "9") key="9" ;;
      ":") key="shift-semicolon" ;;
      ";") key="semicolon" ;;
      "<") key="shift-comma" ;;
      "=") key="equal" ;;
      ">") key="shift-dot" ;;
      "?") key="shift-slash" ;;
      "@") key="shift-2" ;;
      "A"|"B"|"C"|"D"|"E"|"F"|"G"|"H"|"I"|"J"|"K"|"L"|"M"|"N"|"O"|"P"|"Q"|"R"|"S"|"T"|"U"|"V"|"W"|"X"|"Y"|"Z")
        key="shift-${char,,}" ;;  # lowercase version
      "[") key="bracket_left" ;;
      "\\") key="backslash" ;;
      "]") key="bracket_right" ;;
      "^") key="shift-6" ;;
      "_") key="shift-minus" ;;
      "a"|"b"|"c"|"d"|"e"|"f"|"g"|"h"|"i"|"j"|"k"|"l"|"m"|"n"|"o"|"p"|"q"|"r"|"s"|"t"|"u"|"v"|"w"|"x"|"y"|"z")
        key="$char" ;;
      *) echo "Unsupported character: '$char'" >&2; return 1 ;;
    esac
    qm sendkey "$VMID" "$key"
    sleep 0.1
  done
  qm sendkey $VMID kp_enter
  sleep 0.5
}

send_command ""
send_command "root"
sleep 1
send_command "opnsense"
sleep 1
send_command "8"
sleep 1
send_command "mkdir -p /mnt/cdrom"
send_command "mount_cd9660 /dev/cd0 /mnt/cdrom"
send_command "cp /conf/config.xml /conf/config.xml.backup"
send_command "cp /mnt/cdrom/config.xml /conf/config.xml"
send_command "reboot"
