#!/bin/bash

tests=($(ls -d */))
for testID in "${tests[@]}"; do 
  echo "${testID}"
  applicationName="toy"
  stream="../../unit_tests/oPIEC/${applicationName}/${testID}datastream.input"
  loader="../../applications/${applicationName}/loader.pl"

  time 

  if diff -w -B "${testID}test.result" ${testID}correct.result > /dev/null
  then
    echo "${applicationName} ${testID}: Correct.";
  else
    echo "${applicationName} ${testID}: Error.";
    echo  "`diff -w -B "${testID}test.result" ${testID}correct.result`" 
  fi
done
