#!/bin/bash

# demo18.bash
# This script should collect predictions from several models.

# I should drop predictions from previous run:
./psqlmad<<EOF
DROP TABLE IF EXISTS predictions;
EOF

for ((year=2016; year < 2017 ; year++))
do
  echo $year
  ./psqlmad -f demo18.sql -v tstyr=$year -v trainyrs=30
done
exit
