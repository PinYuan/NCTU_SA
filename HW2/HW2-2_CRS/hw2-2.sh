#!/bin/bash

source prepareClassinfo.sh
source printTimetable.sh
source selectClass.sh
source selectEmptyClass.sh
source options.sh
source search.sh

initUserData
initOption

loadOptions

while true; do
	printTable
	state=$(cat usr/state.txt)
	case ${state} in
		0) # add class
			searchOrNot
			if [ $? = 0 -a $(cat usr/searchWhich.txt) != 3 ] ; then
				if [ $(cat usr/searchWhich.txt) = 1 ] ; then
					searchByTime
				else
					searchByName
				fi
				rm usr/searchWhich.txt
			fi

			while true; do
				if [ ${options[3]} = 0 ] ; then
					addEmptyClass
				else
					addClass
				fi
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
			optionWindow
			loadOptions
		;;
		2) # exit
			exit 0
		;;
	esac
done