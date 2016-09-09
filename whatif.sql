--
-- whatif.sql
--

-- This script should help me answer the question: What if the GSPC price is $x?

-- Once I supply $x, this script should return a prediction.

-- Demo:
-- ./psqlmad -af whatif.sql -v whatif_price=2123.4 -v tstyr=2016 -v trainyrs=25 -v ma1=2 -v ma2=3 -v ma3=4 -v ma4=5 -v ma4=5 -v ma5=6 -v ma6=7 -v ma7=8 -v ma8=9

select :whatif_price
;

DROP   TABLE IF EXISTS prices;
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

DROP   TABLE IF EXISTS wprice;
CREATE TABLE wprice as select * from prices where cdate = (select max(cdate) from prices);

UPDATE wprice SET cdate  = cdate+1;
UPDATE wprice SET closep = :whatif_price ;

INSERT INTO prices SELECT * FROM wprice;

-- I should add column: pctlead
DROP TABLE IF EXISTS prices10;
CREATE TABLE prices10 AS
SELECT cdate,closep,
100*(LEAD(closep,1)OVER(ORDER BY cdate)-closep)/closep AS pctlead
FROM  prices
ORDER BY cdate;

-- I should add columns: ma1,ma2,ma3,ma4
DROP TABLE IF EXISTS prices12;
CREATE TABLE prices12 as
SELECT cdate,closep,pctlead,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma1 PRECEDING AND CURRENT ROW) AS ma1,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma2 PRECEDING AND CURRENT ROW) AS ma2,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma3 PRECEDING AND CURRENT ROW) AS ma3,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma4 PRECEDING AND CURRENT ROW) AS ma4,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma5 PRECEDING AND CURRENT ROW) AS ma5,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma6 PRECEDING AND CURRENT ROW) AS ma6,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma7 PRECEDING AND CURRENT ROW) AS ma7,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN :ma8 PRECEDING AND CURRENT ROW) AS ma8
FROM  prices10
ORDER BY cdate;

-- I should add column: slope1, slope2, ...
DROP TABLE IF EXISTS prices13;
CREATE TABLE prices13 as
SELECT cdate,closep,pctlead,row_number()OVER(ORDER BY cdate) AS id
,CASE WHEN pctlead<0.033 THEN 0 ELSE 1 END AS label -- For classification
,(ma1-LAG(ma1,1)OVER(order by cdate))/ma1 AS slope1
,(ma2-LAG(ma2,1)OVER(order by cdate))/ma2 AS slope2
,(ma3-LAG(ma3,1)OVER(order by cdate))/ma3 AS slope3
,(ma4-LAG(ma4,1)OVER(order by cdate))/ma4 AS slope4
,(ma5-LAG(ma5,1)OVER(order by cdate))/ma5 AS slope5
,(ma6-LAG(ma6,1)OVER(order by cdate))/ma6 AS slope6
,(ma7-LAG(ma7,1)OVER(order by cdate))/ma7 AS slope7
,(ma8-LAG(ma8,1)OVER(order by cdate))/ma8 AS slope8
FROM  prices12
ORDER BY cdate;

DROP TABLE IF EXISTS traindata,testdata;
CREATE TABLE traindata AS SELECT * FROM prices13
WHERE extract(year from cdate) BETWEEN :tstyr -1 - :trainyrs AND :tstyr -1;

select min(cdate),max(cdate) from  traindata;

-- I should extract year from command line:
CREATE TABLE testdata AS SELECT * FROM prices13
WHERE extract(year from cdate) = :tstyr;

select min(cdate),max(cdate) from  testdata;

-- I should create a model which assumes that pctlead depends on mvgavg_slope:
DROP TABLE IF EXISTS svm_slpm2;
DROP TABLE IF EXISTS svm_slpm2_summary;
DROP TABLE IF EXISTS svm_slpm2_random;
SELECT madlib.svm_regression(
'traindata', -- source table
'svm_slpm2', -- model                             
'pctlead',   -- dependent variabl
'ARRAY[1,slope1, slope2,slope3,slope4,slope5,slope6,slope7,slope8]', -- features
'gaussian',
'n_components=10',
'',
'init_stepsize=[1,0.1,0.01], max_iter=99, n_folds=26, lambda=[0.01,0.02], epsilon=[0.01, 0.02]'
);
-- 'init_stepsize=[1,0.1,0.01], max_iter=[100,150], n_folds=20, lambda=[0.01,0.02], epsilon=[0.01, 0.02]'

-- I should collect predictions of testdata
DROP TABLE svm_slpm2_predictions;
SELECT  madlib.svm_predict('svm_slpm2', 'testdata', 'id', 'svm_slpm2_predictions');

-- I should report model effectiveness:
SELECT
SUM(SIGN(prediction)*pctlead) AS effectiveness,
COUNT(cdate) prediction_count
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id;

SELECT
SIGN(prediction),
SUM(SIGN(prediction)*pctlead) AS effectiveness,
COUNT(cdate) prediction_count
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id
GROUP BY SIGN(prediction);

-- I should report long-only effectiveness:
SELECT SUM(pctlead) AS lo_effectiveness,
COUNT(cdate) prediction_count
FROM prices13
WHERE extract(year from cdate) = :tstyr; 

-- I should report model accuracy:
SELECT
SIGN(prediction)*SIGN(pctlead) true_or_false
,SIGN(prediction)              pos_or_neg
,COUNT(cdate)                  observations
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id
GROUP BY SIGN(prediction)*SIGN(pctlead), SIGN(prediction)
ORDER BY SIGN(prediction)*SIGN(pctlead), SIGN(prediction)
;

-- I should report recent predictions:
SELECT cdate, closep, prediction, pctlead
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id
AND cdate + 9 > (SELECT MAX(cdate) FROM prices13)
ORDER BY cdate
;
