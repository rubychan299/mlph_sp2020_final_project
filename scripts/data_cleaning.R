library(readr)
library(tidyverse)

# Import the dataset
dat <- read_csv("dataset_diabetes/diabetic_data.csv")

# Data cleaning
dat <- dat %>% 
  dplyr::select(-encounter_id,-patient_nbr,-payer_code,-discharge_disposition_id,-admission_source_id, -medical_specialty, -diag_1, -diag_2, -diag_3, -weight)

summary(dat$time_in_hospital)

dat <- dat %>% 
  mutate_at(vars(15:37),
            ~as.numeric(recode(.,"No"=0, 
                               "Steady"=1,
                               "Down"=1,
                               "Up"=1)))

dat <- dat %>% 
  mutate(los = case_when(
    time_in_hospital < 4.4 ~ 0,
    time_in_hospital >= 4.4 ~ 1),
    age = factor(age),
    A1Cresult = factor(A1Cresult),
    admission_type_id = factor(admission_type_id),
    max_glu_serum = factor(max_glu_serum),
    change = factor(change),
    diabetesMed = factor(diabetesMed),
    readmitted = factor(readmitted))

dat$num_diabetesMed <- rowSums(dat[,c(15:37)])

dat <- dat[,-c(15:37)]

dat <- dat %>% 
  dplyr::select(-time_in_hospital)

dat <- filter(dat, race!="?"&gender!="Unknown/Invalid")

dat <- dat %>% mutate(race = factor(race))

summary(dat$race)
summary(dat$admission_type_id)
summary(dat$A1Cresult)
summary(dat$change)
summary(dat$los)