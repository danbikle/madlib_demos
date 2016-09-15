--
-- many_whatif_get.sql
--

-- This script should get recent prediction and copy it to table many_pred
-- Demo:
-- ./psqlmad -af many_whatif_get.sql

INSERT INTO many_pred
SELECT closep, prediction
FROM prices13 a,svm_slpm2_predictions b
WHERE a.id = b.id
AND cdate = (SELECT MAX(cdate) FROM prices13)
;
