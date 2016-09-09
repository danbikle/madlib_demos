--
-- whatif.sql
--

-- This script should help me answer the question: What if the GSPC price is $x?

-- Once I supply $x, this script should return a prediction.

-- Demo:
-- ./psqlmad -af whatif.sql -v whatif_price=2123.5 -v tstyr=2016 -v trainyrs=25 -v ma1=2 -v ma2=3 -v ma3=4 -v ma4=5 -v ma4=5 -v ma5=6 -v ma6=7 -v ma7=8 -v ma8=9

select :whatif_price
;

