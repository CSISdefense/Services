################################################################################
# Data Pre-Processing for Vendor Size Shiny Graphic
# UPDATED 2021/03/07
#
# This script does pre-processing to get a SQL query into usable form for shiny
# graphics
#
# Input:
#   CSV-format results from SQL query:
#     Vendor_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer
#
# Output: CSV file (unaggregated_FPDS.Rda)
# with data in the minimal form needed by Shiny script
################################################################################

# install.packages("../csis360_0.0.0.9022.tar.gz")

library(tidyverse)
library(magrittr)
library(csis360)
library(readr)



source("scripts\\NAICS.r")
# read in data
# setwd("K:/Users/Greg/Repositories/Vendor")
disa_gsa<-read_delim(file.path("data","semi_clean","DISA_GSA_contract.txt"),delim="\t",na=c("NULL","NA"),
                     col_names = TRUE, guess_max = 700000)

disa_sum<-read_delim(file.path("data","semi_clean","DISA_summary_veh.txt"),delim="\t",na=c("NULL","NA"),
                     col_names = TRUE, guess_max = 700000)


summary(factor(disa_gsa$CSISidvpiidid[disa_gsa$idvpiid==""]))

disa_gsa$idvpiid[is.na(disa_gsa$idvpiid)]<-""
disa_gsa$idv_or_piid[disa_gsa$idvpiid!=""]<-paste("IDV",disa_gsa$idvpiid[disa_gsa$idvpiid!=""],"_")
disa_gsa$idv_or_piid[disa_gsa$idvpiid==""]<-paste("AWD",disa_gsa$piid[disa_gsa$idvpiid==""],"_")

idv_spend<-disa_gsa %>% group_by(idv_or_piid,VehicleClassification) %>%
  summarise(obligatedAmount=sum(obligatedAmount))

idv_spend[order(desc(idv_spend$obligatedAmount)),]




disa_sum<-read_delim(file.path("data","semi_clean","DISA_summary2.txt"),delim="\t",na=c("NULL","NA"),
                    col_names = TRUE, guess_max = 700000)



disa_sum<-apply_standard_lookups(disa_sum)
# disa_sum <- deflate(disa_sum,money_var="obligatedAmount",fy_var="Fiscal_Year",deflator_var="OMB20_GDP20")
# disa_sum$NAICS_ShortHand

disa_sum<-csis360::read_and_join(disa_sum,
                           "LOOKUP_Buckets.csv",
                           # by="ProductOrServiceArea",
                           by="ProductServiceOrRnDarea",
                           replace_na_var="ProductServiceOrRnDarea",
                           add_var=c("ServicesCategory.detail"),
                           path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
                           dir="Lookups/"
)

disa_sum %>% group_by(informationtechnologycommercialitemcategory) %>% filter(Fiscal_Year>="2000") %>%
  # group_by(ProductOrServiceCode,ProductOrServiceCodeText,principalnaicscode,NAICS_ShortHand,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20))
# levels(factor(disa_sum$informationtechnologycommercialitemcategory))


ds_lc<-prepare_labels_and_colors(disa_sum)
ds_ck<-get_column_key(disa_sum)

save(disa_sum,file=file.path("data","semi_clean","disa.Rda"))




summary(factor(disa_gsa$contractingofficeagencyid))
disa<-disa_gsa %>% filter(contractingofficeagencyid=='97AK')
disa$idvpiid[is.na(disa$idvpiid)]<-""
disa$idv_or_piid[disa$idvpiid!=""]<-paste("IDV",disa$idvpiid[disa$idvpiid!=""],"_")
disa$idv_or_piid[disa$idvpiid==""]<-paste("AWD",disa$piid[disa$idvpiid==""],"_")
summary(factor(disa$ContractingOfficeName))
summary(factor(disa$ContractingOfficeID))
View(disa %>%filter(is.na(ContractingOfficeName)))




(v<-build_plot(disa %>% filter(Fiscal_Year>=2005),
           chart_geom = "Bar Chart",
           share=FALSE,
           x_var="Fiscal_Year",
           y_var="obligatedAmount",
           color_var = "VehicleClassification",
           facet_var = "ContractingOfficeID",
           format=TRUE
           )
)

disa <- deflate(disa,money_var="obligatedAmount",fy_var="Fiscal_Year",deflator_var="OMB20_GDP20")


disa_sum$informationtechnologycommercialitemcategory<-factor(disa_sum$informationtechnologycommercialitemcategory)
levels(disa_sum$informationtechnologycommercialitemcategory)<-list("Unlabeled"="",
                                                                   "A: COMMERCIALLY AVAILABLE" =c("A","A: COMMERCIALLY AVAILABLE"),
                                                                   "B: OTHER COMMERCIAL ITEM"=c(  "B"                ,              "B: OTHER COMMERCIAL ITEM"  ),
                                                                   "C: NON-DEVELOPMENTAL ITEM"=c("C","C: NON-DEVELOPMENTAL ITEM"),
                                                                   "D: NON-COMMERCIAL ITEM"=c("D",                              "D: NON-COMMERCIAL ITEM" ),
                                                                   "E: COMMERCIAL SERVICE" =c("E","E: COMMERCIAL SERVICE"),
                                                                   "F: NON-COMMERCIAL SERVICE" =c("F"            ,                  "F: NON-COMMERCIAL SERVICE"),
                                                                   "Z: NOT IT PRODUCTS OR SERVICES"=c("Z","Z: NOT IT PRODUCTS OR SERVICES"))

View(disa %>% group_by(Fiscal_Year) %>% summarise(Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20)))
View(disa_sum %>% group_by(Fiscal_Year) %>% summarise(Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20)))

idv_spend_test<-disa %>% filter(Fiscal_Year>=2005) %>% group_by(idv_or_piid,VehicleClassification,ContractingOfficeID,ContractingOfficeName,fundingrequestingagencyid,
                                                                ) %>%
  summarise(Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20))


idv_spend<-disa %>% filter(Fiscal_Year>=2005) %>% group_by(idv_or_piid,VehicleClassification,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20),
            min_fyear=min(Fiscal_Year),
            max_fyear=max(Fiscal_Year))

idv_spend <-  idv_spend %>% group_by(ContractingOfficeID) %>%
  mutate(crank=order(order(Action_Obligation_OMB20_GDP20,decreasing = TRUE)),
         cshare=Action_Obligation_OMB20_GDP20/sum(Action_Obligation_OMB20_GDP20))

View(idv_spend %>% filter(crank<=5))

idv_spend %>% filter(crank<=5) %>% group_by(ContractingOfficeID) %>%
  dplyr::summarise(cshare=sum(cshare),
           Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20))

idv_spend %>% filter(crank<=10) %>% group_by(ContractingOfficeID) %>%
  dplyr::summarise(cshare=sum(cshare),
                   Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20))

idv_spend<-idv_spend[order(idv_spend$ContractingOfficeID,desc(idv_spend$Action_Obligation_OMB20_GDP20)),]
View(idv_spend %>% filter(crank<=5))
write.csv(idv_spend %>% filter(crank<=5), file="DISA_top_office_contract.csv",row.names = FALSE)

disa_psc_naics<-disa_sum %>% filter(fiscal_year>=2005) %>% group_by(ProductOrServiceCode,ProductOrServiceCodeText,principalnaicscode,NAICS_ShortHand,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))
disa_psc_naics <-  disa_psc_naics %>% group_by(ContractingOfficeID) %>%
  mutate(crank=order(order(obligatedAmount_OMB19_19,decreasing = TRUE)),
         cshare=obligatedAmount_OMB19_19/sum(obligatedAmount_OMB19_19))

idv_spend_2020<-disa %>% filter(Fiscal_Year>=2010) %>% group_by(idv_or_piid,VehicleClassification,ContractingOfficeID) %>%
  summarise(Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20)) %>%  group_by(ContractingOfficeID) %>%
  mutate(crank=order(order(Action_Obligation_OMB20_GDP20,decreasing = TRUE)),
         cshare=Action_Obligation_OMB20_GDP20/sum(Action_Obligation_OMB20_GDP20)) %>% filter(crank<=5) %>% group_by(ContractingOfficeID) %>%
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="511210"]<-"Software Publishers"
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="541512"]<-"Computer Systems Design Services "
  dplyr::summarise(cshare=sum(cshare),
                   Action_Obligation_OMB20_GDP20=sum(Action_Obligation_OMB20_GDP20))





