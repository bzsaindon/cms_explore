##############################################################################
#                        HCC Wide Tables                                     #
############################################################################## 
#Packages Required:   dplyr
#Input Files:         RAF.rds
#Output Files:        hcc_2008.rds
#                     hcc_2009.rds
#                     hcc_2008_2009.rds
#                     hcc_2010.rds

library(dplyr)
raf_test<- readRDS("../derived variables/RAF.rds")
raf_test<- raf_test[c("DESYNPUF_ID", "hcc2014", "CLM_THRU_DT")]
raf_test<- raf_test[!(is.na(raf_test$hcc2014)),]
raf_test$year<- substr(raf_test$CLM_THRU_DT, 1, 4)

deduped.data <- unique(raf_test[ , c("DESYNPUF_ID", "hcc2014", "year") ] )

wide.data_2008 <-deduped.data[deduped.data$year==2008,] %>%
  reshape(.,
                  idvar = "DESYNPUF_ID",
                  v.names = c("hcc2014"),
                  timevar = "hcc2014",
                  direction = "wide")%>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"_2008"))) 
wide.data_2009 <-deduped.data[deduped.data$year==2009,] %>%
  reshape(.,
          idvar = "DESYNPUF_ID",
          v.names = c("hcc2014"),
          timevar = "hcc2014",
          direction = "wide")%>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"_2009"))) 
wide.data_2010 <-deduped.data[deduped.data$year==2010,] %>%
  reshape(.,
          idvar = "DESYNPUF_ID",
          v.names = c("hcc2014"),
          timevar = "hcc2014",
          direction = "wide")%>%
  setNames(c(names(.)[1], paste0(names(.)[-1],"_2010"))) 

wide.data_2008[ , !names(wide.data_2008) %in% c("DESYNPUF_ID", "year_2008")]<- ifelse(is.na(wide.data_2008[ , !names(wide.data_2008) %in% c("DESYNPUF_ID", "year_2008")]), 0, 1)
wide.data_2009[ , !names(wide.data_2009) %in% c("DESYNPUF_ID", "year_2009")]<- ifelse(is.na(wide.data_2009[ , !names(wide.data_2009) %in% c("DESYNPUF_ID", "year_2009")]), 0, 1)
wide.data_2010[ , !names(wide.data_2010) %in% c("DESYNPUF_ID", "year_2010")]<- ifelse(is.na(wide.data_2010[ , !names(wide.data_2010) %in% c("DESYNPUF_ID", "year_2010")]), 0, 1)
wide.data_2008$year_2008<- NULL 
wide.data_2009$year_2009<- NULL 
wide.data_2010$year_2010<- NULL 

hcc_2008_2009<- merge.data.frame(x = wide.data_2008, y = wide.data_2009, by ="DESYNPUF_ID", all=TRUE)
hcc_2008_2009<- ifelse(is.na(hcc_2008_2009), 0, hcc_2008_2009)
hcc_2010<-wide.data_2010


saveRDS(hcc_2008_2009, file = "../derived variables/hcc_2008_2009.rds")
saveRDS(wide.data_2008, file = "../derived variables/hcc_2008.rds")
saveRDS(wide.data_2009, file = "../derived variables/hcc_2009.rds")
saveRDS(hcc_2010, file = "../derived variables/hcc_2010.rds")
