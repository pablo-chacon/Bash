#!/bin/bash

# Clear cache and clean up before shutdown.

# Author: ekarlsson66@gmail.com
# Date: 2020-01-20
# Version: 002


# Service file content:  
#[Unit]
#Description=Before Shutting Down
#
#[Service]
#Type=oneshot
#RemainAfterExit=true
#ExecStart=/bin/true
#ExecStop=/local/bin/clean-up.sh
#
#[Install]


drop="/proc/sys/vm/drop_caches"
shtdwn="/etc/systemd/system/beforeshutdown.service"
ctl=$(systemctl)
content="""
[Unit]
Description=Before Shutting Down

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/local/home/clearcache.sh

[Install]"""


if [ -f "$shtdwn" ]; then

	"$ctl" status "$shtdwn"; if true; then
		sync; echo 1 > "$drop"
		echo 2 > "$drop"
		sync; echo 3 > "$drop"

		apt upgrade -y
		apt clean -y
		
		exit 0;
	
	fi

else

	echo "$content" > "$shtdwn"

	"$ctl" daemon-reload
	"$ctl" enable beforeshutdown.service
	"$ctl" start beforeshutdown.service

	sync; echo 1 > "$drop"
	echo 2 > "$drop"
	sync; echo 3 > "$drop"

	apt upgrade +y -y
	apt autoremove -y

	exit 0;

fi



