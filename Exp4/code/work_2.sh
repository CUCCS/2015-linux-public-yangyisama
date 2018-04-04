#!bin/bash
TEMP=`getopt -o apng --long agerange,position,playername,playerage,help -n 'tsv.sh' -- "$@"`

function funAgeRange () 
{
	age=$(awk -F '\t' '{print $6}' worldcupplayerinfo.tsv)
	sum=0
	a=0
	b=0
	c=0

	for n in $age
	do
	    if [ "$n" != 'Age' ] ; then
      		let sum+=1

		if [ "$n" -lt 20 ] ; then 
		    let a+=1  
		fi

      		if [ "$n" -ge 20 ] && [ "$n" -le 30 ] ; then 
		    let b+=1  
		fi

      		if [ "$n" -gt 30 ] ; then 
		    let c+=1   
		fi

            fi
	done

	rate1=$(awk 'BEGIN{printf "%.3f",'"$a"*100/"$sum"'}')	 
	rate2=$(awk 'BEGIN{printf "%.3f",'"$b"*100/"$sum"'}')
	rate3=$(awk 'BEGIN{printf "%.3f",'"$b"*100/"$sum"'}')
	echo "---------------- # Age Statistics # --------------------"
	echo "--------------------------------------------------------"
	echo "|    Age     |    < 20    |    20 ~ 30    |    > 30    |"
	echo "--------------------------------------------------------"
	echo "|Total Number|     "$a"      |      "$b"      |    "$c"     |"
	echo "--------------------------------------------------------"
	echo "| Proportion |   "$rate1" "%"  |    "$rate2" "%"   |  "$rates3" "%"  |"
	echo "--------------------------------------------------------" 

}
function funPosition () {
	position=$(sed -n '2, $ p' worldcupplayerinfo.tsv | awk -F\\t '{print $5}' | sort | uniq -c | sort -nr | awk '{print $2}')
	positionArray=($position)

	amount=$(sed -n '2, $ p' worldcupplayerinfo.tsv | awk -F\\t '{print $5}' | sort | uniq -c | sort -nr | awk '{print $1}' )
	amountArray=($amount)
	total=0
	for i in $amount ; do
  		total=$(($total+$i))
	done

	echo "--------------- # Position Statistics # ----------------"
	echo "--------------------------------------------------------"
	i=0
	while [ $i -lt ${#positionArray[@]} ]; do

  		por=$(echo "scale=2; 100 * ${amountArray[${i}]} / $total" | bc)
  		echo "Position: ${positionArray[${i}]}"
	    echo "Number: ${amountArray[${i}]}"
	    echo "Proportion: $por%"
  		i=$(($i+1))
	done
}
function funPlayerName {

	longest=$(awk -F'\t' 'BEGIN{max=0}{if(length($9)>max){max=length($9);}}END{print max}' worldcupplayerinfo.tsv)
	long_names=$(awk -F'\t' 'BEGIN{longest='$longest';i=1}{if(length($9)==longest){name[i++]=$9}}END{for(n in name)print name[n]}' worldcupplayerinfo.tsv)
	shortest=$(awk -F'\t' 'BEGIN{min=100}{if(length($9)<min){min=length($9);}}END{print min}' worldcupplayerinfo.tsv)
    short_names=$(awk -F'\t' 'BEGIN{shortest='$shortest';i=1}{if(length($9)==shortest){name[i++]=$9}}END{for(n in name)print name[n]}' worldcupplayerinfo.tsv)
	
	echo "---- # the players whose name is longest----"
        echo "${long_names}"

	echo "--- # the players whose name is shortest---"
        echo "${short_names}"
}
function funPlayerAge {
	temp=$(sort -k6 worldcupplayerinfo.tsv| awk -F'\t' '{print $6 "\t" $9}'|head > target.txt)
 	min_names=$(more target.txt | awk -F'\t' 'BEGIN{min=100;i=1}{if(min>=$1){min=$1;name[i++]=$2}}END{for(n in name)print name[n]}')
	min=$(more target.txt | awk -F'\t' 'BEGIN{min=100;i=1}{if(min>=$1){min=$1}}END{print min}')
	echo "---- # the youngest players ("$min") # ----"
	echo "$min_names"

	temp=$(sort -k6 -nr worldcupplayerinfo.tsv| awk -F'\t' '{print $6 "\t" $9}'|head > target1.txt)
	max_names=$(more target1.txt | awk -F'\t' 'BEGIN{max=0;i=1}{if(max<=$1){max=$1;name[i++]=$2}}END{for(n in name)print name[n]}')
	max=$(more target1.txt | awk -F'\t' 'BEGIN{max=0;i=1}{if(max<=$1){max=$1}}END{print max}')
	echo "---- # the oldest players ("$max") # ----"
	echo "$max_names"
}
eval set -- "$TEMP"

while true ; do
    case "$1" in
    	-l|--all) funAgeRange;funPosition;funPlayerName;funPlayerAge; shift;;
        -a|--agerange) funAgeRange ; shift ;;
        -p|--position) funPosition ; shift ;;
        -n|--playername) funPlayerName ; shift ;;
        -g|--playerage) funPlayerAge ; shift ;;
        --help) echo -e "
Usage: bash tsv.sh [OPTIONS] [PARAMETER] \n
-a, --agerange          Statistics of the number of players in different age ranges (<20, [20-30], >30) and proportion\n
-p, --position          Statistics of the number of players in different positions and proportion\n
-n, --playername        Statistics of the longest and the shortest name of players\n
-g, --playerage         Statistics of the yongest and the oldest players\n
--help                  Ask for help\n"; shift ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done
