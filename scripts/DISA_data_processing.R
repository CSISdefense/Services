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
library(Hmisc)
library(readr)



source("scripts\\NAICS.r")
# read in data

disa_gsa<-read_delim(file.path("data","semi_clean","DISA_GSA_contract.txt"),delim="\t",na=c("NULL","NA"),
                     col_names = TRUE, guess_max = 700000)

disa_sum<-read_delim(file.path("data","semi_clean","DISA_summary.txt"),delim="\t",na=c("NULL","NA"),
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



summary(factor(disa_gsa$contractingofficeagencyid))
disa<-disa_gsa %>% filter(contractingofficeagencyid=='97AK')
disa$idvpiid[is.na(disa$idvpiid)]<-""
disa$idv_or_piid[disa$idvpiid!=""]<-paste("IDV",disa$idvpiid[disa$idvpiid!=""],"_")
disa$idv_or_piid[disa$idvpiid==""]<-paste("AWD",disa$piid[disa$idvpiid==""],"_")
summary(factor(disa$ContractingOfficeName))
summary(factor(disa$ContractingOfficeID))
View(disa %>%filter(is.na(ContractingOfficeName)))




(v<-build_plot(disa %>% filter(fiscal_year>=2005),
           chart_geom = "Bar Chart",
           share=FALSE,
           x_var="fiscal_year",
           y_var="obligatedAmount",
           color_var = "VehicleClassification",
           facet_var = "ContractingOfficeID",
           format=TRUE
           )
)

disa <- deflate(disa,money_var="obligatedAmount",fy_var="fiscal_year",deflator_var="OMB20_GDP20")
disa_sum <- deflate(disa_sum,money_var="obligatedAmount",fy_var="fiscal_year",deflator_var="OMB20_GDP20")
disa_sum$NAICS_ShortHand

disa_sum %>% group_by(informationtechnologycommercialitemcategory) %>% filter(fiscal_year>="2000") %>%
  # group_by(ProductOrServiceCode,ProductOrServiceCodeText,principalnaicscode,NAICS_ShortHand,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB20_GDP20))
levels(factor(disa_sum$informationtechnologycommercialitemcategory))
disa_sum$informationtechnologycommercialitemcategory<-factor(disa_sum$informationtechnologycommercialitemcategory)
levels(disa_sum$informationtechnologycommercialitemcategory)<-list("Unlabeled"="",
                                                                   "A: COMMERCIALLY AVAILABLE" =c("A","A: COMMERCIALLY AVAILABLE"),
                                                                   "B: OTHER COMMERCIAL ITEM"=c(  "B"                ,              "B: OTHER COMMERCIAL ITEM"  ),
                                                                   "C: NON-DEVELOPMENTAL ITEM"=c("C","C: NON-DEVELOPMENTAL ITEM"),
                                                                   "D: NON-COMMERCIAL ITEM"=c("D",                              "D: NON-COMMERCIAL ITEM" ),
                                                                   "E: COMMERCIAL SERVICE" =c("E","E: COMMERCIAL SERVICE"),
                                                                   "F: NON-COMMERCIAL SERVICE" =c("F"            ,                  "F: NON-COMMERCIAL SERVICE"),
                                                                   "Z: NOT IT PRODUCTS OR SERVICES"=c("Z","Z: NOT IT PRODUCTS OR SERVICES"))

disa_sum$informationtechnologycommercialitemcategory<-factor(disa_sum$informationtechnologycommercialitemcategory)
levels(disa_sum$informationtechnologycommercialitemcategory)<-list("Unlabeled"="",
                                                                   "A: COMMERCIALLY AVAILABLE" =c("A","A: COMMERCIALLY AVAILABLE"),
                                                                   "B: OTHER COMMERCIAL ITEM"=c(  "B"                ,              "B: OTHER COMMERCIAL ITEM"  ),
                                                                   "C: NON-DEVELOPMENTAL ITEM"=c("C","C: NON-DEVELOPMENTAL ITEM"),
                                                                   "D: NON-COMMERCIAL ITEM"=c("D",                              "D: NON-COMMERCIAL ITEM" ),
                                                                   "E: COMMERCIAL SERVICE" =c("E","E: COMMERCIAL SERVICE"),
                                                                   "F: NON-COMMERCIAL SERVICE" =c("F"            ,                  "F: NON-COMMERCIAL SERVICE"),
                                                                   "Z: NOT IT PRODUCTS OR SERVICES"=c("Z","Z: NOT IT PRODUCTS OR SERVICES"))

disa_sum<-csis360::read_and_join(disa_sum,
                                  "LOOKUP_Buckets.csv",
                                  # by="ProductOrServiceArea",
                                  by="ProductServiceOrRnDarea",
                                  replace_na_var="ProductServiceOrRnDarea",
                                  add_var="ProductServiceOrRnDarea.sum",
                                  path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
                                  dir="Lookups/"
)

#Vehicle
disa_sum<-csis360::read_and_join_experiment(disa_sum,
                                            "Vehicle.csv",
                                            by=c("VehicleClassification"="Vehicle.detail"),
                                            add_var=c("Vehicle.sum","Vehicle.sum7","Vehicle.AwardTask"),
                                            path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                                            # path="K:/Users/Greg/Repositories/Lookup-Tables/",
                                            dir="contract/"
)

disa_sum<-read_and_join_experiment(data=disa_sum
                                   ,"InformationTechnologyCommercialItemCategory.csv"
                                   ,path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/"
                                   ,dir="productorservice/"
                                   ,by=c("informationtechnologycommercialitemcategory"="informationtechnologycommercialitemcategory")
                                   # ,new_var_checked=FALSE
                                   # ,create_lookup_rdata=TRUE
                                   # ,col_types="dddddddddccc"
) 

disa_sum$dFYear<-as.Date(paste("1/1/",as.character(disa_sum$fiscal_year),sep=""),"%m/%d/%Y")

ds_lc<-prepare_labels_and_colors(disa_sum)
ds_ck<-get_column_key(disa_sum)

save(disa_sum,file=file.path("data","semi_clean","disa.Rda"))


View(disa %>% group_by(fiscal_year) %>% summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19)))
View(disa_sum %>% group_by(fiscal_year) %>% summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19)))
disa$naics
disa$fundingrequestingagencyid
idv_spend_test<-disa %>% filter(fiscal_year>=2005) %>% group_by(idv_or_piid,VehicleClassification,ContractingOfficeID,ContractingOfficeName,fundingrequestingagencyid,
                                                                ) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))


idv_spend<-disa %>% filter(fiscal_year>=2005) %>% group_by(idv_or_piid,VehicleClassification,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19),
            min_fyear=min(fiscal_year),
            max_fyear=max(fiscal_year))

idv_spend <-  idv_spend %>% group_by(ContractingOfficeID) %>%
  mutate(crank=order(order(obligatedAmount_OMB19_19,decreasing = TRUE)),
         cshare=obligatedAmount_OMB19_19/sum(obligatedAmount_OMB19_19))

View(idv_spend %>% filter(crank<=5))

idv_spend %>% filter(crank<=5) %>% group_by(ContractingOfficeID) %>%
  dplyr::summarise(cshare=sum(cshare),
           obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))

idv_spend %>% filter(crank<=10) %>% group_by(ContractingOfficeID) %>%
  dplyr::summarise(cshare=sum(cshare),
                   obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))

idv_spend<-idv_spend[order(idv_spend$ContractingOfficeID,desc(idv_spend$obligatedAmount_OMB19_19)),]
View(idv_spend %>% filter(crank<=5))
write.csv(idv_spend %>% filter(crank<=5), file="DISA_top_office_contract.csv",row.names = FALSE)

disa_psc_naics<-disa_sum %>% filter(fiscal_year>=2005) %>% group_by(ProductOrServiceCode,ProductOrServiceCodeText,principalnaicscode,NAICS_ShortHand,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))
disa_psc_naics <-  disa_psc_naics %>% group_by(ContractingOfficeID) %>%
  mutate(crank=order(order(obligatedAmount_OMB19_19,decreasing = TRUE)),
         cshare=obligatedAmount_OMB19_19/sum(obligatedAmount_OMB19_19))

disa_psc_naics<-disa_psc_naics[order(disa_psc_naics$ContractingOfficeID,desc(disa_psc_naics$obligatedAmount_OMB19_19)),]
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="541519"]<-"Other Computer Related Services"
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="517410"]<-"Satellite Telecommunications"
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="517110"]<-"Wired Telecommunications Carriers"
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="511210"]<-"Software Publishers"
disa_psc_naics$NAICS_ShortHand[disa_psc_naics$NAICS_ShortHand=="" & disa_psc_naics$principalnaicscode=="541512"]<-"Computer Systems Design Services "


summary(factor(disa_sum$informationtechnologycommercialitemcategory))
disa_sum %>% group_by(informationtechnologycommercialitemcategory) %>% filter(fiscal_year>="2000") %>%
  # group_by(ProductOrServiceCode,ProductOrServiceCodeText,principalnaicscode,NAICS_ShortHand,ContractingOfficeID,ContractingOfficeName) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))
levels(factor(disa_sum$informationtechnologycommercialitemcategory))

(c<-build_plot(disa_sum %>% filter(fiscal_year>=2005),
               chart_geom = "Bar Chart",
               share=FALSE,
               x_var="fiscal_year",
               y_var="obligatedAmount_OMB19_19",
               color_var = "informationtechnologycommercialitemcategory",
               facet_var = "ContractingOfficeID",
               format=TRUE
)
)
(coverall<-build_plot(disa_sum %>% filter(fiscal_year>=2002),
               chart_geom = "Bar Chart",
               share=FALSE,
               x_var="fiscal_year",
               y_var="obligatedAmount_OMB19_19",
               color_var = "informationtechnologycommercialitemcategory",
               # facet_var = "ContractingOfficeID",
               format=TRUE
)+theme(legend.position = "right")
)
ggsave(coverall,file="output//disa_commercial.png")

disa_sum<-read_and_join_experiment(data=disa_sum
                         ,"Vehicle.csv"
                         ,path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/"
                         ,dir="contract/"
                         ,by=c("VehicleClassification"="Vehicle.detail")
                         # ,new_var_checked=FALSE
                         # ,create_lookup_rdata=TRUE
                         # ,col_types="dddddddddccc"
) 


disa_sum<-read_and_join_experiment(data=disa_sum
                                   ,"InformationTechnologyCommercialItemCategory.csv"
                                   ,path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/"
                                   ,dir="productorservice/"
                                   ,by=c("informationtechnologycommercialitemcategory"="informationtechnologycommercialitemcategory")
                                   # ,new_var_checked=FALSE
                                   # ,create_lookup_rdata=TRUE
                                   # ,col_types="dddddddddccc"
) 

(voverall<-build_plot(disa_sum %>% filter(fiscal_year>=2000),
                      chart_geom = "Bar Chart",
                      share=FALSE,
                      x_var="fiscal_year",
                      y_var="obligatedAmount_OMB19_19",
                      color_var = "Vehicle.sum7",
                      # facet_var = "ContractingOfficeID",
                      format=TRUE
)+theme(legend.position = "right")
)
ggsave(voverall,file="output//disa_vehicle.png")


View(disa_psc_naics %>% filter(crank<=5))
disa_psc_naics %>% filter(crank<=5) %>% group_by(ContractingOfficeID) %>%
  dplyr::summarise(cshare=sum(cshare),
                   obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))

idv_spend_2020<-disa %>% filter(fiscal_year>=2010) %>% group_by(idv_or_piid,VehicleClassification,ContractingOfficeID) %>%
  summarise(obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19)) %>%  group_by(ContractingOfficeID) %>%
  mutate(crank=order(order(obligatedAmount_OMB19_19,decreasing = TRUE)),
         cshare=obligatedAmount_OMB19_19/sum(obligatedAmount_OMB19_19)) %>% filter(crank<=5) %>% group_by(ContractingOfficeID) %>%
  dplyr::summarise(cshare=sum(cshare),
                   obligatedAmount_OMB19_19=sum(obligatedAmount_OMB19_19))





