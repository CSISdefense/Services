#=================================================================================================================#

# Data processing for ContractingOffice-based HHI Data

#=================================================================================================================#

library(tidyverse)
library(csis360)
library(dplyr)
library(readr)

contracting_office_naics = read.table("data//semi_clean//Defense_Office.sp_OfficeHistoryNAICS.txt", header = TRUE, 
                                      na.strings = c("","NA","NULL"),
                                      quote = "\"",
                                      sep = "\t")

contracting_office_naics<-remove_bom(contracting_office_naics)

contracting_office_naics<-contracting_office_naics %>%
  dplyr::filter(Fiscal_year > 2000 & !is.na(ContractingOfficeCode))  %>% 
  group_by(Fiscal_year,ContractingOfficeCode)


#Rank and calculated HHI by obligation amount
contracting_office_naics<-contracting_office_naics %>%
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

annual_office_naics_hhi<-contracting_office_naics %>%
  dplyr::summarize(
    obligatedAmount = sum(obligatedAmount),
    numberOfContracts=sum(numberOfContracts),
    office_naics_hhi_obl=sum((pctObl*100)^2,na.rm=TRUE),
    office_naics_hhi_k=sum((pctK*100)^2,na.rm=TRUE),
    sumcheck_obl=sum(pctObl,na.rm=TRUE),
    sumcheck_k=sum(pctK,na.rm=TRUE)
  )

# Managing odd cases, such as contracts for 0.
annual_office_naics_hhi$sumcheck_obl[annual_office_naics_hhi$office_naics_hhi_obl==0]<-NA
annual_office_naics_hhi$office_naics_hhi_obl[annual_office_naics_hhi$office_naics_hhi_obl==0]<-NA

if(any(!is.na(annual_office_naics_hhi$sumcheck_obl) &
       annual_office_naics_hhi$sumcheck_obl - 1 > 1e-9 )) stop("Obligated Sumcheck failed")
if(any(!is.na(annual_office_naics_hhi$sumcheck_k) &
       annual_office_naics_hhi$sumcheck_k - 1 > 1e-9 )) stop("Count Sumcheck failed")

annual_office_naics_hhi<-annual_office_naics_hhi %>% dplyr::select(c(-sumcheck_obl,-sumcheck_k))

#Creating an average to fill in when there isn't a prior year value to rely on.
average_office_naics_hhi<-annual_office_naics_hhi %>% 
  group_by(ContractingOfficeCode) %>%
  dplyr::summarize(
    obligatedAmount = sum(obligatedAmount),
    numberOfContracts=sum(numberOfContracts),
    avg_office_naics_hhi_obl=mean(office_naics_hhi_obl,na.rm=TRUE),
    avg_office_naics_hhi_k=mean(office_naics_hhi_k,na.rm=TRUE)
  )



write.csv(annual_office_naics_hhi,"data//clean//annual_office_naics_hhi.csv")
write.csv(average_office_naics_hhi,"data//clean//average_office_naics_hhi.csv")