--
-- demo11.sql
--

-- http://madlib.incubator.apache.org/docs/latest/group__grp__linreg.html

DROP   TABLE houses;
CREATE TABLE houses (id INT, tax INT, bedroom INT, bath FLOAT, price INT,
            size INT, lot INT);
COPY houses FROM STDIN WITH DELIMITER '|';
  1 |  590 |       2 |    1 |  50000 |  770 | 22100
  2 | 1050 |       3 |    2 |  85000 | 1410 | 12000
  3 |   20 |       3 |    1 |  22500 | 1060 |  3500
  4 |  870 |       2 |    2 |  90000 | 1300 | 17500
  5 | 1320 |       3 |    2 | 133000 | 1500 | 30000
  6 | 1350 |       2 |    1 |  90500 |  820 | 25700
  7 | 2790 |       3 |  2.5 | 260000 | 2130 | 25000
  8 |  680 |       2 |    1 | 142500 | 1170 | 22000
  9 | 1840 |       3 |    2 | 160000 | 1500 | 19000
 10 | 3680 |       4 |    2 | 240000 | 2790 | 20000
 11 | 1660 |       3 |    1 |  87000 | 1030 | 17500
 12 | 1620 |       3 |    2 | 118600 | 1250 | 20000
 13 | 3100 |       3 |    2 | 140000 | 1760 | 38000
 14 | 2070 |       2 |    3 | 148000 | 1550 | 14000
 15 |  650 |       3 |  1.5 |  65000 | 1450 | 12000
\.

-- Train a regression model. First, a single regression for all the data.

drop table houses_linregr;
drop table houses_linregr_summary;
drop table houses_linregr_bedroom;
drop table houses_linregr_bedroom_summary;

SELECT madlib.linregr_train( 'houses',
                             'houses_linregr',
                             'price',
                             'ARRAY[1, tax, bath, size]'
                           );

-- Generate three output models, one for each value of "bedroom". 

SELECT madlib.linregr_train( 'houses',
                             'houses_linregr_bedroom',
                             'price',
                             'ARRAY[1, tax, bath, size]',
                             'bedroom'
                           );

-- Examine the resulting models.

-- Set extended display on for easier reading of output
\x ON
SELECT * FROM houses_linregr;

-- View the results grouped by bedroom.
SELECT * FROM houses_linregr_bedroom;


-- Alternatively you can unnest the results for easier reading of output.

\x OFF
SELECT unnest(ARRAY['intercept','tax','bath','size']) as attribute,
       unnest(coef) as coefficient,
       unnest(std_err) as standard_error,
       unnest(t_stats) as t_stat,
       unnest(p_values) as pvalue
FROM houses_linregr;
