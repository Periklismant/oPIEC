#!/bin/bash
# This script runs Prob-EC--oPIEC for the application specified in ${ApplicationName}. 
# Currently supported applications: "caviar", "maritime"

applicationName=$1 # "caviar" or "maritime"
streamFile=$2 # path to input event narrative

streamFileName=${streamFileNamePrefix}${eventNo}_filtered2
	resultFileName=${applicationName}_${eventNo}
	echo $streamFileName
	loader="../../applications/${applicationName}/loader.pl" #loader-no-caching.pl"
	stream="../../applications/${applicationName}/datasets/${streamFileName}.pl"

	time problog ../src/Prob-EC/probec.pl -a ${loader} -a ${stream}  > ${resultFileName}.result
	sed -i 's/"//g; s/ //g' ${resultFileName}.result 
	python3 cut_decimals.py ${resultFileName}.result ${resultFileName}-comp.result
