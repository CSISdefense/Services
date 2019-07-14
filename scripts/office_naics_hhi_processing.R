#=================================================================================================================#

# Data processing for ContractingOffice-based HHI Data

#=================================================================================================================#

library(tidyverse)
library(csis360)
library(dplyr)
library(readr)

contracting_office_naics = read.table("data//semi_clean//Office.OfficeIDhistoryNAICS_fy.txt", header = TRUE, 
                                      na.strings = c("","NA","NULL"),
                                      quote = "\"",
                                      sep = "\t")

contracting_office_naics<-remove_bom(contracting_office_naics)

contracting_office_naics<-contracting_office_naics %>% group_by(Fiscal_year,ContractingOfficeCode)
contracting_office_naics<-contracting_office_naics %>%
  filter(Fiscal_year > 2000) 


#Rank and calculated HHI by obligation amount
contracting_office_naics_ob<-contracting_office_naics %>%
  dplyr::mutate(
    posObl = rank(-obligatedAmount,
               ties.method ="min"),
    posK = rank(-numberOfContracts,
                  ties.method ="min"),
    pctObl = ifelse(obligatedAmount>0,
                 obligatedAmount / sum(obligatedAmount[obligatedAmount>0]),
                 NA
    ),
    pctK = numberOfContracts / sum(numberOfContracts)
  )

office_naics_hhi<-contracting_office_naics %>%
  dplyr::summarize(
    obligatedAmount = sum(obligatedAmount),
    numberOfContracts=sum(numberOfContracts),
    hh_index_obl=sum((pctObl*100)^2,na.rm=TRUE),
    hh_index_k=sum((pctK*100)^2,na.rm=TRUE),
    sumcheck_obl=sum(hh_index_obl,na.rm=TRUE),
    sumcheck_obl=sum(hh_index_obl,na.rm=TRUE)
  )

write.csv(office_naics_hhi,"data//clean//office_naics_hhi.csv")