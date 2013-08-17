#!/bin/bash
for f in 1 2 3 4 5 6 7
do  
	if [ "$f" -eq "4" ]
	then 
		sleep 0.2 
	else  
		beep -f 1700 -l 60 -n -f 1000 -l 80 
	fi 
done

