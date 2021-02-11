#!/bin/bash

# Clean-up script runs before shutdown.
# Remove tmp, unused/unnecessary apt, flush logs and drop caches.
# Creates service file if it dont exists.

# Author: ekarlsson66@gmail.com
# Date: 2020-01-20
# Version: 002


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


function clean_up
{		
sync; echo 1 > "$drop" # Clear cache
echo 2 > "$drop"
sync; echo 3 > "$drop"

apt update && apt upgrade
	
apt autoremove -y # Remove unnecessary apt packages.

apt autoclean
	 	
find /tmp -type f -atime +10 -delete # Remove tmp files no access 10+ days.

rm -rf /var/log/* # Remove all logs.
}


if [ -f "$shtdwn" ]; then # If service file exists.
	
"$ctl" status "$shtdwn"; if true; then # Check service file status. 
		
	clean_up 
		
	else
		
	"$ctl" start beforeshutdown.service # Start service file.
		
	clean_up
	
	fi

	exit 0;

else

echo "$content" > "$shtdwn" # Create beforeshutdown.service file.

"$ctl" daemon-reload # Reload service file deamon.
"$ctl" enable beforeshutdown.service # Enable service file
"$ctl" start beforeshutdown.service # Start service. 

clean_up


exit 0;


fi

