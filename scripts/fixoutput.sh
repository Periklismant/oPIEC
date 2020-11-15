events=("meeting" "moving")
fileName="Walk1-smooth-1.0"

cd ../Prob-EC_output &&
sed -i 's/"//g; s/ //g' ${fileName}.result &&
LastIndex=$((${#events[@]}-1))
echo ${LastIndex}
for i in $(seq 0 ${LastIndex}) #${0..${LastIndex}}
do
	sed  '/'${events[$i]}\([^\)]*\)\=${values[$i]}'/!d' ${fileName}.result > ${fileName}_${events[$i]}.pl
done
