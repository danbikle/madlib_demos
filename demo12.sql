--
-- demo12.sql
--

-- Demo:
-- ./psqlmad -f demo12.sql

-- Ref:
-- http://madlib.incubator.apache.org/docs/latest/group__grp__linreg.html

-- This script should demonstrate Linear Regression.


-- Goog: In postgres how to copy CSV file into table?
DROP TABLE IF EXISTS prices;
CREATE TABLE prices
(
cdate   text
,openp  text
,highp  text
,lowp   text
,closep text
,volume text
,adjp   text
)
;

COPY prices 
(
cdate   
,openp  
,highp  
,lowp   
,closep 
,volume 
,adjp   
)
from '/home/ann/madlib_demos/gspc.csv' with csv;

