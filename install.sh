#!/bin/bash
### RTEC installation steps ###

## Create oPIEC_scripts package by changing the file structure *temporarily*.

mkdir oPIEC_scripts
touch oPIEC_scripts/__init__.py
cp src/oPIEC-python/*.py oPIEC_scripts
mkdir oPIEC_scripts/scripts
cp scripts/oPIEC_cli.py oPIEC_scripts/scripts 

## Then, create the temporary Prob-EC package
mkdir Prob-EC
touch Prob-EC/__init__.py
cp src/Prob-EC/*.pl Prob-EC/

## Install RTEC via setuptools.
machine="$(uname -s)"
if [[ "$machine" == "Linux"* ]] || [[ "$machine" == "Darwin"* ]]; then
	pip3 install .
elif [[ "$machine" == "CYGWIN"* ]] || [[ "$machine" == "MINGW"* ]]; then
	py -m pip install .
fi

## Add the installation path of RTEC to $PATH. 
#echo $PATH
#NewPath=`python3 -m site --user-base`/bin
if [[ "$machine" == "Linux"* ]] || [[ "$machine" == "Darwin"* ]];  then
	NewPath=`python3 -m site --user-base`/bin
elif [[ "$machine" == "CYGWIN"* ]] || [[ "$machine" == "MINGW"* ]]; then
	NewPath=`py -m site --user-base`/bin
fi

#echo $NewPath
case :$PATH:
	in *:$NewPath:*) ;;
		*) export PATH=$PATH:$NewPath;;
esac
#if [[ $PATH == ?(*:)$NewPath?(:*) ]]; then
#	echo "Path already present."
#else
#	export PATH=$PATH:$NewPath
#	echo "Path updated."
#fi
#echo $PATH

## Revert the changes in the file structure.
rm -rf oPIEC_scripts
rm -rf Prob-EC
