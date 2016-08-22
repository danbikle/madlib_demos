-- 

UPDATE traindata SET label =
CASE WHEN pctlead < (
  SELECT madlib.svec_median(ARRAY(SELECT pctlead FROM traindata WHERE pctlead IS NOT NULL)) FROM traindata LIMIT 1
)
THEN 0 ELSE 1 END
;
