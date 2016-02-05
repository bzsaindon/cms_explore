##############################################################################
#                        File Read In                                       #
############################################################################## 
getwd()
setwd("/Users/briansaindon/desktop/cms_puf/data/")

filenames<- read.csv("recdfiles.csv",sep=",",quote = ",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))

DE1_0_2008_Beneficiary_Summary_File_Sample_1 <- read.csv("DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))
DE1_0_2009_Beneficiary_Summary_File_Sample_1 <- read.csv("DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))
DE1_0_2010_Beneficiary_Summary_File_Sample_1 <- read.csv("DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv",sep=",",header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))

DE1_0_2008_to_2010_Carrier_Claims_Sample_1A <- read.csv("DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))
DE1_0_2008_to_2010_Carrier_Claims_Sample_1B <- read.csv("DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))

DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 <- read.csv("DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))
DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 <- read.csv("DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))

DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1 <- read.csv("DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv",sep=",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))



#Age
DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT<- as.factor(DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT)
DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT_1<- as.Date(DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT, "%Y%m%d" )
DE1_0_2008_Beneficiary_Summary_File_Sample_1$AGE<-as.numeric(floor((difftime("2008-12-31", DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT_1, units = "days")/365)))

age<-DE1_0_2008_Beneficiary_Summary_File_Sample_1[c("DESYNPUF_ID", "AGE")]
saveRDS(age, file = "../derived variables/age.rds")
hist(DE1_0_2008_Beneficiary_Summary_File_Sample_1$AGE)

DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT<- as.factor(DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT)
DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT_1<- as.Date(DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT, "%Y%m%d" )
DE1_0_2009_Beneficiary_Summary_File_Sample_1$AGE<-as.numeric(floor((difftime("2009-12-31", DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT_1, units = "days")/365)))
hist(DE1_0_2009_Beneficiary_Summary_File_Sample_1$AGE)

DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT<- as.factor(DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT)
DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT_1<- as.Date(DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT, "%Y%m%d" )
DE1_0_2010_Beneficiary_Summary_File_Sample_1$AGE<-as.numeric(floor((difftime("2010-12-31", DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_BIRTH_DT_1, units = "days")/365)))
hist(DE1_0_2010_Beneficiary_Summary_File_Sample_1$AGE)

#Death_Flag
DE1_0_2008_Beneficiary_Summary_File_Sample_1$Death_Flag <- ifelse(is.na(DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)
DE1_0_2009_Beneficiary_Summary_File_Sample_1$Death_Flag <- ifelse(is.na(DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)
DE1_0_2010_Beneficiary_Summary_File_Sample_1$Death_Flag <- ifelse(is.na(DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)





