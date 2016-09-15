--
-- many_whatif_rpt.sql
--

-- This script should report predictions in many_pred
-- Demo:
-- ./psqlmad -af many_whatif_rpt.sql

SELECT * FROM many_pred ORDER BY aprice;
