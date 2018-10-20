addEmptyClass() {
	local paires=()
	selected=()
	new_unselected=()
	unselected_arr=()
	selected_arr=()


	sort -n -k 1 -o usr/unselected.txt usr/unselected.txt
	sort -n -k 1 -o usr/selected.txt usr/selected.txt
	
	selected_time_all=()

	while read item; do
		selected+=(${item})
		class=$(echo "${totalArray[${item}]}" | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g') 
	    selected_arr[${item}]="${class}"
	    selected_time_all+=" ${timeArray[${item}]}"
	done < usr/selected.txt

	while read item class; do
		class=$(echo "$class" | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g') 
	    unselected_time=${timeArray[${item}]}
	    
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
	    	unselected_arr[${item}]="${class}"
    	fi
	done < usr/unselected.txt

	for num in {1..130}; do
		if [ -n "${unselected_arr[${num}]}" ] ; then
			paires+=(${num} ${unselected_arr[${num}]} off)
		elif [ -n "${selected_arr[${num}]}" ] ; then
			paires+=(${num} ${selected_arr[${num}]} on)
		fi
	done

	echo ${paires[@]} | xargs dialog --stdout --buildlist "Add class" 50 150 30 > usr/new_selected.txt
	if [ $? != 0 ] ; then
		return 1
	fi
	
	new_selected=`cat usr/new_selected.txt`

	for i in ${selected[@]}; do
	    skip=
	    for j in ${new_selected[@]}; do
	        [[ $i == $j ]] && { skip=1; break; }
	    done
	    [[ -n $skip ]] || new_unselected+=("${i}")
	done
	return 0
}