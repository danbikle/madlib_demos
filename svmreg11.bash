#!/bin/bash

# svmreg11.bash

# This script should use a loop to call svmreg11.sql

for ((year=2000; year < 2017 ; year++))
do
  echo $year
  ./psqlmad -f svmreg11.sql -v tstyr=$year -v trainyrs=30
done
exit
