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

-- I should add column: mvgavg3day,mvgavg4day,mvgavg5day,mvgavg10day
DROP TABLE IF EXISTS prices12;
CREATE TABLE prices12 as
SELECT cdate,closep,leadp,pctlead,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS mvgavg3day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS mvgavg4day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS mvgavg5day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS mvgavg10day
FROM  prices11
ORDER BY cdate;

SELECT * FROM prices12
WHERE cdate+22 > (SELECT MAX(cdate) FROM prices12);

-- I should add column: mvgavg_slope3, mvgavg_slope4
DROP TABLE IF EXISTS prices13;
CREATE TABLE prices13 as
SELECT cdate,closep,leadp,pctlead,
(mvgavg3day-LAG(mvgavg3day,1)OVER(order by cdate))/mvgavg3day AS mvgavg_slope3,
(mvgavg4day-LAG(mvgavg4day,1)OVER(order by cdate))/mvgavg4day AS mvgavg_slope4,
(mvgavg5day-LAG(mvgavg5day,1)OVER(order by cdate))/mvgavg5day AS mvgavg_slope5,
(mvgavg10day-LAG(mvgavg10day,1)OVER(order by cdate))/mvgavg10day AS mvgavg_slope10
FROM  prices12
ORDER BY cdate;

SELECT * FROM prices13
WHERE cdate+22 > (SELECT MAX(cdate) FROM prices13);

-- I should look for correlation tween mvgavg_slope and pctlead:
SELECT
CORR(mvgavg_slope3,pctlead) corr_sp3,
CORR(mvgavg_slope4,pctlead) corr_sp4,
CORR(mvgavg_slope5,pctlead) corr_sp5,
CORR(mvgavg_slope10,pctlead) corr_sp10
FROM prices13;
-- Does pctlead depend on mvgavg_slope?

-- I should drill down into each year.
-- Goog: In postgres how to extract year from date?
-- https://www.postgresql.org/docs/9.3/static/functions-datetime.html#FUNCTIONS-DATETIME-TABLE
-- https://www.postgresql.org/docs/9.3/static/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT
SELECT
extract(year from cdate)     yr,
CORR(mvgavg_slope3,pctlead)  corr_sp3,
CORR(mvgavg_slope4,pctlead)  corr_sp4,
CORR(mvgavg_slope5,pctlead)  corr_sp5,
CORR(mvgavg_slope10,pctlead) corr_sp10
FROM prices13
GROUP BY extract(year from cdate)
ORDER BY extract(year from cdate)
;

-- Using Linear Regression,
-- I should learn from 1987 through 2014 and 
-- try to predict each day of 2015,2016.

DROP TABLE IF EXISTS traindata,testdata;
CREATE TABLE traindata AS SELECT * FROM prices13
WHERE cdate BETWEEN '1987-01-01' AND '2014-12-31';

CREATE TABLE testdata AS SELECT * FROM prices13
WHERE cdate BETWEEN '2016-01-01' AND '2016-12-31';

-- I should create a model which assumes that pctlead depends on mvgavg_slope:
DROP TABLE IF EXISTS slopemodel;
DROP TABLE IF EXISTS slopemodel_summary;
SELECT madlib.linregr_train( 'traindata',
                             'slopemodel',
                             'pctlead',
                             'ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10]'
                           );

-- I should use the model on Aug 2016:
SELECT cdate,pctlead,
madlib.linregr_predict(ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10],coef) AS prediction 
FROM testdata,slopemodel
WHERE cdate BETWEEN '2016-08-01' AND '2016-08-31'
ORDER BY cdate;

-- I should use the model on testdata
DROP TABLE IF EXISTS slopemodel_predictions;
CREATE TABLE slopemodel_predictions AS
SELECT cdate,pctlead,
madlib.linregr_predict(ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10],coef) AS prediction 
FROM testdata,slopemodel
ORDER BY cdate;

SELECT MIN(prediction),MAX(prediction) FROM slopemodel_predictions;

-- I should report long-only effectiveness:
SELECT SUM(pctlead) AS lo_effectiveness FROM slopemodel_predictions;


-- bye
