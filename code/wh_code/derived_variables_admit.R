#index admits
#caluclate the denominator for readmission counts
library(dplyr)
ip_tmp <- DE1_0_2008_to_2010_Inpatient_Claims_Sample_1[1:10000, c("DESYNPUF_ID","CLM_ADMSN_DT","NCH_BENE_DSCHRG_DT")]
#                                                         "CLM_FROM_DT", "CLM_THRU_DT", "ADMTNG_ICD9_DGNS_CD", "ICD9_DGNS_CD_1", "ICD9_DGNS_CD_2", "ICD9_DGNS_CD_3", "ICD9_DGNS_CD_4", "ICD9_DGNS_CD_5", "ICD9_DGNS_CD_6", "ICD9_DGNS_CD_7", "ICD9_DGNS_CD_8", "ICD9_DGNS_CD_9", "ICD9_DGNS_CD_10")]

ip_tmp$CLM_ADMSN_DT<-as.factor(ip_tmp$CLM_ADMSN_DT)
ip_tmp$CLM_ADMSN_DT<- as.Date(ip_tmp$CLM_ADMSN_DT, "%Y%m%d" )

ip_tmp$NCH_BENE_DSCHRG_DT<-as.factor(ip_tmp$NCH_BENE_DSCHRG_DT)
ip_tmp$NCH_BENE_DSCHRG_DT<- as.Date(ip_tmp$NCH_BENE_DSCHRG_DT, "%Y%m%d" )

#Step 1: Include all ip clm with discharge dates from Jan 1 through Dec 1 of measurement year

ip.step1 <- subset(ip_tmp, NCH_BENE_DSCHRG_DT > "2008-01-01" & NCH_BENE_DSCHRG_DT < "2008-12-01")

#Step 2: Acute to Acute transfer
#a.  if new admit date - discharge date
ip.step1 %>% group_by(DESYNPUF_ID) %>% last(ip.step1$NCH_BENE_DSCHRG_DT)
test<- ip.step1 %>%
  group_by(DESYNPUF_ID) %>%
  mutate(before.adm_dt = lag(CLM_ADMSN_DT, order_by=DESYNPUF_ID),
         before.dis_dt = lag(NCH_BENE_DSCHRG_DT, order_by=DESYNPUF_ID))
test$counter <- with(test, ave(DESYNPUF_ID, DESYNPUF_ID, FUN = seq_along))

test$new_adm_date<-ifelse(test$counter==1, test$CLM_ADMSN_DT, NA)
test$new_adm_date<-ifelse(!test$counter==1 & test$before.dis_dt >= test$CLM_ADMSN_DT , test$before.adm_dt, test$new_adm_date)
test$new_adm_date<-ifelse(!test$counter==1 & (test$before.dis_dt + 1 < test$CLM_ADMSN_DT), test$CLM_ADMSN_DT, test$new_adm_date)
test$new_adm_date <- as.Date(test$new_adm_date,
                       origin = "1970-01-01")
#SAS code below
#if first.&member=1 then do; new_adm_dt=&adm_dt; end; *<== if first member new_dis_dt is dis_dt;
#if first.&member=0 and (lag_dis_dt = &adm_dt OR lag_dis_dt+1 = &adm_dt OR lag_dis_dt >= &adm_dt) then do;
#new_adm_dt=new_adm_dt; end;*<== if no gap or over lapping reset adm_dt;
#if first.member=0 and lag_dis_dt+1< &adm_dt then do;new_adm_dt=&adm_dt;  end;*<== if gap present reset;

transfer_collapse<- test %>%
  group_by(DESYNPUF_ID, new_adm_date, NCH_BENE_DSCHRG_DT) %>%
  summarise(new_dis_date = max(NCH_BENE_DSCHRG_DT))

test_transfer<- transfer_collapse %>%
  group_by(DESYNPUF_ID,new_adm_date) %>%
  arrange(NCH_BENE_DSCHRG_DT) %>%
  filter(row_number()==n())

test_transfer<- select(test_transfer, DESYNPUF_ID, new_adm_date, new_dis_date)
test_transfer<- rename(test_transfer, CLM_ADMSN_DT = new_adm_date, NCH_BENE_DSCHRG_DT= new_dis_date)

#step3 - exclude if new admt date == new discharge date
test_transfer$same_day_discharge<-ifelse(test_transfer$CLM_ADMSN_DT==test_transfer$NCH_BENE_DSCHRG_DT, 1, 0)

index_admits <- test_transfer[test_transfer$same_day_discharge == "0",]
index_admits<- rename(index_admits, dis_dt_i = NCH_BENE_DSCHRG_DT, )
index_admits$indx_adm<- 1
index_admits$i_adm_dt<- index_admits$CLM_ADMSN_DT
index_admits$i_dis_dt<- index_admits$dis_dt_i


proc sql;
create table transfer_collapse as
select &member,&diagc1,&diagc2, &diagc3, &diagc4, &diagc5,
&adm_dt, &dis_dt, new_adm_dt format mmddyy8., max(&dis_dt) as new_dis_dt format mmddyy8.
from acute_ips group by &member, new_adm_dt, &dis_dt;
quit;


