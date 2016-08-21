--
-- demo17.sql
--

-- Demo:
-- ./psqlmad -f demo17.sql

-- This script should demonstrate SVM on GSPC (S&P 500) prices.

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
);

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

-- I should add column: pctlead
DROP TABLE IF EXISTS prices10;
CREATE TABLE prices10 AS
SELECT cdate,closep
,100*(LEAD(closep,1)OVER(ORDER BY cdate)-closep)/closep AS pctlead
,100*(LAG(closep,1)OVER(ORDER BY cdate)-closep)/closep AS pctlag1
,100*(LAG(closep,2)OVER(ORDER BY cdate)-closep)/closep AS pctlag2
,100*(LAG(closep,4)OVER(ORDER BY cdate)-closep)/closep AS pctlag4
,100*(LAG(closep,8)OVER(ORDER BY cdate)-closep)/closep AS pctlag8
,100*(LAG(closep,16)OVER(ORDER BY cdate)-closep)/closep AS pctlag16
FROM  prices
ORDER BY cdate;
