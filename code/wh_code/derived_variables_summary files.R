#Create Independent variable datasets flattening year 1 and year 2 data
#Data to include
#1. 2008 & 2009 Summary Files   - rename var names


summary_2008<-DE1_0_2008_Beneficiary_Summary_File_Sample_1 
summary_2009<-DE1_0_2009_Beneficiary_Summary_File_Sample_1 
summary_2010<-DE1_0_2010_Beneficiary_Summary_File_Sample_1

summary_2008<- summary_2008 %>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"_2008"))) 
summary_2009<- summary_2009 %>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"_2009"))) 
summary_2010<- summary_2010 %>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"_2010"))) 
summary_2008_2009<- merge.data.frame(x = summary_2008, y = summary_2009, by = "DESYNPUF_ID", all=TRUE)
saveRDS(summary_2008, file = "../derived variables/summary_2008.rds")
saveRDS(summary_2009, file = "../derived variables/summary_2009.rds")
saveRDS(summary_2008_2009, file = "../derived variables/summary_2008_2009.rds")
saveRDS(summary_2010, file = "../derived variables/summary_2010.rds")
