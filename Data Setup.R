Sys.setenv("LANGUAGE" = "EN")
Sys.setlocale("LC_ALL", "C")
library(dplyr)
library(ggplot2)
library(usmap)

#Read in datafiles
Adm <- read.csv("Admission.csv", header = T)
Claim <- read.csv("Claim.csv",header = T)
ICD <- read.csv("ClaimICD.csv", header = T)

Adm <- dplyr::select(Adm, patientID = 1, dplyr::everything())
Claim <- dplyr::select(Claim, patientID = 2, dplyr::everything())

# Merge Adm and Claim
Mix <- inner_join(Adm, Claim, by = "patientID")
Mix2 <- Mix %>% select( patientID,ADMISSION_DATE, DISCHARGE_DATE, SRVC_FROM_DATE, SRVC_THRU_DATE, STATE_CODE, TOT_NET, TOT_COB, TOT_OOP,  TOT_COINS, TOT_COPAY ,TOT_DED ,     
                        CLM_PMT_AMT, OUT_OF_POCKET, COB, ALLOWED_AMOUNT, CHARGE)
# Convert charcter to date file
for(i in 2:5){
  Mix2[,i] <- as.Date(Mix2[,i])
}
# Compare the relevant variables
Mix2$dif1 <- Mix2$SRVC_FROM_DATE-Mix2$ADMISSION_DATE
Mix2$dif2 <- Mix2$DISCHARGE_DATE-Mix2$SRVC_FROM_DATE
Mix2$dif <- ifelse(Mix2$dif1>=0 & Mix2$dif2>=0, 1, 0)
Mix3 <- filter(Mix2, dif==1)
Mix4 <- Mix3[,-c(10:12)]
Mix4 <- Mix4 %>%  distinct(patientID, SRVC_FROM_DATE, .keep_all=T)
write.csv(Mix4,"Admission_Claim_Mergedata.csv", row.names = FALSE)


# Calculate mean OOP and NET (this is not per person per year) 
Adm1 <-Adm %>%
  group_by(STATE_CODE) %>%
  summarise_at(vars(TOT_OOP,TOT_NET), list(name = mean))

# rename variables
Adm1 <- dplyr::select(Adm1, OOP = 2, NET=3 , dplyr::everything())

# Plot NET vs OOP by state
ggplot(Adm1)+geom_point(mapping = aes(x = NET, y = OOP, color = STATE_CODE))
# ggplot(Adm)+geom_point(mapping = aes(x = TOT_NET, y = TOT_OOP, color = STATE_CODE))+
#   xlim(0, 100000)

# US map of NET
data(statepop)
statepop$STATE_CODE <- statepop$abbr
statepop <- inner_join(statepop, Adm1, by = "STATE_CODE")
plot_usmap(data = statepop, values = "NET", color = "red") + 
  scale_fill_continuous(name = "NET coverage by Medicare (2018)", label = scales::comma) + 
  theme(legend.position = "right")
