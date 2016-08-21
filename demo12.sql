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
cdate   date
,openp  float
,highp  float
,lowp   float
,closep float
,volume float
,adjp   float
)
;

-- Ref:
-- https://www.postgresql.org/docs/9.3/static/sql-copy.html

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
FROM '/home/ann/madlib_demos/gspc.csv' WITH CSV HEADER;

-- I should create a table of 2016 prices:
DROP TABLE IF EXISTS prices2016;
CREATE TABLE prices2016 as
SELECT cdate,closep 
FROM  prices
WHERE cdate BETWEEN '2016-01-01' AND '2016-12-31'
ORDER BY cdate;

SELECT * FROM prices2016;

