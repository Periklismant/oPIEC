#!/bin/bash

#events=("meeting" "moving")
#values=("true" "true")
#fileName="Walk1-smooth-1.0"
#events=("loitering")
#values=("true")
#fileName="loitering_test"
#pythonVersion="3.8"

IFS=',' read -r -a events <<< "$1"
IFS=',' read -r -a values <<< "$2"
fileName="$3"
pythonVersion="$4"

cd ../Prob-EC_output/preprocessed &&
sed -i 's/"//g; s/ //g' ${fileName}.result &&
LastIndex=$((${#events[@]}-1))

for i in $(seq 0 ${LastIndex}) #${0..${LastIndex}}
do
	sed  '/'${events[$i]}\([^\)]*\)\=${values[$i]}'/!d' ${fileName}.result > ../recognition/${fileName}_${events[$i]}_${values[$i]}.pl
done &&
cd ../../scripts 
