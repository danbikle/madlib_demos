# README.md

This repo contains madlib demos.

To install madlib on my Centos 7 host I followed the steps in this file:

madlib_installation_steps.txt

I describe most of the demos below:

## demo10.sql is a simple walkthrough of a demo I found on the web:

https://cwiki.apache.org/confluence/display/MADLIB/Quick+Start+Guide+for+Users

I use demo10.sql to verify that madlib is installed and that 

I understand the call to madlib.logregr_train().

demo10.sql is a demo of Logistic Regression.


## demo11.sql is a simple walkthrough of a demo I found on the web:

[Linear Regression Demo](http://madlib.incubator.apache.org/docs/latest/group__grp__linreg.html)

demo11.sql shows a call to madlib.linregr_train().


## demo12.sql demonstrates some useful ideas:

* Postgres COPY command copies CSV rows from file into table.
* Syntax: Postgres DROP TABLE IF EXISTS
* Postgres Table Column data types: date, float
* SQL date arithmetic:
```sql
SELECT cdate-'2015-12-31' FROM  prices;

```
* Postgres ARRAY syntax
* Postgres extended display

## demo13.sql demonstrates Postgres window functions:
* https://www.postgresql.org/docs/9.3/static/functions-window.html
* LEAD()
```sql
LEAD(closep,1)OVER(ORDER BY cdate)
```
* AVG()
```sql
AVG(closep)OVER(ORDER BY cdate ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
```
* demo13.sql demonstrates SQL sub-query:
```sql
SELECT * FROM prices10
WHERE cdate+10 > (SELECT MAX(cdate) FROM prices10);
```

## demo14.sql demonstrates Logistic Regression on GSPC prices.

* demo14.sql demonstrates if-then-else logic inside SQL:

```sql
SELECT CASE WHEN pctlead<0.033 THEN 0 ELSE 1 END AS label FROM prices12;
```

* demo14.sql demonstrates BETWEEN predicate:

```sql
SELECT * FROM prices13 WHERE cdate BETWEEN '2015-01-01' AND '2016-12-31';
```

* demo14.sql demonstrates idea of 'Long-Only Effectiveness':

```sql
SELECT
SUM(pctlead) AS effectiveness
FROM logr_slpm1_predictions;
```


* demo14.sql demonstrates idea of 'Model Effectiveness':

```sql
SELECT
SUM(SIGN(prediction-0.5)*pctlead) AS effectiveness
FROM logr_slpm1_predictions;
```

* demo14.sql demonstrates idea of 'Accuracy':

```sql
-- True:
SELECT COUNT(cdate)tp FROM logr_slpm1_predictions WHERE prediction>0.5 AND pctlead>0;
SELECT COUNT(cdate)tn FROM logr_slpm1_predictions WHERE prediction<0.5 AND pctlead<0;
-- False:
SELECT COUNT(cdate)fp FROM logr_slpm1_predictions WHERE prediction>0.5 AND pctlead<0;
SELECT COUNT(cdate)fn FROM logr_slpm1_predictions WHERE prediction<0.5 AND pctlead>0;
```

## demo15.sql demonstrates SVM Classification of GSPC prices.

* demo15.sql demonstrates how to implement K-Fold Validation to tune hyperparameters:

```sql
'init_stepsize=[1,0.1], max_iter=[100,150], n_folds=20, lambda=[0.01,0.02], epsilon=[0.01, 0.02]'

```

## demo16.sql demonstrates SVM Regression of GSPC prices.

## demo17.sql demonstrates SVM Regression of GSPC prices.

## demo18.bash demonstrates some Bash techniques:

* It feeds text into shell command using here-doc and EOF token.

* It calls For-Loop driven by a range of integers.

* It feeds shell variables into Postgres as Postgres variables.

## demo18.sql compares Linear Regression, Logistic Regression, SVM Regression.

* demo18.sql demonstrates how to get median of a column:

```sql
SELECT madlib.svec_median(ARRAY(SELECT pctlead FROM traindata WHERE pctlead IS NOT NULL)) FROM traindata LIMIT 1;
```

## demo18.txt reports that SVM Regression is the most effective model between 2010 and 2016.

## demo19.bash is similar to demo18.bash.

## demo19.sql is similar to demo18.sql.

## demo19.txt shows poor results probably due to over-fitting probably due to too many features.

## gspc.csv is data from Yahoo:

* https://finance.yahoo.com/quote/%5EGSPC

## psqlmad is a shell script which wraps the Postgres psql command line UI.

* psqlmad shows how to pass a password to psql on command line:

```bash
PGPASSWORD=madlib /usr/bin/psql -U madlib -d madlib -h 127.0.0.1 -P pager=no $@
```

## some_results.txt shows some results from demo13.sql, demo14.sql, demo16.sql, demo17.sql

## sqldemo1.sql contains syntax examples for teaching SQL.

## sqldemo1.txt contains output from sqldemo1.sql.

## svmreg11.bash is similar to demo19.bash is similar to demo18.bash.

## svmreg11.sql runs SVM Regression against GSPC prices.

## If you have questions, e-me: bikle101@gmail.com

