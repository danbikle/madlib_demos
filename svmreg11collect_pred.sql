--
-- svmreg11collect_pred.sql
--

-- This script should collect predictions.

INSERT INTO 
svmregpred(cdate,closep,pctlead,prediction)
SELECT     cdate,closep,pctlead,prediction
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id
;
