#! /bin/sh
addEmptyClass() {
	local paires=""
	selected=""

	sort -n -k 1 -o usr/unselected.txt usr/unselected.txt
	sort -n -k 1 -o usr/selected.txt usr/selected.txt
	
	selected_time_all=""

	# initialize
	for num in $(seq 1 130); do
		eval unselected_arr${num}=""
		eval selected_arr${num}=""
	done

	while read item; do
		selected=${selected}" ${item}"
		class=$(eval echo \${totalArray${item}} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g') 
		eval selected_arr${item}="${class}"
		selected_time_all=${selected_time_all}" $(eval echo \${timeArray${item}})"
	done < usr/selected.txt

	while read item class; do
		class=$(echo "$class" | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g') 
		unselected_time=$(eval echo \${timeArray${item}})
	    
	    	conflict=1
	    	for t in ${unselected_time}; do
	    		for selected_time in ${selected_time_all}; do
	    			if [ ${t} = ${selected_time} ] ; then
	    				conflict=0
	    				break
    				fi
	    		done
	    		if [ ${conflict} = 0 ] ; then
	    			break
    			fi
    		done
    		if [ ${conflict} = 1 ] ; then
	    		eval unselected_arr${item}="${class}"
    		fi
	done < usr/unselected.txt

	for num in $(seq 1 130); do
		unselected_str="$(eval echo \${unselected_arr${num}})"
		selected_str="$(eval echo \${selected_arr${num}})"
		if [ -n "${unselected_str}" ] ; then
			unselected_str=$(echo ${unselected_str} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\\(/g' | sed 's/)/\\)/g')
			paires=${paires}" ${num} ${unselected_str} off"
		elif [ -n "${selected_str}" ] ; then
			selected_str=$(echo ${selected_str} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\\(/g' | sed 's/)/\\)/g')
			paires=${paires}" ${num} ${selected_str} on"
		fi
	done

	echo ${paires} | xargs dialog --stdout --buildlist "Add class" 50 150 30 > usr/new_selected.txt
	if [ $? != 0 ] ; then
		return 1
	fi
	
	for i in ${selected}; do
	    	skip=
		for j in ${new_selected}; do
	        	if [ ${i} = ${j} ] ; then
				skip=1
				break
			fi
	    	done
	    	if [ -e ${skip} ] ; then
		       	new_unselected=${new_unselected}" ${i}"
		fi
	done
	return 0
}
