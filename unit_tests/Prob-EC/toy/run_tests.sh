#!/bin/bash

tests=($(ls -d */))
for testID in "${tests[@]}"; do 
  echo "${testID}"
  applicationName="toy"
  stream="../../unit_tests/Prob-EC/${applicationName}/${testID}datastream.pl"
  loader="../../applications/${applicationName}/loader.pl"

  problog ../../../src/Prob-EC/probec.pl -a ${loader} -a ${stream} > "${testID}test.result"

  if diff -w -B "${testID}test.result" ${testID}correct.result > /dev/null
  then
    echo "${applicationName} ${testID}: Correct.";
  else
    echo "${applicationName} ${testID}: Error.";
    echo  "`diff -w -B "${testID}test.result" ${testID}correct.result`" 
  fi
done
