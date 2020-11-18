

fileName="maritime_test" # Name for the result file of Prob-EC/oPIEC.
pythonVersion="3.8" # Insert the python to which you installed the packages for oPIEC (e.g. intervaltree). 
					# If you are using Python 3 and have only version of python installed, pythonVersion="3" should work fine. 
inputPath="../../../inputDatasets/examples/maritime_short.pl" # input path for Prob-EC.
events=("loitering") # List of target fluents.
values=("true") # And the respective target value.

for i in "${events[@]}"
do
	eventParam="${eventParam} -a $i"
done &&
problog ../src/Prob-EC/maritime/er_prob_maritime_cached.pl -a ${inputPath} ${eventParam} > ../Prob-EC_output/preprocessed/${fileName}.result && # runs Prob-EC.
./fixoutput.sh ${events} ${values} ${fileName} ${pythonVersion} && # Seperate events from Prob-EC output. Results in the 'Prob-EC_output/recognition/' folder. 
cd ../src/oPIEC-python/ &&
LastIndex=$((${#events[@]}-1)) &&
for i in $(seq 0 ${LastIndex}) # Execute oPIEC for all target events.
do 
	python${pythonVersion} oPIEC.py ${fileName}_${events[i]}_${values[i]}
done