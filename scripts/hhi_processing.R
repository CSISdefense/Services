<<<<<<< Updated upstream
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

names(contracting_office_naics) <- c("Fiscal_year","principalNAICScode",
                                     "principalnaicscodeText","ContractingOfficeCode",
                                     "numberOfContracts",
                                     "obligatedAmount","numberOfActions")

contracting_office_naics<-contracting_office_naics %>% group_by(Fiscal_year,ContractingOfficeCode)

contracting_office_naics<-contracting_office_naics %>%
  filter(Fiscal_year > 2000) 
  

#Rank and calculated HHI by obligation amount
contracting_office_naics_ob<-contracting_office_naics %>%
  filter(Fiscal_year > 2000) %>%
  dplyr::mutate(
    pos = rank(-obligatedAmount,
               ties.method ="min"),
    pctObl = ifelse(obligatedAmount>0,
                 obligatedAmount / sum(obligatedAmount[obligatedAmount>0]),
                 NA
    ),
    pctK = numberOfContracts / sum(numberOfContracts)
  )

fy_summary_ob<-contracting_office_naics_ob %>%
  dplyr::summarize(
    obligatedAmount = sum(obligatedAmount),
    numberOfContracts=sum(numberOfContracts),
    hh_index_obl=sum((pctObl*100)^2,na.rm=TRUE),
    hh_index_k=sum((pctK*100)^2,na.rm=TRUE)
  )

write.csv(fy_summary_ob,file="data\\clean\\office_naics_hhi.csv")

# Rank and calculated HHI by contract number

contracting_office_naics_nc<-contracting_office_naics %>%
  filter(Fiscal_year > 2000) %>%
  dplyr::mutate(
    pos = rank(-numberOfContracts,
               ties.method ="min"),
    pct = ifelse(numberOfContracts>0,
                 numberOfContracts / sum(numberOfContracts[numberOfContracts>0]),
                 NA
    )
  )

fy_summary_nc<-contracting_office_naics_nc %>%
  dplyr::summarize(
    numberOfContracts = sum(numberOfContracts),
    numberOfContracts=sum(numberOfContracts),
    hh_index=sum((pct*100)^2,na.rm=TRUE)
  )
=======
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

names(contracting_office_naics) <- c("Fiscal_year","principalNAICScode",
                                     "principalnaicscodeText","ContractingOfficeCode",
                                     "numberOfContracts",
                                     "obligatedAmount","numberOfActions")

contracting_office_naics<-contracting_office_naics %>% 
  group_by(Fiscal_year,ContractingOfficeCode) %>%
  filter(Fiscal_year > 2000) 
  

#Rank and calculated HHI by obligation amount
contracting_office_naics_ob<-contracting_office_naics %>%
  dplyr::mutate(
    pos = rank(-obligatedAmount,
               ties.method ="min"),
    pctObl = ifelse(obligatedAmount>0,
                 obligatedAmount / sum(obligatedAmount[obligatedAmount>0]),
                 NA),
    pctK = numberOfContracts / sum(numberOfContracts)
  )

office_naics_hhi<-contracting_office_naics_ob %>%
  dplyr::summarize(
    obligatedAmount = sum(obligatedAmount),
    numberOfContracts=sum(numberOfContracts),
    hh_index_obl=sum((pctObl*100)^2,na.rm=TRUE),
    hh_index_k=sum((pctK*100)^2,na.rm=TRUE)
  )

write.csv(office_naics_hhi,"data//clean//office_naics_hhi.csv")
>>>>>>> Stashed changes
