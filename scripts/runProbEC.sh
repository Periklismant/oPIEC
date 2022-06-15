#!/bin/bash
# This script runs Prob-EC--oPIEC for the application specified in ${ApplicationName}. 
# Currently supported applications: "caviar", "maritime"

applicationName="maritime" # "caviar" or "maritime"
streamFileNamePrefix="Brest_with_noise_preprocessed/Brest_" #"original_smooth_1.0" #"Brest_with_noise_preprocessed/Brest_10000_one_day"
#eventNos=(250 500 1000 2000)
for eventNo in $1 #250 #500 1000 2000
do 
	streamFileName=${streamFileNamePrefix}${eventNo}_filtered2
	resultFileName=${applicationName}_${eventNo}
	echo $streamFileName
	loader="../../applications/${applicationName}/loader.pl" #loader-no-caching.pl"
	stream="../../applications/${applicationName}/datasets/${streamFileName}.pl"

	time problog ../src/Prob-EC/probec.pl -a ${loader} -a ${stream}  > ${resultFileName}.result
	sed -i 's/"//g; s/ //g' ${resultFileName}.result 
	python3 cut_decimals.py ${resultFileName}.result ${resultFileName}-comp.result
done
