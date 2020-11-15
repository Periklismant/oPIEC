#!/bin/bash

fileName="caviar_test"
pythonVersion="3.8"

#problog ../src/Prob-EC/caviar/er_prob_orig_cached.pl > ../Prob-EC_output/preproccessed/${fileName}.result && #Change input files from code
./fixoutput.sh "meeting,moving" "true,true" ${fileName} ${pythonVersion} &&
cd ../src/oPIEC-python/ &&
python${pythonVersion} oPIEC.py ${fileName}_meeting_true_id4_id5.input > ../../oPIEC_output/${fileName}_meeting_true_id4_id5.result &&
python${pythonVersion} oPIEC.py ${fileName}_moving_true_id4_id5.input > ../../oPIEC_output/${fileName}_moving_true_id4_id5.result