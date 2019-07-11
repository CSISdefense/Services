---
title: "Create Dataset"
output:
  html_document:
    keep_md: yes
    toc: yes
date: "Wednesday, July 11, 2019"
---

#Setup
```{r Libraries, echo = FALSE}
library(csis360)
library(ggplot2)
library(dplyr)
library(arm)
library(R2WinBUGS)
library(knitr)
library(foreign)
library(stargazer)
library(texreg)
library(reshape2)
library(tidyverse)
source("https://raw.githubusercontent.com/CSISdefense/Vendor/master/Scripts/DIIGstat.r")

axis.text.size<-10
strip.text.size<-10
legend.text.size<-8
# table.text.size<-5.75
title.text.size<-12
geom.text.size<-12

main.text.size<-1
note.text.size<-1.40


```


Contracts are classified using a mix of numerical and categorical variables. While the changes in numerical variables are easy to grasp and summarize, a contract may have one line item that is competed and another that is not. As is detailed in the exploration on R&D, we are only considering information available prior to contract start. The percentage of contract obligations that were competed is a valuable benchmark, but is highly influenced by factors that occured after contract start..



##Prepare Data
First we load the data. The dataset used is a U.S. Defense Contracting dataset derived from   FPDS.


###Data Transformations and Summary



```{r ReadInData, echo = TRUE}
# load(file="../data/clean/defense_contract_complete.RData")
# 
# def_serv<-def %>% filter(PSR %in% c("Services"))
# def_serv<-def_serv[def_serv$MinOfSignedDate>=as.Date("2008-01-01") & def_serv$MinOfSignedDate<=as.Date("2015-12-31"),]
# rm(def)
#   
# #****This should be in dataset building, not transform.
#     def_serv<-read_and_join_experiment( def_serv,
#                                                    "Contract.sp_ContractEntityID.txt",
#                                                    path="",
#                                                    directory="..\\data\\semi_clean\\",
#                                                    by=c("CSIScontractID"),
#                                                    add_var=c("EntityID","UnmodifiedEntityID"),
#                                                    new_var_checked=FALSE,
#                                         create_lookup_rdata=TRUE)
#     def_serv$EntityID[is.na(def_serv$EntityID)]<-
#       def_serv$UnmodifiedEntityID[is.na(def_serv$EntityID)]
# 




# load("..\\data\\clean\\fed_transformed.rdata")
# fed <- fed %>% group_by() %>% dplyr::select(CSIScontractID,PlaceCountryISO3,Crisis)
# def_serv<-left_join(def_serv,fed)
# summary(def_serv$PlaceCountryISO3)
# summary(fed$PlaceCountryISO)
# summary(factor(def_serv$Crisis))
# rm(fed)
# #About 25.4k inexplicably missing
# # summary(def_serv[is.na(def_serv$Crisis),])
# 
# debug(transform_contract)
# # # head(def_serv)
# def_serv<-transform_contract(def_serv)
# # 
# # 
# discrete_percent_plot(def_serv,"CBre")
# discrete_percent_plot(def_serv,"Term")
# 
#   summary_discrete_plot(def_serv,"Level1_Category")
# 
# 
# # summary(def_serv$Unmodifieddef_servBaseAndAllOptionsValue)
# # summary(def_serv$Action.Obligation)
# 
# 
#   
# #This should be transferred into transform contract at some point
# cal_deflator<-remove_bom(read.csv("https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/economic/Lookup_Calendar_Deflator.csv"))
# 
# #Average salary
# def_serv$CensusYear<-factor(def_serv$StartCY)
# summary(def_serv$CensusYear)
# levels(def_serv$CensusYear)<-list("2007"=c("2008","2009","2010","2011","2012"),
#                                  "2012"=c("2013","2014","2015","2016","2017"))
# def_serv$CensusYear<-as.numeric(as.character(def_serv$CensusYear))
# cal_deflator<-cal_deflator %>% dplyr::select(Calendar_Year,BEA18)
# 
# def_serv<-dplyr::left_join(def_serv, cal_deflator,
#           by=c("CensusYear"="Calendar_Year"))
# 
# def_serv$US6_avg_sal_lag1Const<-def_serv$US6_avg_sal_lag1/def_serv$BEA18
# 
# 
# def_serv$l_US6_avg_sal_lag1Const<-na_non_positive_log(def_serv$US6_avg_sal_lag1Const)
#       def_serv$cl_US6_avg_sal_lag1Const<-arm::rescale(def_serv$l_US6_avg_sal_lag1Const)
# 
# def_serv <- def_serv  %>% dplyr::select(-BEA18)  
# colnames(def_serv[colnames(def_serv)=="US6_avg_sal_lag1"])<-"US6_avg_sal_lag1_then_year"
# colnames(def_serv[colnames(def_serv)=="cl_US6_avg_sal_lag1"])<-"cl_US6_avg_sal_lag1_then_year"
# #def6_obl_lag1Const
# def_serv<-dplyr::left_join(def_serv, cal_deflator,
#           by=c("StartCY"="Calendar_Year"))
# summary(def_serv$BEA18)
# 
# def_serv$def6_obl_lag1Const<-def_serv$def6_obl_lag1/def_serv$BEA18
# def_serv$l_def6_obl_lag1Const<-na_non_positive_log(def_serv$def6_obl_lag1Const)
#       def_serv$cl_def6_obl_lag1Const<-arm::rescale(def_serv$l_def6_obl_lag1Const)
# 
# colnames(def_serv[colnames(def_serv)=="def6_obl_lag1"])<-"def6_obl_lag1_then_year"
# colnames(def_serv[colnames(def_serv)=="cl_def6_obl_lag1"])<-"cl_def6_obl_lag1_then_year"
# 
# 




# def_serv<-def_serv[!colnames(def_serv) %in% colnames(def_serv)[grep("^l_",colnames(def_serv))]]
# save(file="../data/clean/transformed_def_serv.Rdata", def_serv)
load("../data/clean/transformed_def_serv.Rdata")


#********************Still not done***************************
#Def NAICS size
#Salary
#Both require calendar year deflators

# summary(def_serv$Action.Obligation)
# ?deflate
# debug(deflate)
# def_serv<-deflate(def_serv,
#                    money_var = "Action.Obligation",
#                    deflator_var="OMB.2019",
#                   fy_var="StartFY",
#                  path="C:/Users/gsand/Repositories/Lookup-Tables/"
# )
# def_serv<-deflate(def_serv,
#                    money_var = "Ceil",
#                    deflator_var="OMB.2019",
#                   fy_var="StartFY",
#                  path="C:/Users/gsand/Repositories/Lookup-Tables/"
# )
# def_serv$l_Ceil<-na_non_positive_log(def_serv$Ceil.OMB.2019)
# def_serv$cl_Ceil<-arm::rescale(def_serv$l_Ceil)


# def_serv<-def_serv[def_serv$PSR %in% c("Services"),]
# summary(factor(def_serv$OCO_GF))
# colnames(def_serv)[colnames(def_serv)=="Office"]<-"ContractingOfficeCode"
# 
# colnames(def_serv)[colnames(def_serv)=="StartFY"]<-"fiscal_year"
# def_serv<-read_and_join_experiment( def_serv,
#                                     "Office.sp_OfficeHistoryCapacityLaggedConst.txt",
#                                     path="",
#                                     directory="..\\data\\semi_clean\\",
#                                     by=c("ContractingOfficeCode","fiscal_year"),
#                                     add_var=c("office_obligatedamount_1year",
#                                               "office_numberofactions_1year",
#                                               "office_PBSCobligated_1year",
#                                               "office_obligatedamount_7year"),
#                                     new_var_checked=FALSE)
# def_serv<-read_and_join_experiment( def_serv,
#                                           "Office.sp_ProdServOfficeHistoryLaggedConst.txt",
#                                           path="",
#                                           directory="..\\data\\semi_clean\\",
#                                           by=c("ContractingOfficeCode","fiscal_year","ProductOrServiceCode"),
#                                           add_var=c("office_psc_obligatedamount_7year"),
#                                           new_var_checked=FALSE,
#                                     col_types="ccddddc")
# def_serv<-read_and_join_experiment( def_serv,
#                                           "Office.sp_EntityIDofficeHistoryLaggedConst.txt",
#                                           path="",
#                                           directory="..\\data\\semi_clean\\",
#                                           by=c("EntityID","ContractingOfficeCode","fiscal_year"),
#                                           add_var=c("office_entity_paircount_7year","office_entity_numberofactions_1year",
#                                                     "office_entity_obligatedamount_7year"),
#                                           new_var_checked=FALSE)
# def_serv<-read_and_join( def_serv,
#                            "ProductOrServiceCode.ProdServHistoryCFTEcoalesceLaggedConst.txt",
#                            path="",
#                            directory="..\\data\\semi_clean\\",
#                            by=c("fiscal_year","OCO_GF","ProductOrServiceCode"),
#                            add_var=c("CFTE_Rate_1year"),
#                            new_var_checked=FALSE)
#   colnames(def_serv)[colnames(def_serv)=="fiscal_year"]<-"StartFY"
# colnames(def_serv)[colnames(def_serv)=="ContractingOfficeCode"]<-"Office"





# deflate <- function(
#   data,
#   money_var = "Amount",
#   fy_var = "Fiscal_Year",
#   deflator_file = "Lookup_Deflators.csv",
#   deflator_var="OMB20_GDP18",
#   path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
#   directory="economic/",
#   deflator_dropped=TRUE
# )



length(unique((def_serv$ContractingOfficeCode)))
length(unique((def_serv$Agency)))
length(unique((def_serv$NAICS)))
length(unique((def_serv$NAICS3)))


#Removing l_s just to reduce size. They can be derived easily.

# 


# load("output//naics_join.Rdata")

```




### Variable examination
```{r VarGraph}
summary(def_serv$UnmodifiedBaseandExercisedOptionsValue)
def_serv$UnmodifiedBaseandExercisedOptionsValue[def_serv$UnmodifiedBaseandExercisedOptionsValue<=0]<-NA



def_serv$l_base<-log(def_serv$UnmodifiedBaseandExercisedOptionsValue+1)
def_serv$p_OptGrowth<-def_serv$ExercisedOptions/def_serv$UnmodifiedBaseandExercisedOptionsValue+1
def_serv$lp_OptGrowth<-log(def_serv$p_OptGrowth)
def_serv$n_OptGrowth<-def_serv$ExercisedOptions+1
def_serv$ln_OptGrowth<-log(def_serv$n_OptGrowth)


def_serv$Opt<-NA
def_serv$Opt[def_serv$AnyUnmodifiedUnexercisedOptions==1& def_serv$ExercisedOptions>0]<-"Option Growth"
def_serv$Opt[(def_serv$AnyUnmodifiedUnexercisedOptions==1)& def_serv$ExercisedOptions==0]<-"No Growth"
def_serv$Opt[def_serv$AnyUnmodifiedUnexercisedOptions==0]<-"Initial Base=Ceiling"
def_serv$Opt<-factor(def_serv$Opt)


def_serv$l_pPBSC<-log(def_serv$pPBSC+1)
def_serv$l_pOffPSC<-log(def_serv$pOffPSC+1)
def_serv$l_pMarket<-log(def_serv$pMarket+1)
def_serv$l_CA<-log(def_serv$office_entity_numberofactions_1year+1)
def_serv$l_CFTE<-log(def_serv$CFTE_Rate_1year)

summary(def_serv$l_CFTE)


freq_continuous_plot(def_serv,"CFTE_Rate_1year",bins=50)
freq_continuous_plot(def_serv,"l_CFTE",bins=50)
freq_continuous_plot(def_serv,"UnmodifiedBaseandExercisedOptionsValue",bins=50)
freq_continuous_plot(def_serv,"l_base",bins=50)
freq_continuous_plot(def_serv %>%filter(AnyUnmodifiedUnexercisedOptions==1),"p_OptGrowth",bins=50)
freq_continuous_plot(def_serv %>%filter(AnyUnmodifiedUnexercisedOptions==1),"lp_OptGrowth",bins=50)



freq_continuous_plot(def_serv,"pPBSC",bins=50)
freq_continuous_plot(def_serv,"l_pPBSC",bins=50) #No real point, stick with PBSC
freq_continuous_plot(def_serv,"pOffPSC",bins=50)
freq_continuous_plot(def_serv,"l_pOffPSC",bins=50)  #No real point here either
freq_continuous_plot(def_serv,"pMarket",bins=50)
freq_continuous_plot(def_serv,"l_pMarket",bins=50)
freq_continuous_plot(def_serv,"office_entity_paircount_7year",bins=50)
freq_continuous_plot(def_serv,"office_entity_numberofactions_1year",bins=50)
freq_continuous_plot(def_serv,"l_CA",bins=50)
summary(def_serv$pMarket)

def_serv$l_pMarket<-log(def_serv$pMarket+1)


# Effplot<-freq_discrete_plot(subset(def_serv,"EffComp"))
# Effplot<-Effplot+labs(x="Effective Competition",y="Contract or Task Order Count")
# ggsave(Effplot,file="Output//EffFreq.png",width=5.5,height=5.5,dpi=600)
save(file="../data/clean/transformed_def_serv.Rdata", def_serv)
```

## Computational Sample Creation
```{r Sample}

 # load(file="data//def_sample.Rdata")

summary(def_serv$b_Term)
summary(def_serv$b_CBre)
summary(def_serv$lp_OptGrowth) #Missing
summary(def_serv$ExercisedOptions)
summary(def_serv$AnyUnmodifiedUnexercisedOptions)
#Study Variables
summary(def_serv$cl_US6_avg_sal_lag1Const)
summary(def_serv$cl_CFTE)
summary(def_serv$c_pPBSC)
summary(def_serv$c_pOffPSC)
summary(def_serv$c_pairHist)
summary(def_serv$cl_pairCA)
#Controls
summary(def_serv$CompOffr)
summary(def_serv$cl_Offr)
summary(def_serv$cl_Ceil)
summary(def_serv$capped_cl_Days)
summary(def_serv$Veh) 
summary(def_serv$PricingUCA)
summary(def_serv$PlaceCountryISO3)
summary(def_serv$NAICS)
summary(def_serv$NAICS3)
summary(def_serv$Office)
summary(def_serv$Agency)
summary(def_serv$StartCY)
summary(def_serv$cl_def3_HHI_lag1)#Missing!
summary(def_serv$cl_def3_ratio_lag1)#Missing!
summary(def_serv$cl_def6_HHI_lag1)#Missing!
summary(def_serv$cl_def6_obl_lag1)#Missing!
summary(def_serv$cl_def6_ratio_lag1)#Missing!
summary(def_serv$cl_US6_avg_sal_lag1)#Missing!
#New Controls
summary(def_serv$cl_OffCA)
summary(def_serv$cl_OffCA)
summary(def_serv$c_pMarket)
summary(def_serv$Crisis)


complete<-
  #Dependent Variables
  !is.na(def_serv$b_Term)& #summary(def_serv$b_Term)
  !is.na(def_serv$b_CBre)&
  !is.na(def_serv$lp_OptGrowth)&
  !is.na(def_serv$ExercisedOptions)&
  !is.na(def_serv$AnyUnmodifiedUnexercisedOptions)&
  #Study Variables
  !is.na(def_serv$cl_US6_avg_sal_lag1Const)&
  !is.na(def_serv$cl_CFTE)&
  !is.na(def_serv$c_pPBSC)&
  !is.na(def_serv$c_pOffPSC)&
  !is.na(def_serv$c_pairHist)&
  !is.na(def_serv$cl_pairCA)&
  #Controls
  !is.na(def_serv$CompOffr)&
  !is.na(def_serv$cl_Offr)&
  !is.na(def_serv$cl_Ceil)&
  !is.na(def_serv$capped_cl_Days)&
  !is.na(def_serv$Veh) &
  !is.na(def_serv$PricingUCA)&
  !is.na(def_serv$PlaceCountryISO3)& #New Variable
  # !is.na(def_serv$b_UCA)& No longer  used
  !is.na(def_serv$NAICS)&
  !is.na(def_serv$NAICS3)&
  !is.na(def_serv$Office)&
  !is.na(def_serv$Agency)&
  !is.na(def_serv$StartCY)&
  !is.na(def_serv$cl_def3_HHI_lag1)&
  !is.na(def_serv$cl_def3_ratio_lag1)&
  !is.na(def_serv$cl_def6_HHI_lag1)&
  !is.na(def_serv$cl_def6_obl_lag1Const)&
  !is.na(def_serv$cl_def6_ratio_lag1)&
  #New Controls
  !is.na(def_serv$cl_OffCA)& #summary(def_serv$cl_OffCA)
  !is.na(def_serv$cl_OffVol)& #summary(def_serv$cl_OffVol)
  !is.na(def_serv$c_pMarket)&  #summary(def_serv$c_pMarket)
  !is.na(def_serv$Crisis)  #summary(def_serv$c_pMarket)




summary(complete)
summary(def_serv$Action_Obligation.OMB20_GDP18)
money<-def_serv$Action_Obligation.OMB20_GDP18
any(def_serv$Action_Obligation.OMB20_GDP18<0)
money[def_serv$Action_Obligation.OMB20_GDP18<0]<-0
sum(def_serv$Action_Obligation.OMB20_GDP18[def_serv$Action_Obligation.OMB20_GDP18<0])

#Overall
length(money[!complete])/length(money)
sum(money[!complete],na.rm=TRUE)/sum(money,na.rm=TRUE)

#What portion of contracts have potential options, 
sum(money[def_serv$AnyUnmodifiedUnexercisedOptions==1],na.rm=TRUE)/
  sum(money,na.rm=TRUE)


#Missing data, how many records
nrow(def_serv[!complete,])/nrow(def_serv)
sum(def_serv[!complete,]$Action.Obligation.OMB20_GDP18,na.rm=TRUE)/sum(def_serv$Action.Obligation.OMB20_GDP18,na.rm=TRUE)

#Missing data how much money?
length(money[!complete&def_serv$AnyUnmodifiedUnexercisedOptions==1])/
  length(money[def_serv$AnyUnmodifiedUnexercisedOptions==1])
sum(money[!complete&def_serv$AnyUnmodifiedUnexercisedOptions==1],na.rm=TRUE)/
  sum(money[def_serv$AnyUnmodifiedUnexercisedOptions==1],na.rm=TRUE)



#Refreshing
load(file="../data/clean/def_sample.Rdata")

# serv_complete<-def_serv[complete,]
# serv_smp1m<-serv_complete[sample(nrow(serv_complete),1000000),]
# serv_smp<-serv_complete[sample(nrow(serv_complete),250000),]
# rm(serv_complete)
# serv_opt<-def_serv[complete&def_serv$AnyUnmodifiedUnexercisedOptions==1,]


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



# 
# serv_smp<-def_serv[complete,]
# # 
save(file="../data/clean/def_sample.Rdata",serv_smp,serv_smp1m,serv_opt)
# write.foreign(df=serv_smp,
#               datafile="Data//def_sample250k.dat",
#               codefile="Data//def_sample250k_code.do",
#               package = "Stata")
# write.foreign(df=serv_smp1m,
#               datafile="Data//def_sample1m.dat",
#               codefile="Data//def_sample1m_code.do",
#               package = "Stata")

# levels(serv_smp$Intl)<- list("Just U.S."=c("Just U.S."), 
#                                 "Any Intl."=c("Any International"))
# levels(serv_smp1m$Intl)<- list("Just U.S."=c("Just U.S."), 
#                                 "Any Intl."=c("Any International"))


```
