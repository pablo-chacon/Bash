#!/bin/bash

# Create a tmp file to work with. reorder columns. 
# Identify MAC addresses, remove identifier "-". 
# UTF-8 encode, Self sustaining script.  
# 
# Author: ekarlsson66@gmail.com
# Version: 3.2
# Date: 2019-12-03

# In MAC addresses format: "000b-abe3-a2df"
# Out MAC addresses: "AA:BB:CC:DD:EE:FF" (Work in progress).
# Identify MAC addresses, remove "-".
# Read target file as a table, reorder column 1, 2. 
# Create tmp table file. 
# UTF-8 encode, save as csv.
# MAC address formating. Last attempt: | sed 's!\(..\)!\1:!g;'.


function read_table()
{
while read F
do 
     
    echo "$F" | grep ^"\d"  

done
}


cat $1 | sed 's![-]!!g;s!:$!!' | sort -u -k2 \
| awk '{ print $2" ; "$1 }' > "/tmp/mac.txt"
 
cat /tmp/mac.txt | iconv -f ISO-8859-1 -t UTF-8  &> "mac.csv" 

rm -rf "/tmp/mac.txt"


exit 0;   








