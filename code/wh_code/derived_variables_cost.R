#identify dependent variable for cost models
#1.Inpatient Annual Medicaid Reimbursement Amount; 
#2. Outpatient Annual Medicaid Reimb Amt

cost <- DE1_0_2010_Beneficiary_Summary_File_Sample_1[c("DESYNPUF_ID", "MEDREIMB_IP", "MEDREIMB_OP")]
cost<- rename(cost, MEDREIMB_IP_2010 = MEDREIMB_IP, MEDREIMB_OP_2010= MEDREIMB_OP)

saveRDS(cost, file = "../derived variables/cost_2010.rds")
saveRDS(RAF, file = "../derived variables/RAF.rds")
