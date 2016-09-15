--
-- many_whatif_prep.sql
--

-- This script should create a table which collects predictions.
-- Demo:
-- ./psqlmad -af many_whatif_prep.sql
drop table many_pred;
create table many_pred
(
  aprice float
  ,prediction float
)
;
