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

* If you have questions, e-me: bikle101@gmail.com

