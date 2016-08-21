--
-- sqldemo1.sql
--

-- Demo:
-- ./psqlmad -f sqldemo1.sql

-- This script should demonstrate some SQL syntax.

-- CCLUD is an acronym for verbs.
-- Verbs: Create, Copy, List, Update, Delete
-- A verb is a concept, SQL implements the concept with commands

-- SQL verb commands: CREATE, SELECT, UPDATE, DROP, DELETE

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

-- Count the rows in prices:
SELECT COUNT(cdate) FROM prices;
SELECT COUNT(lowp)  FROM prices;
SELECT COUNT(*)     FROM prices;
-- To count rows I need to list a column or just list a *.
