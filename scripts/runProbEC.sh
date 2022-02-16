#!/bin/bash
# This script runs Prob-EC--oPIEC for the application specified in ${ApplicationName}. 
# Currently supported applications: "caviar", "maritime"

applicationName="maritime" #"caviar"
streamFileName="Brest_10000_one_day"
loader="../../applications/${applicationName}/loader.pl"
stream="../../applications/${applicationName}/datasets/Brest_with_noise_preprocessed/${streamFileName}.pl"

problog ../src/Prob-EC/probec.pl -a ${loader} -a ${stream} > ${applicationName}.result
#./fixoutput.sh ".." "meeting,moving" "true,true" ${fileName} &&
#cd ../src/oPIEC-python/ &&
#python oPIEC.py ${fileName}_meeting_true && # Execute oPIEC for both events.
#python oPIEC.py ${fileName}_moving_true 
