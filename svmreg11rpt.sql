--
-- svmreg11rpt.sql
-- 

-- This script should report the effectiveness of SVM Regression.
-- Demo:
-- ./psqlmad -f svmreg11rpt.sql

-- I should report long-only effectiveness:
SELECT SUM(pctlead) AS lo_effectiveness,
COUNT(cdate) prediction_count
FROM svmregpred
;

-- I should report model effectiveness:
SELECT
SUM(SIGN(prediction)*pctlead) AS effectiveness,
COUNT(cdate) prediction_count
FROM svmregpred
;

SELECT
SIGN(prediction),
SUM(SIGN(prediction)*pctlead) AS effectiveness,
COUNT(cdate) prediction_count
FROM svmregpred
GROUP BY SIGN(prediction)
;

-- I should report model accuracy:
SELECT
SIGN(prediction)*SIGN(pctlead) true_or_false
,SIGN(prediction)              pos_or_neg
,COUNT(cdate)                  observations
FROM svmregpred
GROUP BY SIGN(prediction)*SIGN(pctlead), SIGN(prediction)
ORDER BY SIGN(prediction)*SIGN(pctlead), SIGN(prediction)
;

-- bye


