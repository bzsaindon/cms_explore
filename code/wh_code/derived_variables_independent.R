#Create One Independent variable dataset to be used for all models
#Data to include
#1. 2008 & 2009 Summary Files   - rename var names
#2. Death Variables
#3. Age Variables    
#4. 2008 and 2009 HCCs      

summary_08_09<- readRDS("../derived variables/summary_2008_2009.rds")
death<- readRDS("../derived variables/death_08_09.rds")
age<- readRDS("../derived variables/age.rds")
hcc_08_09<- readRDS("../derived variables/hcc_2008_2009.rds")
hcc_09<- readRDS("../derived variables/hcc_2009.rds")
flattened_independent_variables<- merge(x = summary_08_09, y = age, by = "DESYNPUF_ID", all=TRUE)

flattened_independent_variables<- merge(x = flattened_independent_variables, y = hcc_08_09, by = "DESYNPUF_ID", all=TRUE)
#flattened_independent_variables1<- merge(x = flattened_independent_variables, y = hcc_09, by = "DESYNPUF_ID", all=TRUE)

saveRDS(flattened_independent_variables, file = "../derived variables/flattened_independent_variables.rds")
length(unique(flattened_independent_variables$DESYNPUF_ID))




