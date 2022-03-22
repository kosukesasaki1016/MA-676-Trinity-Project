Sys.setenv("LANGUAGE" = "EN")
Sys.setlocale("LC_ALL", "C")
library(dplyr)

summary <- read.csv("DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv", header = T)
inpatient <- read.csv("DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv",header = T)
outpatient <- read.csv("DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv", header = T)

msin <- filter(inpatient,ICD9_DGNS_CD_1==340)
msout <- filter(outptient,ICD9_DGNS_CD_1==340)

