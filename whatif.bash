#!/bin/bash

# whatif.bash

# This script should help me answer the question: What if the GSPC price is $x?

# Once I supply $x, this script should return a prediction.

# Demo:
# ./whatif.bash 2123.50

if [ $# -ne 1 ]
then
  echo You typed something wrong.
  echo Try something like this:
  echo ./whatif.bash 2123.50
  exit 1
fi

echo $1
echo $#

# I should get prices:
# curl http://ichart.finance.yahoo.com/table.csv?s=%5EGSPC > gspc.csv

./psqlmad -af whatif.sql -v whatif_price=$1 -v tstyr=2016 -v trainyrs=25 -v ma1=2 -v ma2=3 -v ma3=4 -v ma4=5 -v ma4=5 -v ma5=6 -v ma6=7 -v ma7=8 -v ma8=9

exit
