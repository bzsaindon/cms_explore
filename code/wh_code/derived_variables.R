#######
#Create Death Flag Using Demo Table
######

death_flag_2008 <- ifelse(is.na(DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)
death_flag_2009 <- ifelse(is.na(DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)
death_flag_2010 <- ifelse(is.na(DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)

death_08<-as.data.frame(cbind(DE1_0_2008_Beneficiary_Summary_File_Sample_1$DESYNPUF_ID, ifelse(is.na(DE1_0_2008_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)))
colnames(death_08)<- c("DESYNPUF_ID", "DEATH08")
death_09<-as.data.frame(cbind(DE1_0_2009_Beneficiary_Summary_File_Sample_1$DESYNPUF_ID, ifelse(is.na(DE1_0_2009_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)))
colnames(death_09)<- c("DESYNPUF_ID", "DEATH09")
death_10<-as.data.frame(cbind(DE1_0_2010_Beneficiary_Summary_File_Sample_1$DESYNPUF_ID, ifelse(is.na(DE1_0_2010_Beneficiary_Summary_File_Sample_1$BENE_DEATH_DT), 0, 1)))
colnames(death_10)<- c("DESYNPUF_ID", "DEATH10")
death_dv<-merge.data.frame(death_08, death_09, by = "DESYNPUF_ID", all = TRUE)
death_dv<-merge.data.frame(death_dv, death_10, by = "DESYNPUF_ID", all = TRUE)

###
# HCC Flags
###
