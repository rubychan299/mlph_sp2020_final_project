# Length of stay prediction for diabetic patients in 130 US hospitals from 1999 - 2008
Machine Learning in Public Health Spring 2020 Final Project

## Data Description
This project used the data "Diabetes 130-US hospitals for years 1999-2008 Data Set” from [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/Diabetes+130-US+hospitals+for+years+1999-2008# ), which includes the demographic and medical information for 101766 individual diabetic inpatient encounters at 130 US hospitals and integrated delivery networks. 

## Data Preparation
    All the data pre-rocessing can be reproduced using `<data_cleaning.r>`. 

There are 50 variables in the original dataset, we exclude the encounter ID, patient number, weight, discharge disposition, admission source, payer code, medical specialty, and diagnosis 1 to 3 from analysis. The original dataset contains 24 features for diabetic medications using the generic names, and we summed up the medications prescribed and got the number of diabetic medications administered during each encounter. Then the 24 features were dropped from the dataset. After that, those with unknown gender and race were removed from analysis, which resulted in a final sample size of 99,492. 

## Analysis

    All the analysis can be reproduced using `<analysis.r>`.

Use `<final_project_code.html>` as the reference for the output and .pdf file contains the detailed results and discussion.

1. Feature Selection

    Lasso Regression and best subset selection was used for Feature selection for logistic regression

2. Classification
 * Logistic Regression
 * Linear Discrimicent 
 * K-NN
 * Random Forest

3. Model Evaluation

    Accuracy and AUC