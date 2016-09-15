#!/bin/bash

# many_whatif.bash

# This script should help me answer the question: What if the GSPC price is $x?

# Demo:
# ./many_whatif.bash

# I should get prices:
curl http://ichart.finance.yahoo.com/table.csv?s=%5EGSPC > gspc.csv

declare -i aprice_i
declare -i delta_i
declare -i whatif_i
aprice_i=`sed -n '2 p' gspc.csv |awk -F, '{print $(NF-2)}'|awk -F. '{print $1}'`
for delta_i in -20 -10 0 10 20 
do
  whatif_i=aprice_i+delta_i
  echo  ./psqlmad -af whatif.sql -v whatif_price=$whatif_i -v tstyr=`date +%Y` -v trainyrs=25 -v ma1=2 -v ma2=3 -v ma3=4 -v ma4=5 -v ma4=5 -v ma5=6 -v ma6=7 -v ma7=8 -v ma8=9
done
exit
