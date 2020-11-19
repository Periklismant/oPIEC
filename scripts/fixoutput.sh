#!/bin/bash
#Reads the recognition of Prob-EC (in /Prob-EC_output/preprocessed/), separates it by fluent and writes the recognition of each fluent in a new separate files (in /Prob-EC_output/recognition/). 

IFS=',' read -r -a events <<< "$1"
IFS=',' read -r -a values <<< "$2"
fileName="$3"
pythonVersion="$4"

cd ../Prob-EC_output/raw &&
sed -i 's/"//g; s/ //g' ${fileName}.result &&
LastIndex=$((${#events[@]}-1))

for i in $(seq 0 ${LastIndex}) #${0..${LastIndex}}
do
	sed  '/'${events[$i]}\([^\)]*\)\=${values[$i]}'/!d' ${fileName}.result > ../preprocessed/${fileName}_${events[$i]}_${values[$i]}.pl
done &&
cd ../../scripts 
