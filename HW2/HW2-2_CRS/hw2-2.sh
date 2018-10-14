#!/bin/bash

source prepareClassinfo.sh
source printTimetable.sh
source selectClass.sh
source options.sh

initUserData
initOption

loadOptions

while true; do
	printTable
	state=$(cat usr/state.txt)
	case ${state} in
		0) # add class
			while true; do
				addClass
				if [ $? != 0 ] ; then # cancel
					break
				fi
				checkCollision
				showCollision
				if [ $? = 1 ] ; then # no collision
					break
				fi 
			done
		;;
		3) # options
			optionWin
			loadOptions
		;;
		2) # exit
			exit 0
		;;
	esac
done