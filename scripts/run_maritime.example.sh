

fileName="maritime_test"
pythonVersion="3.8"
inputPath="../../../inputDatasets/examples/maritime_short.pl"
events=("loitering")
values=("true")

for i in "${events[@]}"
do
	eventParam="${eventParam} -a $i"
done &&
#problog ../src/Prob-EC/maritime/er_prob_maritime_cached.pl -a ${inputPath} ${eventParam} > ../Prob-EC_output/preproccessed/${fileName}.result && #Change input files from code
./fixoutput.sh ${events} ${values} ${fileName} ${pythonVersion} &&
cd ../src/oPIEC-python/ &&
LastIndex=$((${#events[@]}-1)) &&
for i in $(seq 0 ${LastIndex})
do 
	python${pythonVersion} oPIEC.py ${fileName}_${events[i]}_${values[i]}
done