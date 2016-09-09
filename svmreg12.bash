#!/bin/bash

# svmreg12.bash

# This script should use a loop to call svmreg12.sql
./psqlmad -f svmreg11cr_pred.sql
for ((year=2000; year < 2017 ; year++))
do
  echo $year
  ./psqlmad -f svmreg12.sql -v tstyr=$year -v trainyrs=25 -v ma1=2 -v ma2=3 -v ma3=4 -v ma4=5
  ./psqlmad -f svmreg11collect_pred.sql
done

./psqlmad -f svmreg11rpt.sql

exit
