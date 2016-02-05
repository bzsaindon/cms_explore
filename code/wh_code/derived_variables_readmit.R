
ip_tmp <- DE1_0_2008_to_2010_Inpatient_Claims_Sample_1[1:10000, c("DESYNPUF_ID","CLM_ADMSN_DT","NCH_BENE_DSCHRG_DT")]
#                                                         "CLM_FROM_DT", "CLM_THRU_DT", "ADMTNG_ICD9_DGNS_CD", "ICD9_DGNS_CD_1", "ICD9_DGNS_CD_2", "ICD9_DGNS_CD_3", "ICD9_DGNS_CD_4", "ICD9_DGNS_CD_5", "ICD9_DGNS_CD_6", "ICD9_DGNS_CD_7", "ICD9_DGNS_CD_8", "ICD9_DGNS_CD_9", "ICD9_DGNS_CD_10")]

ip_tmp$CLM_ADMSN_DT<-as.factor(ip_tmp$CLM_ADMSN_DT)
ip_tmp$CLM_ADMSN_DT<- as.Date(ip_tmp$CLM_ADMSN_DT, "%Y%m%d" )

ip_tmp$NCH_BENE_DSCHRG_DT<-as.factor(ip_tmp$NCH_BENE_DSCHRG_DT)
ip_tmp$NCH_BENE_DSCHRG_DT<- as.Date(ip_tmp$NCH_BENE_DSCHRG_DT, "%Y%m%d" )

#step 1 - identify all acute ip stays between jan 2 - dec 31

ip.step1 <- subset(ip_tmp, NCH_BENE_DSCHRG_DT > "2008-01-02" & NCH_BENE_DSCHRG_DT < "2008-12-31")

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


N_step2<- transfer_collapse %>%
  group_by(DESYNPUF_ID,new_adm_date) %>%
  arrange(NCH_BENE_DSCHRG_DT) %>%
  filter(row_number()==n())

N_step2<- select(N_step2, DESYNPUF_ID, new_adm_date, new_dis_date)
N_step2<- rename(N_step2, CLM_ADMSN_DT = new_adm_date, NCH_BENE_DSCHRG_DT= new_dis_date)

#Step 3 Exclude acute inpatient hospital discharges with a principal diagnosis of pregnancy (Pregnancy Value Set) or a principal diagnosis for a
#condition originating in the perinatal period (Perinatal Conditions Value Set). 

#step 4: Determine if any of acute inpatient stays have an admit within 30 days after indx discharge date ***;
#4.a mergen_step2 to denom data

s4test<- merge(x = N_step2, y = index_admits, by = c("DESYNPUF_ID", "CLM_ADMSN_DT"), all = TRUE)
s4test$indx_adm<-ifelse(is.na(s4test$indx_adm), 0,s4test$indx_adm )

#if first.&member=1 or indx_adm=1 then do;
#temp_adm_dt=i_adm_dt; temp_dis_dt=i_dis_dt;
#end;
s4test$counter <- with(s4test, ave(DESYNPUF_ID, DESYNPUF_ID, FUN = seq_along))
s4test$temp_adm_dt<-ifelse(s4test$counter==1,  s4test$i_adm_dt, NA )
s4test$temp_dis_dt<-ifelse(s4test$counter==1,  s4test$i_dis_dt, NA )

s4test<- s4test %>%
  group_by(DESYNPUF_ID) %>%
  mutate(lag.id = lag(DESYNPUF_ID, order_by=DESYNPUF_ID))

#if &member=lag(&member) and indx_adm=0 then do;
#   if (&adm_dt-temp_dis_dt<=30) then do; 
#   i_adm_dt=temp_adm_dt; i_dis_dt=temp_dis_dt; 
#   end;
# end;

s4test$i_adm_dt<-ifelse(s4test$DESYNPUF_ID==s4test$lag.id & s4test$indx_adm==0, 
                        ifelse((s4test$CLM_ADMSN_DT - s4test$temp_dis_dt <=30), s4test$temp_adm_dt, s4test$i_adm_dt),s4test$i_adm_dt)
s4test$i_dis_dt<-ifelse(s4test$DESYNPUF_ID==s4test$lag.id & s4test$indx_adm==0, 
                        ifelse((s4test$CLM_ADMSN_DT - s4test$temp_dis_dt <=30), s4test$temp_dis_dt, s4test$i_dis_dt),s4test$i_dis_dt)
s4test$readm30<- 0

#if &member=lag(&member) and temp_dis_dt^=. and 0<&adm_dt-temp_dis_dt<=30 then readm30=1; 



###test
s4test<- s4test %>%
  group_by(DESYNPUF_ID) %>%
  mutate(lag.dis_dt = lag(NCH_BENE_DSCHRG_DT, order_by=DESYNPUF_ID))

s4test<- s4test %>% 
  mutate(daydiff = CLM_ADMSN_DT - lag.dis_dt)
s4test$daydiff<- ifelse(lag.id==DESYNPUF_ID,s4test$daydiff, NA )
s4test$admit30<- ifelse(s4test$daydiff<30 & s4test$daydiff>0,1, 0)


