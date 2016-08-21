--
-- demo15.sql
--

-- Demo:
-- ./psqlmad -f demo15.sql

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
SELECT cdate,closep,
100*(LEAD(closep,1)OVER(ORDER BY cdate)-closep)/closep AS pctlead
FROM  prices
ORDER BY cdate;

-- I should add columns: mvgavg3day,mvgavg4day,mvgavg5day,mvgavg10day
DROP TABLE IF EXISTS prices12;
CREATE TABLE prices12 as
SELECT cdate,closep,pctlead,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS mvgavg3day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS mvgavg4day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS mvgavg5day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS mvgavg10day
FROM  prices10
ORDER BY cdate;

-- I should add column: mvgavg_slope3, mvgavg_slope4
DROP TABLE IF EXISTS prices13;
CREATE TABLE prices13 as
SELECT cdate,closep,pctlead
,CASE WHEN pctlead<0.033 THEN 0 ELSE 1 END AS label -- For classification
,(mvgavg3day-LAG(mvgavg3day,1)OVER(order by cdate))/mvgavg3day AS mvgavg_slope3
,(mvgavg4day-LAG(mvgavg4day,1)OVER(order by cdate))/mvgavg4day AS mvgavg_slope4
,(mvgavg5day-LAG(mvgavg5day,1)OVER(order by cdate))/mvgavg5day AS mvgavg_slope5
,(mvgavg10day-LAG(mvgavg10day,1)OVER(order by cdate))/mvgavg10day AS mvgavg_slope10
FROM  prices12
ORDER BY cdate;

-- I should learn from 1987 through 2014 and 
-- try to predict each day of 2015,2016.

DROP TABLE IF EXISTS traindata,testdata;
CREATE TABLE traindata AS SELECT * FROM prices13
WHERE cdate BETWEEN '1987-01-01' AND '2014-12-31';

CREATE TABLE testdata AS SELECT * FROM prices13
WHERE cdate BETWEEN '2015-01-01' AND '2016-12-31';

-- I should create a model which assumes that pctlead depends on mvgavg_slope:
DROP TABLE IF EXISTS svm_slpm1;
DROP TABLE IF EXISTS svm_slpm1_summary;
SELECT madlib.svm_classification(
'traindata', -- source table
'svm_slpm1', -- model                             
'label',     -- labels
'ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10]', -- features
'gaussian',
'n_components=10',
'',
'init_stepsize=1, max_iter=200'
);

-- I should use the model on Aug 2016:
DROP TABLE svm_slpm1_predictions;
SELECT  madlib.svm_predict('svm_slpm1', 'testdata', 'cdate', 'svm_slpm1_predictions');
SELECT * FROM svm_slpm1_predictions WHERE cdate > '2016-08-01';
SELECT prediction,count(prediction) from svm_slpm1_predictions group by prediction;

-- bye
