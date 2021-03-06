--
-- demo19.sql
--

-- This script should collect predictions from several models.

-- Demo:
-- ./psqlmad -af demo19.sql -v tstyr=2016 -v trainyrs=30

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

-- I should add columns: pctlead, nlag, ...
DROP   TABLE IF EXISTS prices10;
CREATE TABLE prices10 AS
SELECT cdate,closep,
100*(LEAD(closep,1)OVER(ORDER BY cdate)-closep)/closep pctlead
,(closep - LAG(closep,1)OVER(ORDER BY cdate))/closep   nlag1
,(closep - LAG(closep,2)OVER(ORDER BY cdate))/closep   nlag2
,(closep - LAG(closep,4)OVER(ORDER BY cdate))/closep   nlag4
,(closep - LAG(closep,8)OVER(ORDER BY cdate))/closep   nlag8
,(closep - LAG(closep,16)OVER(ORDER BY cdate))/closep  nlag16
FROM  prices
ORDER BY cdate;

-- I should add columns: mvgavg3day,mvgavg4day,mvgavg5day,mvgavg10day
DROP   TABLE IF EXISTS prices12;
CREATE TABLE prices12 as
SELECT cdate,closep,pctlead,nlag1,nlag2,nlag4,nlag8,nlag16,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS mvgavg3day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS mvgavg4day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS mvgavg5day,
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS mvgavg10day
FROM  prices10
ORDER BY cdate;

-- I should add columns: mvgavg_slope3, mvgavg_slope4, ...
DROP   TABLE IF EXISTS prices13;
CREATE TABLE prices13 as
SELECT cdate,closep,pctlead,nlag1,nlag2,nlag4,nlag8,nlag16
,row_number()OVER(ORDER BY cdate) AS id
,CASE WHEN pctlead<0.033 THEN 0 ELSE 1 END AS label -- For classification
,(mvgavg3day-LAG(mvgavg3day,1)OVER(order by cdate))/mvgavg3day AS mvgavg_slope3
,(mvgavg4day-LAG(mvgavg4day,1)OVER(order by cdate))/mvgavg4day AS mvgavg_slope4
,(mvgavg5day-LAG(mvgavg5day,1)OVER(order by cdate))/mvgavg5day AS mvgavg_slope5
,(mvgavg10day-LAG(mvgavg10day,1)OVER(order by cdate))/mvgavg10day AS mvgavg_slope10
FROM  prices12
ORDER BY cdate;

-- I should extract year from command line:
DROP  TABLE IF EXISTS traindata,testdata;
CREATE TABLE traindata AS SELECT * FROM prices13
WHERE extract(year from cdate) BETWEEN :tstyr -1 - :trainyrs AND :tstyr -1;

-- I want balanced classes to train from:
-- UPDATE traindata
--   SET label = CASE WHEN pctlead<(SELECT AVG(pctlead) FROM traindata) THEN 0 ELSE 1 END;
-- median is better than AVG() here.

-- Median gives better balance than AVG().
-- I should compute label from median, not AVG():
UPDATE traindata SET label =
CASE WHEN pctlead < (
  SELECT madlib.svec_median(ARRAY(SELECT pctlead FROM traindata WHERE pctlead IS NOT NULL)) FROM traindata LIMIT 1
)
THEN 0 ELSE 1 END
;

-- I should count the classes to verify they are balanced:
SELECT label,COUNT(label) FROM traindata GROUP BY label ;

CREATE TABLE testdata AS SELECT * FROM prices13
WHERE extract(year from cdate) = :tstyr;

-- I should get ready to collect predictions:
CREATE TABLE IF NOT EXISTS 
  predictions(model text, cdate date, pctlead float, prediction float, eff float);

-- I should create Linear Regression model which assumes that pctlead depends on mvgavg_slope:
DROP TABLE IF EXISTS linr_slpm1;
DROP TABLE IF EXISTS linr_slpm1_summary;
SELECT madlib.linregr_train( 
'traindata',
'linr_slpm1',
'pctlead',
'ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16]'
);

INSERT INTO predictions (model,cdate,pctlead,prediction,eff)
SELECT 'linr_slpm1',cdate,pctlead,
madlib.linregr_predict(ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16],coef) prediction
,SIGN(
madlib.linregr_predict(ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16],coef)
)*pctlead eff
FROM testdata,linr_slpm1;

-- I should create Logistic Regression model which assumes that label depends on mvgavg_slope:
DROP TABLE IF EXISTS logr_slpm1;
DROP TABLE IF EXISTS logr_slpm1_summary;
SELECT madlib.logregr_train(
'traindata',  -- source table
'logr_slpm1', -- model                             
'label',      -- labels
'ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16]',
NULL,         -- grouping columns
99,           -- max number of iteration
'irls'        -- optimizer
);

INSERT INTO predictions (model,cdate,pctlead,prediction,eff)
SELECT 'logr_slpm1',cdate,pctlead,
madlib.logregr_predict_prob(coef,ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16]) prediction 
,SIGN(
-0.5+madlib.logregr_predict_prob(coef, ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16])
)*pctlead eff
FROM testdata,logr_slpm1;

-- I should create SVM Regression model which assumes that pctlead depends on mvgavg_slope:
DROP TABLE IF EXISTS svm_slpm2;
DROP TABLE IF EXISTS svm_slpm2_summary;
DROP TABLE IF EXISTS svm_slpm2_random;
SELECT madlib.svm_regression(
'traindata', -- source table
'svm_slpm2', -- model                             
'pctlead',   -- dependent variable
'ARRAY[1,mvgavg_slope3, mvgavg_slope4,mvgavg_slope5,mvgavg_slope10,nlag1,nlag2,nlag4,nlag8,nlag16]',
'gaussian',
'n_components=10',
'',
'init_stepsize=[1,0.1,0.01], max_iter=150, n_folds=22, lambda=[0.01,0.02], epsilon=[0.01, 0.02]'
);

-- I should collect predictions of testdata
DROP TABLE svm_slpm2_predictions;
SELECT  madlib.svm_predict('svm_slpm2', 'testdata', 'id', 'svm_slpm2_predictions');

INSERT INTO predictions (model,cdate,pctlead,prediction,eff)
SELECT 'svm_slpm2',cdate,pctlead,prediction
,SIGN(prediction)*pctlead eff
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id;

-- if pctlead < eff, then model is effective.
SELECT model
,SUM(pctlead) long_only_eff
,SUM(eff)     effectiveness
FROM predictions GROUP BY model;

SELECT model, extract(year from cdate) yr
,SUM(pctlead) long_only_eff
,SUM(eff)     effectiveness
FROM predictions
GROUP BY model,yr
ORDER BY model,yr;

-- bye
