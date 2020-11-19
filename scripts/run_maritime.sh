#!/bin/bash
# This script runs Prob-EC--oPIEC for the maritime monitoring example.
# Currently, there are two datasets available in '/inputDatasets/examples/':
# - maritime.pl includes two weeks of data for two vessels.
# - maritime_short.pl includes about 18h of data for the same two vessels.
# This examples computes the probability of 'loitering' and 'rendezVous' for all vessels at each time-point.
# The user may add/change the target events from the ${events} list. 
# Be careful to add/change the corresponding values of fluents from the ${values} list.
# Examine /src/Prob-EC/maritime/event_description to find the available fluent-value pairs.

## General Parameters (Adjust for custom input file or target events) ##
fileName="maritime_test" # Name for the result file of Prob-EC/oPIEC.
pythonVersion="3.8" # Insert the python to which you installed the packages for oPIEC (e.g. intervaltree). 
					# If you are using Python 3 and have only version of python installed, pythonVersion="3" should work fine. 
inputPath="../../../inputDatasets/examples/maritime_short.pl" # input path for Prob-EC. 
events=("loitering" "rendezVous") # List of target fluents.
values=("true" "true") # And the respective target value.

eventsString=$(IFS=','; echo "${events[*]}")
valuesString=$(IFS=','; echo "${values[*]}")


for i in "${events[@]}"
do
	eventParam="${eventParam} -a $i"
done &&
problog ../src/Prob-EC/maritime/er_prob_maritime_cached.pl -a ${inputPath} ${eventParam} > ../Prob-EC_output/preprocessed/${fileName}.result && # runs Prob-EC.
./fixoutput.sh ${eventsString} ${valuesString} ${fileName} ${pythonVersion} && # Seperate events from Prob-EC output. Results in the 'Prob-EC_output/recognition/' folder. 
cd ../src/oPIEC-python/ &&
LastIndex=$((${#events[@]}-1)) &&
for i in $(seq 0 ${LastIndex}) # Execute oPIEC for all target events.
do 
	python${pythonVersion} oPIEC.py ${fileName}_${events[i]}_${values[i]} # Adjust the parameters of oPIEC from /src/oPIEC-python/oPIEC.py
done