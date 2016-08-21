--
-- demo13.sql
--

-- Demo:
-- ./psqlmad -f demo13.sql

-- This script should demonstrate window functions.

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

-- Goog: In postgres how to create lead window function?
-- Ref:
-- http://tapoueh.org/blog/2013/08/20-Window-Functions
-- https://community.modeanalytics.com/sql/tutorial/sql-window-functions/
-- https://www.postgresql.org/docs/9.3/static/functions-window.html
-- https://www.postgresql.org/docs/9.3/static/functions-aggregate.html

-- I should add column: leadp
DROP TABLE IF EXISTS prices10;
CREATE TABLE prices10 AS
SELECT cdate,closep,
LEAD(closep,1)OVER(ORDER BY cdate) AS leadp
FROM  prices
ORDER BY cdate;

SELECT * FROM prices10
WHERE cdate+10 > (SELECT MAX(cdate) FROM prices10);

-- I should add column: pctlead
DROP TABLE IF EXISTS prices11;
CREATE TABLE prices11 as
SELECT cdate,closep,leadp,
100*(leadp - closep) / closep AS pctlead
FROM  prices10
ORDER BY cdate;

SELECT * FROM prices11
WHERE cdate+11 > (SELECT MAX(cdate) FROM prices11);

-- I should add column: mvgavg4day
DROP TABLE IF EXISTS prices12;
CREATE TABLE prices12 as
SELECT cdate,closep,leadp,pctlead,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS mvgavg4day
FROM  prices11
ORDER BY cdate;

SELECT * FROM prices12
WHERE cdate+22 > (SELECT MAX(cdate) FROM prices12);

-- I should add column: mvgavg_slope
DROP TABLE IF EXISTS prices13;
CREATE TABLE prices13 as
SELECT cdate,closep,leadp,pctlead,
(mvgavg4day-LAG(mvgavg4day,1)OVER(order by cdate))/mvgavg4day AS mvgavg_slope
FROM  prices12
ORDER BY cdate;

SELECT * FROM prices13
WHERE cdate+22 > (SELECT MAX(cdate) FROM prices13);

