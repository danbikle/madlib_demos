--
-- demo12.sql
--

-- Demo:
-- ./psqlmad -f demo12.sql

-- Ref:
-- http://madlib.incubator.apache.org/docs/latest/group__grp__linreg.html

-- This script should demonstrate Linear Regression.

-- Goog: In postgres how to copy CSV file into table?
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
)
;

-- Ref:
-- https://www.postgresql.org/docs/9.3/static/sql-copy.html

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

-- I should create a table of 2016 prices:
DROP TABLE IF EXISTS prices2016;
CREATE TABLE prices2016 as
SELECT cdate-'2015-12-31' as yearday,cdate,closep 
FROM  prices
WHERE cdate BETWEEN '2016-01-01' AND '2016-12-31'
ORDER BY cdate;

SELECT * FROM prices2016;

-- I should study demo11

DROP TABLE IF EXISTS prices2016_linregr,prices2016_linregr_summary;

-- I should create a model which assumes that closep depends on yearday:
SELECT madlib.linregr_train( 'prices2016',
                             'prices2016_linregr',
                             'closep',
                             'ARRAY[1, yearday]'
                           );

-- Examine the resulting model.

-- Set extended display on for easier reading of output
\x ON
SELECT * FROM prices2016_linregr;

-- Today, 2016-08-20, I see this:
-- coef | {1897.05599516083,1.26160768158804}
-- On day 0 closep should be 1897.056
-- On day x   closep should be 1897.056 + 1.26 * x
-- On day 10  closep should be 1897.056 + 12.6  is 1909.66
-- On day 100 closep should be 1897.056 + 126.2 is 2023.26

-- Lets see:
SELECT madlib.linregr_predict(ARRAY[1,0 ] ,coef) AS prediction FROM prices2016_linregr;
SELECT madlib.linregr_predict(ARRAY[1,10] ,coef) AS prediction FROM prices2016_linregr;
SELECT madlib.linregr_predict(ARRAY[1,100],coef) AS prediction FROM prices2016_linregr;

-- bye


