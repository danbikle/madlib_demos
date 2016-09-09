--
-- svmreg11cr_pred.sql
--

-- Demo:
-- ./psqlmad -f svmreg11cr_pred.sql

-- This should create a table to collect predictions.
DROP   TABLE svmregpred;
CREATE TABLE svmregpred AS SELECT
cdate,closep,pctlead,prediction
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id
;

TRUNCATE TABLE svmregpred;
