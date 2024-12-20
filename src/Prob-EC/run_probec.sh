#!/bin/bash

Application=$1
Dataset=$2
Events=$3
Values=$4

problog probec.pl -a ../../applications/${Application}/loader.pl -a ../../applications/${Application}/datasets/${Dataset}.pl  > ../../results/Prob-EC_output/raw/${Dataset}.result
#Reads the recognition of Prob-EC (in /Prob-EC_output/preprocessed/), separates it by fluent and writes the recognition of each fluent in a new separate files (in /Prob-EC_output/recognition/). 

#repoPath="$1"
IFS=',' read -r -a events <<< "${Events}"
IFS=',' read -r -a values <<< "${Values}"

sed -i 's/"//g; s/ //g' ../../results/Prob-EC_output/raw/${Dataset}.result
LastIndex=$((${#events[@]}-1))

for i in $(seq 0 ${LastIndex}) #${0..${LastIndex}}
do
	sed  '/'${events[$i]}\([^\)]*\)\=${values[$i]}'/!d' ../../results/Prob-EC_output/raw/${Dataset}.result > ../../results/Prob-EC_output/preprocessed/${Dataset}_${events[$i]}_${values[$i]}.pl
done
