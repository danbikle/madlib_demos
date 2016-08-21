--
-- sqldemo1.sql
--

-- Demo:
-- ./psqlmad -af sqldemo1.sql

-- This script should demonstrate some SQL syntax.

-- CCLUD is an acronym for verbs.
-- Verbs: Create, Copy, List, Update, Delete
-- A verb is a concept, SQL implements the concept with simple commands.

-- SQL commands: CREATE, SELECT, INSERT, UPDATE, DROP, DELETE, TRUNCATE

-- The verbs operate on nouns.
-- Nouns: Table, Row

-- Usually SQL is case insensitive.
-- Sometimes words are in uppercase but they dont need to be:
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
-- A table is like a variable.
-- It has a name and it holds data.
-- A table is like a spreadsheet.
-- It has rows and columns.
-- Currently the prices table has 7 columns and 0 rows.

-- Count the rows in prices:
SELECT COUNT(cdate) FROM prices;

-- I should copy rows from gspc.csv file into prices table.
-- The COPY command is not SQL syntax.
-- It is postgres syntax:
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
-- Now the prices table has many rows.

-- List count of rows in prices:
SELECT COUNT(cdate) FROM prices;
SELECT COUNT(lowp)  FROM prices;
SELECT COUNT(*)     FROM prices;
-- To count rows I need to list a column or just list a *.

-- List some minimum column values in prices:
SELECT MIN(cdate),MIN(closep),MIN(volume) FROM prices;

-- List some maximum and average column values in prices:
SELECT MAX(closep),MAX(volume), AVG(closep),AVG(volume) FROM prices;

-- List all columns of one row in prices:
SELECT * FROM prices WHERE cdate = (SELECT MAX(cdate) FROM prices);

-- List some columns of a row in prices:
SELECT cdate,closep FROM prices WHERE cdate = (SELECT MAX(cdate)-1 FROM prices);

-- List some columns of some rows in prices:
SELECT cdate,closep FROM prices WHERE cdate > (SELECT MAX(cdate)-10 FROM prices);
-- SQL is like Pandas. Constrain columns first, then constrain rows.

-- List some columns of some rows in prices and order by closep
SELECT cdate,closep
FROM prices 
WHERE cdate > (SELECT MAX(cdate)-10 FROM prices)
ORDER BY closep
;

-- List max closep using inline-view:
SELECT max(closep)     FROM
  (SELECT cdate,closep FROM prices WHERE cdate > (SELECT MAX(cdate)-10 FROM prices)) iv;

-- Create table from table:
DROP   TABLE IF EXISTS prices2;
CREATE TABLE prices2 AS SELECT cdate,openp,closep FROM prices WHERE cdate > '2016-08-08';

-- Create table from table, column from columns:
DROP   TABLE IF EXISTS prices3;
CREATE TABLE prices3 AS SELECT cdate,openp,closep, closep - openp AS diff FROM prices2;

-- Copy rows from table to table:
INSERT INTO prices3
SELECT cdate,openp,closep, closep - openp AS diff FROM prices
WHERE cdate = '2016-08-01';

-- Copy rows from table to table2 where rows not in table2 already:
INSERT INTO prices3
SELECT cdate,openp,closep, closep - openp AS diff FROM prices
WHERE  cdate BETWEEN '2016-08-01' AND '2016-08-31'
AND    cdate NOT IN (SELECT cdate FROM prices3);

-- Update all rows of a column:
UPDATE prices3 SET diff = 0;

-- Update some rows of a column:
UPDATE prices3 SET diff = 1 where cdate = '2016-08-01';

-- Update column using other columns:
UPDATE prices3 SET diff = closep - openp;
