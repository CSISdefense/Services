# ---
# title: "Create Services Sample"
# output:
#   html_document:
#     keep_md: yes
#     toc: yes
# date: "Wednesday, July 11, 2019"
# ---

#Setup
library(csis360)
library(ggplot2)
library(dplyr)
library(arm)
library(knitr)
library(foreign)
library(stargazer)
library(texreg)
library(reshape2)
library(tidyverse)
library(foreign)
source("https://raw.githubusercontent.com/CSISdefense/Vendor/master/Scripts/DIIGstat.r")

if(!exists("def_serv")) load("data/clean/transformed_def_serv.Rdata")
def_serv<-transition_variable_names_FMS(def_serv)


contract_transform_verify(def_serv)

def_serv$Action_Obligation.OMB20_GDP18

## Computational Sample Creation
summary(def_serv$UnmodifiedBase_Then_Year)
summary(def_serv$UnmodifiedCeiling_Then_Year)



#Ceil2Base exploring
ggplot(def_serv %>% filter(Ceil2Base>1 & Ceil2Base<10),aes(x=Ceil2Base))+geom_histogram(bins=30)
ggplot(def_serv %>% filter(Ceil2Base>1),aes(x=Ceil2Base))+geom_histogram(bins=30)+scale_x_log10()
ggplot(def_serv %>% filter(Ceil2Base>1),aes(x=Ceil2Base))+geom_histogram(bins=50)+scale_x_log10()
# def_serv$cp_AvlOpt<-arm::rescale(def_serv$p_AvlOpt)
# def_serv <-def_serv %>% dplyr::select(-AvlOpt,-p_AvlOpt,-cp_AvlOpt)


#Output variables
summary(def_serv$b_Term)
summary(def_serv$ln_CBre_OMB20_GDP18)
summary(def_serv$ln_OptGrowth_OMB20_GDP18) 
summary(def_serv$AnyUnmodifiedUnexercisedOptions)
#Study Variables
summary(def_serv$cln_US6sal)
summary(def_serv$cln_PSCrate) 
summary(def_serv$cp_OffPerf7) 
summary(def_serv$cp_OffPSC7) 
summary(def_serv$cn_PairHist7)
summary(def_serv$cln_PairCA)
#Controls
summary(def_serv$Comp)
summary(def_serv$cln_Ceil)
summary(def_serv$cln_Base)
summary(def_serv$cln_Days)
summary(def_serv$Veh) 
summary(def_serv$PricingUCA)
summary(def_serv$Place)
summary(def_serv$NAICS6)
summary(def_serv$NAICS3)
summary(def_serv$Office)
summary(def_serv$Agency)
summary(def_serv$StartCY)
summary(def_serv$cln_Def3HHI) 
summary(def_serv$clr_Def3toUS)
summary(def_serv$cln_Def6HHI)
summary(def_serv$cln_Def6Obl)
summary(def_serv$clr_Def6toUS)
summary(def_serv$cln_US6sal) 
#New Controls
summary(def_serv$cp_PairObl7)
summary(def_serv$Crisis)
summary(def_serv$cln_OffFocus)  
summary(def_serv$cl_office_naics_hhi_obl) 

complete<-
  #Dependent Variables
  !is.na(def_serv$b_Term)& #summary(def_serv$b_Term)
  !is.na(def_serv$b_CBre)&
  # !is.na(def_serv$ln_CBre_OMB20_GDP18)&
  # !is.na(def_serv$ln_OptGrowth)&
  !is.na(def_serv$AnyUnmodifiedUnexercisedOptions)&
  #Study Variables
  !is.na(def_serv$cln_US6sal)&
  !is.na(def_serv$cln_PSCrate)&
  !is.na(def_serv$cp_OffPerf7)&
  !is.na(def_serv$cp_OffPSC7)&
  !is.na(def_serv$cn_PairHist7)&
  !is.na(def_serv$cln_PairCA)&
  #Controls
  !is.na(def_serv$Comp)&
  !is.na(def_serv$clr_Ceil2Base)&
  !is.na(def_serv$cln_Base)&
  !is.na(def_serv$cln_Days)&
  !is.na(def_serv$Veh) &
  !is.na(def_serv$PricingUCA)&
  !is.na(def_serv$Place)& #New Variable
  # !is.na(def_serv$b_UCA)& No longer  used
  !is.na(def_serv$NAICS6)&
  !is.na(def_serv$NAICS3)&
  !is.na(def_serv$Office)&
  !is.na(def_serv$Agency)&
  !is.na(def_serv$StartCY)&
  !is.na(def_serv$cln_Def3HHI)&
  !is.na(def_serv$clr_Def3toUS)&
  !is.na(def_serv$cln_Def6HHI)&
  !is.na(def_serv$cln_Def6Obl)&
  !is.na(def_serv$clr_Def6toUS)&
  #New Controls
  !is.na(def_serv$cln_OffObl7)& #summary(def_serv$cln_OffObl7)
  !is.na(def_serv$cp_PairObl7)&  #summary(def_serv$cp_PairObl7)
  !is.na(def_serv$Crisis)&  #summary(def_serv$cp_PairObl7)
  !is.na(def_serv$cln_OffFocus)&
  !is.na(def_serv$clr_Ceil2Base)


summary(complete)
money<-def_serv$Action_Obligation_OMB20_GDP18
any(def_serv$Action_Obligation_OMB20_GDP18<0)
money[def_serv$Action_Obligation_OMB20_GDP18<0]<-0
sum(def_serv$Action_Obligation_OMB20_GDP18[def_serv$Action_Obligation_OMB20_GDP18<0])

#Missing data, how many records and how much money
length(money[!complete])/length(money)
sum(money[!complete],na.rm=TRUE)/sum(money,na.rm=TRUE)

#What portion of contracts have potential options, 
sum(money[def_serv$AnyUnmodifiedUnexercisedOptions==1],na.rm=TRUE)/
  sum(money,na.rm=TRUE)

#Missing data with potential options how much money?
length(money[!complete&def_serv$AnyUnmodifiedUnexercisedOptions==1])/
  length(money[def_serv$AnyUnmodifiedUnexercisedOptions==1])
sum(money[!complete&def_serv$AnyUnmodifiedUnexercisedOptions==1],na.rm=TRUE)/
  sum(money[def_serv$AnyUnmodifiedUnexercisedOptions==1],na.rm=TRUE)

#Refreshing
serv_complete<-def_serv[complete,]
serv_smp1m<-serv_complete[sample(nrow(serv_complete),1000000),]
serv_smp<-serv_complete[sample(nrow(serv_complete),250000),]
rm(serv_complete)
serv_opt<-def_serv[complete&def_serv$AnyUnmodifiedUnexercisedOptions==1,]
serv_exeropt<-serv_opt[serv_opt$OptExer %in% c("Some Options","Some and All Options"),]
serv_breach<-def_serv[complete&def_serv$b_CBre==1,]

#To instead replace entries in existing sample, use  this code.
# load(file="data/clean/def_sample.Rdata")
# serv_smp<-update_sample_col_CSIScontractID(serv_smp,
#                                            def_serv[complete,],
#                                            col=NULL,
#                                            drop_and_replace=TRUE)
# 
# serv_smp1m<-update_sample_col_CSIScontractID(serv_smp1m,
#                                            def_serv[complete,],
#                                            col=NULL,
#                                            drop_and_replace=TRUE)
# 
# serv_opt<-update_sample_col_CSIScontractID(serv_opt,
#                                              def_serv[complete,],
#                                              col=NULL,
#                                              drop_and_replace=TRUE)

# serv_smp<-serv_smp %>% dplyr::select(-c(Ceil, qCRais))
# serv_smp1m<-serv_smp1m %>% dplyr::select(-c(Ceil, qCRais))
# serv_opt<-serv_opt %>% dplyr::select(-c(Ceil, qCRais))





# # load(file="data\\semi_clean\\serv_opt.rdata")
# summary(serv_exeropt$n_CBre_Then_Year)
# serv_exeropt$n_CBre_Then_Year<-serv_exeropt$n_CBre_Then_Year-1
# serv_exeropt$n_CBre_Then_Year[serv_exeropt$override_change_order_growth==TRUE]<-NA
# summary(serv_exeropt$n_CBre_Then_Year)
# summary(serv_exeropt$ln_CBre_Then_Year)
# serv_exeropt$ln_CBre_Then_Year<-na_non_positive_log(serv_exeropt$n_CBre_Then_Year)
# summary(serv_exeropt$ln_CBre_Then_Year)
# serv_exeropt<-serv_exeropt %>% dplyr::select(-n_CBre_OMB20_GDP18,-ln_CBre_OMB20_GDP18)
# colnames(serv_exeropt)[colnames(serv_exeropt)=="n_CBre_Then_Year"]<-"n_CBre"
# serv_exeropt<-deflate(serv_exeropt,
#                   money_var = "n_CBre",
#                   # deflator_var="OMB.2019",
#                   fy_var="StartFY"
# )
# summary(serv_exeropt$n_CBre_OMB20_GDP18)
# serv_exeropt$ln_CBre_OMB20_GDP18<-na_non_positive_log(serv_exeropt$n_CBre_OMB20_GDP18)
# summary(serv_exeropt$ln_CBre_OMB20_GDP18)

colnames(serv_smp)[colnames(serv_smp)=="CrisisProductOrServiceArea"]<-"ServArea"
colnames(serv_smp1m)[colnames(serv_smp1m)=="CrisisProductOrServiceArea"]<-"ServArea"
colnames(serv_opt)[colnames(serv_opt)=="CrisisProductOrServiceArea"]<-"ServArea"
colnames(serv_exeropt)[colnames(serv_exeropt)=="CrisisProductOrServiceArea"]<-"ServArea"
colnames(serv_breach)[colnames(serv_breach)=="CrisisProductOrServiceArea"]<-"ServArea"


save(file="data/clean/def_sample.Rdata",serv_smp,serv_smp1m,serv_opt,serv_exeropt,serv_breach)
write.foreign(df=serv_smp,
              datafile="data//clean//def_serv_sample250k.dat",
              codefile="data//clean//def_serv_sample250k_code.do",
              package = "Stata")
write.foreign(df=serv_smp1m,
              datafile="data//clean//def_serv_sample1m.dat",
              codefile="data//clean//def_serv_sample1m_code.do",
              package = "Stata")
write.foreign(df=serv_opt,
              datafile="data//clean//def_serv_opt.dat",
              codefile="data//clean//def_serv_opt_code.do",
              package = "Stata")
