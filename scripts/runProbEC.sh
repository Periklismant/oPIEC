#!/bin/bash
# This script runs Prob-EC--oPIEC for the application specified in ${ApplicationName}. 
# Currently supported applications: "caviar", "maritime"

applicationName="maritime" #"caviar"
streamFileName="test"
loader="../applications/${applicationName}/loader.pl"
stream="../applications/${applicationName}/datasets/${streamFileName}.pl"

problog ../src/Prob-EC/probec.pl -a loader -a stream > ../Prob-EC_output/raw/${fileName}.result && # Change input files from 'er_prob_orig_cached.pl'
#./fixoutput.sh ".." "meeting,moving" "true,true" ${fileName} &&
#cd ../src/oPIEC-python/ &&
#python oPIEC.py ${fileName}_meeting_true && # Execute oPIEC for both events.
#python oPIEC.py ${fileName}_moving_true 