## Feature Selection 

### Testing and Training data

set.seed(1024)
train <- sample(nrow(dat), nrow(dat) * 0.8)

### LASSO Regression

x <- model.matrix(los~., dat)[,-1]
y <- dat$los

lasso.mod <- glmnet(x[train,],y[train],alpha=1, family = "binomial")
plot(lasso.mod)

cv.out <- cv.glmnet(x[train,],y[train],alpha=1, family = "binomial")
plot(cv.out)

bestlam <- cv.out$lambda.min
lasso.pred <- predict(lasso.mod,s=bestlam ,newx=x[-train,])

lasso.coef = predict(lasso.mod, type = "coefficients", s=bestlam)
lasso.coef

## Classification

#### Logistic Regression

m1 <- glm(los~., data = dat[train,], family = "binomial")
summary(m1)
m1.prob <- predict(m1, dat[-train,], type="response")
m1.pred <- ifelse(m1.prob > 0.5, 1, 0)
# Confusion Matrix
table(m1.pred, dat[-train,]$los)
# Error
mean(m1.pred != dat[-train,]$los)
# Accuracy
mean(m1.pred == dat[-train,]$los)

#### Linear Discriminate Analysis

m2 <- lda(los~., data = dat[train,])
m2.pred <- predict(m2, dat[-train,])$class
# Cofusion Matrix
table(m2.pred, dat[-train,]$los)
# Accuracy
mean(m2.pred == dat[-train,]$los)

#### k-NN

dat_knn <- dat %>% 
  mutate(gender = ifelse(gender == "Female", 1, 0),
         race = as.numeric(race),
         age = as.numeric(age),
         admission_type_id = as.numeric(admission_type_id),
         max_glu_serum = as.numeric(max_glu_serum),
         change = as.numeric(change),
         diabetesMed = as.numeric(diabetesMed),
         readmitted = as.numeric(readmitted),
         A1Cresult = as.numeric(A1Cresult),
         std.lab.procedures = scale(num_lab_procedures),
         std.procedures = scale(num_procedures),
         std.medications = scale(num_medications),
         std.outpatient = scale(number_outpatient),
         std.emergency = scale(number_emergency),
         std.inpatient = scale(number_inpatient),
         std.diagnoses = scale(number_diagnoses),
         std.num.diabetesMed = scale(num_diabetesMed)) %>% 
  select(-num_lab_procedures, -num_procedures, -num_medications,
         -number_outpatient, -number_emergency, -number_inpatient,
         -number_diagnoses, -num_diabetesMed)
train.x <- dplyr::select(dat_knn, -los)[train,]
test.x <- dplyr::select(dat_knn, -los)[-train,]
train.y <- dat$los[train]
test.y <- dat$los[-train]
m3.pred <- knn(train.x,test.x,train.y, k = 3)
mean(m3.pred == test.y)

#### Random Forest 

dat_tree <- dat %>% mutate(los = factor(los))
set.seed(1024)
m4 <- randomForest(los~., data = dat_tree, subset=train, importance=TRUE)
m4.pred <- predict(m4,newdata=dat_tree[-train,])
mean(m4.pred == dat_tree[-train,]$los)

importance(m4)
varImpPlot(m4)

## Evaluation

### Cross-Validation 

set.seed(17)
glm.fit = glm(los~., data = dat, family = "binomial")
cv.error = cv.glm(dat, glm.fit, K = 10)$delta[1]
cv.error

### Model Fit Evaluation

#AUC for logistic regression
test.pred <- prediction(m1.prob, test.y)
test.perf <- performance(test.pred, "auc")
cat('the auc score is ', test.perf@y.values[[1]], "\n")

#AUC for LDA
lda.pred <- predict(m2, dat[-train,])
pred <- prediction(lda.pred$posterior[,2], test.y)
performance(pred,"auc")@y.values[[1]]

#AUC for KNN
knn.mod <- knn(train.x,test.x,train.y, k = 3, prob = T)
knn.pred <- prediction(attributes(knn.mod)$prob, test.y)
performance(knn.pred,"auc")@y.values[[1]]

#AUC for random forest
rf_p_test <- predict(m4, type="prob",newdata = dat_tree[-train,])[,2]
rf_pr_test <- prediction(rf_p_test, dat_tree[-train,]$los)
r_auc_test <- performance(rf_pr_test, measure = "auc")@y.values[[1]] 
r_auc_test

### Model Selection

#Best Subset Selection
regfit.full = regsubsets(los~., data = dat_tree, nvmax = 17)
reg.summary = summary(regfit.full)
reg.summary

#the best model obtained according to Cp
plot(reg.summary$cp, xlab = "Number of Variables", ylab = "Cp", type = "l")
cp.min = which.min(reg.summary$cp)
cp.min
points(cp.min, reg.summary$cp[cp.min], col = "red", cex = 2, pch = 20)

#the best model obtained according to BIC
plot(reg.summary$bic, xlab = "Number of Variables", ylab = "BIC", type = "l")
bic.min = which.min(reg.summary$bic)
bic.min
points(bic.min, reg.summary$bic[bic.min], col = "red", cex = 2, pch = 20)

#the best model obtained according to adjusted R2
plot(reg.summary$adjr2, xlab = "Number of Variables", ylab = "Adjusted R2", type = "l")
adjr2.max = which.max(reg.summary$adjr2)
adjr2.max
points(adjr2.max, reg.summary$adjr2[adjr2.max], col = "red", cex = 2, pch = 20)