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

DROP TABLE IF EXISTS prices13;
CREATE TABLE prices13 as
SELECT cdate,closep,pctlead
,pctlag1,pctlag2,pctlag4,pctlag8,pctlag16
,row_number()OVER(ORDER BY cdate) AS id
,CASE WHEN pctlead<0.033 THEN 0 ELSE 1 END AS label -- For classification
FROM  prices10
ORDER BY cdate;


-- I should learn from 1987 through 2014 and 
-- try to predict each day of 2015,2016.

DROP TABLE IF EXISTS traindata,testdata;
CREATE TABLE traindata AS SELECT * FROM prices13
WHERE cdate BETWEEN '1987-01-01' AND '2014-12-31';

CREATE TABLE testdata AS SELECT * FROM prices13
WHERE cdate BETWEEN '2015-01-01' AND '2016-12-31';

-- I should create a model which assumes that pctlead depends on pctlag:
DROP TABLE IF EXISTS svm_lagm1;
DROP TABLE IF EXISTS svm_lagm1_summary;
DROP TABLE IF EXISTS svm_lagm1_random;
SELECT madlib.svm_regression(
'traindata', -- source table
'svm_lagm1', -- model                             
'pctlead',   -- dependent variable
'ARRAY[1,pctlag1,pctlag2,pctlag4,pctlag8,pctlag16]', -- features
'gaussian',
'n_components=10',
'',
'init_stepsize=[1,0.1,0.01], max_iter=[111,222], n_folds=20, lambda=[0.01,0.02], epsilon=[0.01, 0.02]'
);

-- I should collect predictions of testdata
DROP TABLE svm_lagm1_predictions;
SELECT  madlib.svm_predict('svm_lagm1', 'testdata', 'id', 'svm_lagm1_predictions');

-- I should report model effectiveness:
SELECT
SUM(SIGN(prediction)*pctlead) AS effectiveness,
COUNT(cdate) prediction_count
FROM prices13 a,svm_lagm1_predictions b
WHERE a.id = b.id;

SELECT
SIGN(prediction),
SUM(SIGN(prediction)*pctlead) AS effectiveness,
COUNT(cdate) prediction_count
FROM prices13 a,svm_lagm1_predictions b
WHERE a.id = b.id
GROUP BY SIGN(prediction);

-- I should report long-only effectiveness:
SELECT SUM(pctlead) AS lo_effectiveness,
COUNT(cdate) prediction_count
FROM prices13
WHERE cdate BETWEEN '2015-01-01' AND '2016-12-31';
 
-- I should report model accuracy:
SELECT
SIGN(prediction)*SIGN(pctlead) true_or_false
,SIGN(prediction)              pos_or_neg
,COUNT(cdate)                  observations
FROM prices13 a,svm_lagm1_predictions b
WHERE a.id = b.id
GROUP BY SIGN(prediction)*SIGN(pctlead), SIGN(prediction)
ORDER BY SIGN(prediction)*SIGN(pctlead), SIGN(prediction)

-- bye
