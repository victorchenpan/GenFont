#!/bin/bash

echo "Generate Unicode font in conmon use from full font..."
echo "Usage: $0 unicode3500.txt font.bdf outfile.bdf"

#get unicode of fonts which in need
UNICODE_ARRAY=(`cat $1`)

FETCH_STRING_START="STARTCHAR"
FETCH_STRING_END="ENDCHAR"

fetch_flag=0
unicode_index=0
cur_unicode=${UNICODE_ARRAY[$unicode_index]}
#echo "cur_unicode $cur_unicode"
#the total num of had convert fonts
convert_sum=0

function getNextUnicode()
{
	let unicode_index++
	cur_unicode=${UNICODE_ARRAY[$unicode_index]}
	echo "Next unicode: U_$cur_unicode"
}


function isFetchedStart()
{
	args=$*
	#echo $args
	for string in $args
	do
		if [ "$string" == "$FETCH_STRING_START" ]
			then
			let fetch_flag=1
		fi
	done
	return $fetch_flag
}

end_flag=0
function isFetchedEnd()
{
	args=$*

	for string in $args
	do
		if [ "$string" == "$FETCH_STRING_END" ]
			then
			let fetch_flag=0
			let end_flag=1
		fi
	done
}

need_copy=0
function isMatchTheUnicode()
{
	args=$*
	retval=0
	#echo "U_$cur_unicode"
	unicode=`echo "U_$cur_unicode"|sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
	unicode=${unicode:0:6}

	for string in $args
	do
		str="`echo "$string"|sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`"

		if [ $unicode = $str ]
			then
			echo "match $unicode"
			let retval=1
			let need_copy=1
			let end_flag=0
			let convert_sum++
			break
		fi
	done
	return $retval
}

line_index=1
while read line
do
	echo "$line_index"
	let line_index++
	if [ $fetch_flag == 0 ]
		then
		isFetchedStart $line
	fi

	# check if cur_unicode is in current line
	if [ $fetch_flag == 1 ]
		then
		isMatchTheUnicode $line
	fi

	if [[ $fetch_flag == 1 && $need_copy == 1 ]]
		then	
		echo $line >> $3
	fi

	# check if the line is current font end
	if [ $need_copy == 1 ]
		then
		isFetchedEnd $line
		if [ $end_flag == 1 ]
			then
			let	need_copy=0
			getNextUnicode
		fi
	fi
done < $2

echo "ENDFONT" >> $3
echo "******* Finish ... Have convert $convert_sum fonts ********"
