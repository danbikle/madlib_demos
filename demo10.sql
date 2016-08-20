--
-- demo10.sql
--

-- Demo:
-- ./psqlmad -f demo10.sql


-- ref:
-- https://cwiki.apache.org/confluence/display/MADLIB/Quick+Start+Guide+for+Users
-- http://faculty.cas.usf.edu/mbrannick/regression/Logistic.html
-- http://madlib.incubator.apache.org/docs/latest/group__grp__logreg.html

DROP TABLE IF EXISTS patients, patients_logregr, patients_logregr_summary;
 
CREATE TABLE patients( id INTEGER NOT NULL,
                        second_attack INTEGER,
                        treatment INTEGER,
                        trait_anxiety INTEGER);
                          
INSERT INTO patients VALUES                                                     
(1,     1,      1,      70),
(3,     1,      1,      50),
(5,     1,      0,      40),
(7,     1,      0,      75),
(9,     1,      0,      70),
(11,    0,      1,      65),
(13,    0,      1,      45),
(15,    0,      1,      40),
(17,    0,      0,      55),
(19,    0,      0,      50),
(2,     1,      1,      80),
(4,     1,      0,      60),
(6,     1,      0,      65),
(8,     1,      0,      80),
(10,    1,      0,      60),
(12,    0,      1,      50),
(14,    0,      1,      35),
(16,    0,      1,      50),
(18,    0,      0,      45),
(20,    0,      0,      60);

SELECT * FROM patients;

-- Call MADlib built-in function to train a classification model using the training data table as input:

SELECT madlib.logregr_train(
    'patients',                                 -- source table
    'patients_logregr',                         -- output table
    'second_attack',                            -- labels
    'ARRAY[1, treatment, trait_anxiety]',       -- features
    NULL,                                       -- grouping columns
    20,                                         -- max number of iteration
    'irls'                                      -- optimizer
    );


-- View the model that has just been trained:
-- Set extended display on for easier reading of output (\x is for psql only)

\x on
SELECT * from patients_logregr;
  
-- Alternatively, unnest the arrays in the results for easier reading of output (\x is for psql only)
\x off
SELECT unnest(array['intercept', 'treatment', 'trait_anxiety']) as attribute,
       unnest(coef) as coefficient,
       unnest(std_err) as standard_error,
       unnest(z_stats) as z_stat,
       unnest(p_values) as pvalue,
       unnest(odds_ratios) as odds_ratio
FROM patients_logregr;

-- Now use the model to predict the dependent variable (second heart
-- attack within 1 year) using the logistic regression model. For the
-- purpose of demonstration, we will use the original data table to
-- perform the prediction. Typically a different test dataset with the
-- same features as the original training dataset would be used for
-- prediction.

-- Display prediction value along with the original value.
-- patients_logregr returns only one row so cartesian product is okay here.
SELECT p.id, madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
ORDER BY p.id;

-- True positives
SELECT p.id, madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
WHERE madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]) = 't'
AND   p.second_attack = 1
ORDER BY p.id;

-- True negatives
SELECT p.id, madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
WHERE madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]) = 'f'
AND   p.second_attack = 0
ORDER BY p.id;

-- False positives
SELECT p.id, madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
WHERE madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]) = 't'
AND   p.second_attack = 0
ORDER BY p.id;

-- False negatives
SELECT p.id, madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
WHERE madlib.logregr_predict(coef, ARRAY[1, treatment, trait_anxiety]) = 'f'
AND   p.second_attack = 1
ORDER BY p.id;

-- Predicting the probability of the dependent variable being TRUE.
-- Display prediction value along with the original value:
SELECT p.id, madlib.logregr_predict_prob(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
ORDER BY p.id;

-- Different order
SELECT p.id, madlib.logregr_predict_prob(coef, ARRAY[1, treatment, trait_anxiety]),
       p.second_attack
FROM patients p, patients_logregr m
ORDER BY madlib.logregr_predict_prob(coef, ARRAY[1, treatment, trait_anxiety]);
 
