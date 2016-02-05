##############################################################################
#                        RAF Table                                           #
############################################################################## 
#Packages Required:   stringr, 
#                     dplyr
#Input Files:         DE1_0_2008_to_2010_Inpatient_Claims_Sample_1,
#                     DE1_0_2008_to_2010_Outpatient_Claims_Sample_1
#                     hccxwalk.csv
#                     cms_short_long_desc.csv
#Output Files:        RAF.rds
library(stringr)
library(dplyr)

# 1. Call in ICD9 - HCC X walk

xwalk<-read.csv("../lookup/hccxwalk.csv",sep=",",quote = ",", header=TRUE, stringsAsFactors = FALSE, na.strings = c(" ", ""))
xwalk<-select(xwalk, icd, hcc2014, shortdesc)
xwalk$icd<- as.factor(xwalk$icd)


##################
#   Inpatient  #
#################
ip_tmp <- DE1_0_2008_to_2010_Inpatient_Claims_Sample_1[, c("DESYNPUF_ID","CLM_THRU_DT", "ADMTNG_ICD9_DGNS_CD", "ICD9_DGNS_CD_1", "ICD9_DGNS_CD_2", "ICD9_DGNS_CD_3", "ICD9_DGNS_CD_4", "ICD9_DGNS_CD_5", "ICD9_DGNS_CD_6", "ICD9_DGNS_CD_7", "ICD9_DGNS_CD_8", "ICD9_DGNS_CD_9", "ICD9_DGNS_CD_10")]
ip_tmp1<-reshape(ip_tmp, idvar=c("DESYNPUF_ID", "CLM_THRU_DT"), timevar= "ClM_THRU_DT", varying = list(grep('ICD9', names(ip_tmp),value=TRUE)),direction="long", new.row.names = 1:1000000)
rownames(ip_tmp1) <- c()
ip_tmp1$source_clm<-c("IP")
ip_tmp1$ADMTNG_ICD9_DGNS_CD<-as.factor(ip_tmp1$ADMTNG_ICD9_DGNS_CD)
raf_ip<-select(ip_tmp1, DESYNPUF_ID, CLM_THRU_DT, icd = ADMTNG_ICD9_DGNS_CD ,source_clm)
raf_ip$icd<-str_trim(raf_ip$icd, side = c("both"))
xwalk$icd<-str_trim(xwalk$icd, side = c("both"))
raf_ip<- merge(x = raf_ip, y = xwalk, by = "icd", all.x=TRUE)
raf_ip <- raf_ip[!is.na(raf_ip$icd),]

##################
#   Outpatient  #
#################
op_tmp <- DE1_0_2008_to_2010_Outpatient_Claims_Sample_1[, c("DESYNPUF_ID","CLM_THRU_DT","ADMTNG_ICD9_DGNS_CD", "ICD9_DGNS_CD_1", "ICD9_DGNS_CD_2", "ICD9_DGNS_CD_3", "ICD9_DGNS_CD_4", "ICD9_DGNS_CD_5", "ICD9_DGNS_CD_6", "ICD9_DGNS_CD_7", "ICD9_DGNS_CD_8", "ICD9_DGNS_CD_9", "ICD9_DGNS_CD_10")]
op_tmp1<-reshape(op_tmp, idvar=c("DESYNPUF_ID", "CLM_THRU_DT"), varying = list(grep('ICD9', names(op_tmp),value=TRUE)),direction="long", new.row.names = 1:100000000)
rownames(op_tmp1) <- c()
op_tmp1$source_clm<-c("OP")
op_tmp1$ADMTNG_ICD9_DGNS_CD<-as.factor(op_tmp1$ADMTNG_ICD9_DGNS_CD)
raf_op<-select(op_tmp1, DESYNPUF_ID, CLM_THRU_DT, icd = ADMTNG_ICD9_DGNS_CD ,source_clm)
raf_op$icd<-str_trim(raf_op$icd, side = c("both"))
xwalk$icd<-str_trim(xwalk$icd, side = c("both"))
raf_op<- merge(x = raf_op, y = xwalk, by = "icd", all.x=TRUE)
raf_op <- raf_op[!is.na(raf_op$icd),]



#######################
#   ICD Descriptions  #
#######################

#1. call in cms x walk

cmsxwalk<-read.csv("../lookup/cms_short_long_desc.csv",sep=",", quote = ",", header=TRUE, stringsAsFactors = FALSE, row.names=NULL)

#2. Merge names to raf table
#Combine IP OP to one RAF table
RAF<- rbind(raf_op, raf_ip)
RAF<- merge(x = RAF, y = cmsxwalk, by = "icd", all.x=TRUE)
RAF<-select(RAF, -X)
saveRDS(RAF, file = "../derived variables/RAF.rds")


