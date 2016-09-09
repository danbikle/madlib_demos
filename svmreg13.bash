#!/bin/bash

# svmreg13.bash

# This script should use a loop to call svmreg12.sql

# I should get prices:
curl http://ichart.finance.yahoo.com/table.csv?s=%5EGSPC > gspc.csv

./psqlmad -f svmreg11cr_pred.sql
for ((year=2014; year < 2017 ; year++))
do
  echo $year
  ./psqlmad -f svmreg13.sql -v tstyr=$year -v trainyrs=30 -v ma1=2 -v ma2=3 -v ma3=4 -v ma4=5 -v ma4=5 -v ma5=6 -v ma6=7 -v ma7=8 -v ma8=9
  ./psqlmad -f svmreg11collect_pred.sql
done

./psqlmad -f svmreg11rpt.sql

exit
