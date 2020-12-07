#!/bin/bash
# This script runs Prob-EC--oPIEC for the human activity recognition example. 
# Currently, only the `moving' and `meeting' activities are supported.

fileName="caviar_test"
#pythonVersion="3.8" # Insert the python to which you installed the packages for oPIEC (e.g. intervaltree). 
					# If you are using Python 3 and have only version of python installed, pythonVersion="3" should work fine. 
ApperancePath="../../../datasets/examples/${fileName}/wk1gtAppearanceIndv_smooth.pbl"
MovementPath="../../../datasets/examples/${fileName}/wk1gtMovementIndv_smooth.pbl"


problog ../src/Prob-EC/caviar/er_prob_orig_cached.pl -a AppearancePath -a MovementPath > ../Prob-EC_output/raw/${fileName}.result && # Change input files from 'er_prob_orig_cached.pl'
./fixoutput.sh ".." "meeting,moving" "true,true" ${fileName} &&
cd ../src/oPIEC-python/ &&
python oPIEC.py ${fileName}_meeting_true && # Execute oPIEC for both events.
python oPIEC.py ${fileName}_moving_true 