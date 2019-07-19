# Libraries Used
library(readxl) 
library(stringr)
library(dplyr)
library(plyr)
library(lubridate)
library(tidyverse)
library(csis360)

####################################################################################################################
# User Defined Functions
####################################################################################################################
# (UDF) read all the csv/excel files from the path if matching the pattern
read_allfiles_noskip <- function(file_path, tibble = FALSE) {
  # straight data.frames
  # for tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  filenames <- list.files(file_path, pattern = "*FY*")
  data_list <- lapply(filenames, function(Y) if (stringr::str_detect(Y, 'csv')) {
    x <- read.csv(Y)
    x
  } else {
    sheets <- readxl::excel_sheets(Y)
    x <- lapply(sheets, function(X) readxl::read_excel(Y, sheet = X))
    if(!tibble) x <- lapply(x, as.data.frame)
    names(x) <- sheets
    x
  })
  names(data_list) <- unlist(lapply(filenames, function (X) stringr::str_split(X, pattern = "[.]")))[c(TRUE,FALSE)]
  data_list
}

# (UDF) Read all csv files from the path if matching the pattern
read_allcsv <- function(file_path, tibble = FALSE) {
  # straight data.frames
  # not tidyverse tibble, TRUE for reading as tibble
  filenames <- list.files(file_path, pattern = "gsa[[:graph:]]+\\.csv")
  data_list <- lapply(filenames, function(X) read.csv(X))
  names(data_list) <- unlist(lapply(filenames, function (X) stringr::str_split(X, pattern = "[.]")))[c(TRUE,FALSE)]
  data_list
}

# (UDF) Add "Fiscal Year" for input dataframe
add_fy <- function(input_df, fy){
  input_df <-  input_df %>%
    mutate(`Fiscal Year` = fy)
  input_df
}

# (UDF) Standardize Looping, combined approach with standardize_variable_names function 
standardize_process <- function(input_df) {
  input_df <- standardize_variable_names(input_df)
  while (any(str_detect(names(input_df),"\\."))) {
    input_df <- standardize_variable_names(input_df)
    names(input_df) <- lapply(names(input_df), function(x) gsub("\\.", "_",x))
  }
  input_df
}

####################################################################################################################
# Data Cleaning and Integration
####################################################################################################################
# Some changes are made to the original xlsx files 
# Renaming files: adding FY[[:digit:]]{2} at the beginning of each filename
# Removing special text headers: FY12 (First note row in each sheet), 
# Removing special text sheet: FY13 ("Notes" Sheet), FY14 ("Notes" Sheet), FY15 ("Notes" Sheet)
# Pivot table to data table: FY16
# Select the full data table: FY17("ICS Invoice Factor Export")
all_data_gsa <- read_allfiles_noskip("/Users/xinyuan/Desktop/CSIS/GSA-SCI")

# 2016-2017 GSA SCI data export
all_data_gsa[[1]] <- add_fy(all_data_gsa[[1]],2016)
all_data_gsa[[2]] <- add_fy(all_data_gsa[[2]],2017)
# Check common columns if needed
#header_2016 <- names(all_data_gsa[[1]])
#header_2017 <- names(all_data_gsa[[2]])
#intersect(header_2016, header_2017)
gsa_16_17<-rbind.fill(all_data_gsa[[1]],all_data_gsa[[2]])
write.csv(gsa_16_17,"gsa_16_17.csv",row.names = FALSE, na = "")

# 2014 GSA SCI data export
main_14 <- all_data_gsa[[3]][[1]]
sup_14 <- all_data_gsa[[3]][[2]]
main_14 <- main_14 %>%
  dplyr::rename(`PSC Code` = `Product or Service Code`,
         `PSC Description` = `Product or Service Description` ,
         `Place of Performance City` = `Principal Place of Performance City Name`,
         `Place of Performance State` = `Principal Place of Performance State Code`,
         `Place of Performance County` = `Principal Place of Performance Country Code`,
         `Fair Opportunity Limited Sources` = `Fair Opportunity/Limited Sources`,
         `Referenced IDV PIID` = `Referenced  IDV PIID`,
         `Vendor DUNS` =`DUNS Number`) 
# Check common columns if needed
#header_2014_1 <- names(main_14)
#header_2014_2 <- names(sup_14)
#intersect(header_2014_1, header_2014_2) 
main_14$`Date Signed` <- as.character(as.Date(as.character(main_14$`Date Signed`),'%Y%m%d'))
sup_14$`Date Signed` <- as.character(as.Date(sup_14$`Date Signed`,'%m-%d-%Y'))

# Join main sheet and supplement sheet by PIID with following steps:
# 1. Get all rows from main after join
# 2. Get all rows from sub after join
# 3. Bind all subsets above into one full dataset
main_sub_1 <- main_14 %>%
  full_join(sup_14, by = c("PIID")) %>%
  filter(is.na(`PSC Code.x`) == FALSE) %>%
  select(-contains('.y'))
names(main_sub_1) <- str_replace(names(main_sub_1),'\\.x', "")
main_sub_2 <- main_14 %>% 
  full_join(sup_14, by = c("PIID")) %>%
  filter(is.na(`PSC Code.x`) == TRUE) %>%
  select(-contains('.x')) 
names(main_sub_2) <- str_replace(names(main_sub_2),'\\.y', "")  
gsa_14 <- rbind(main_sub_1, main_sub_2)
gsa_14 <- add_fy(gsa_14,2014)
write.csv(gsa_14,"gsa_14.csv",row.names = FALSE,na = "")

#2015 GSA SCI data export
main_15 <- all_data_gsa[[4]][[1]]
sup_15 <- all_data_gsa[[4]][[2]]
main_15 <- main_15 %>%
  dplyr::rename(`PSC Code` = `Product or Service Code`,
                `PSC Description` = `Product or Service Description` ,
                `Place of Performance City` = `Principal Place of Performance City Name`,
                `Place of Performance State` = `Principal Place of Performance State Code`,
                `Place of Performance County` = `Principal Place of Performance Country Name`,
                `Fair Opportunity Limited Sources` = `Fair Opportunity/Limited Sources`,
                `Referenced IDV PIID` = `Referenced  IDV PIID`,
                `Vendor DUNS` =`DUNS Number`) 
# Check common columns if needed
#header_2015_1 <- names(main_15)
#header_2015_2 <- names(sup_15)
#intersect(header_2015_1,header_2015_2)
main_15$`Date Signed` <- as.character(as.Date(as.character(main_15$`Date Signed`),'%Y%m%d'))
sup_15$`Date Signed` <- as.character(as.Date(sup_15$`Date Signed`,'%m-%d-%Y'))

main_sub_1 <- main_15 %>%
  full_join(sup_15, by = c("PIID")) %>%
  filter(is.na(`PSC Code.x`) == FALSE) %>%
  select(-contains('.y'))
names(main_sub_1) <- str_replace(names(main_sub_1),'\\.x', "")
main_sub_2 <- main_15 %>% 
  full_join(sup_15, by = c("PIID")) %>%
  filter(is.na(`PSC Code.x`) == TRUE) %>%
  select(-contains('.x')) 
names(main_sub_2) <- str_replace(names(main_sub_2),'\\.y', "")  
gsa_15 <- rbind(main_sub_1, main_sub_2)
gsa_15 <- add_fy(gsa_15,2015)
write.csv(gsa_15,"gsa_15.csv",row.names = FALSE, na = "")

# Integrate all GSA SCI data from FY14-FY17
all_data_new <- read_allcsv("/Users/xinyuan/Desktop/CSIS/GSA-SCI")
gsa_14 <- all_data_new[[1]]
gsa_15 <- all_data_new[[2]]
gsa_16_17 <- all_data_new[[3]]
gsa_14_15 <- rbind.fill(gsa_14,gsa_15)
gsa_sci_all <- rbind.fill(gsa_14_15, gsa_16_17)
write.csv(gsa_sci_all,"gsa_14_17.csv",row.names = FALSE, na = "")

####################################################################################################################
# Split into Prime Contract & SubContract
####################################################################################################################
# Split all GSA SCI data into contract (135cols) & subcontractor (420cols)
all_gsa <- read.csv("gsa_14_17.csv")
names(all_gsa) <- str_trim(gsub("\\."," ", names(all_gsa)))
all_gsa$Index <- seq.int(nrow(all_gsa))
split_index <- which(str_detect(names(all_gsa), '^Subcontractor\\s') %in% "TRUE")
split_list <- names(all_gsa)[split_index] #420 columns, 84 Subcontractors

# Remove duplicated rows if there are some
#dup_rows = which(duplicated(all_gsa) == TRUE) #might cause memory error
nondup_gsa = all_gsa[-c(7126),]

# Create Unique Identifier Column - "CSIStieBreaker"
# Underlying logic:
# 1. Group by key identifier columns: `PIID`, `Fiscal Year`, `Contracting_Agency_ID`, `Vendor_DUNS`, `Referred_IDV_PIID`
# 2. Create CSIStieBreaker (integer, 0: Non-duplicated Rows (#0: 134222); -1~: Duplicated Rows)
nondup_gsa <-  nondup_gsa %>%
  group_by(`PIID`,`Fiscal Year`,`Contracting Agency ID`,`Vendor DUNS`,`Referenced IDV PIID`) %>%
  dplyr::mutate(CSIStieBreaker = -1*(row_number()-1))

all_gsa_subcontractor <- subset(nondup_gsa, select = c(split_list,'CSIStieBreaker','Index')) #35 +Index
all_gsa_contract <- nondup_gsa[,!names(nondup_gsa) %in% c(split_list,'Index'), drop = FALSE] #420 + Index

#wide to long - 137939*84subcontractors - 11586876 rows
all_gsa_subcontractor_long <- all_gsa_subcontractor %>%
  gather("Subcontractor_Cols","Value",-Index) %>%
  mutate(Subcontractor = str_extract(Subcontractor_Cols, '^Subcontractor\\s\\d+')) %>%
  mutate(Subcontractor_Cols = str_replace(Subcontractor_Cols,'^Subcontractor\\s\\d+\\s*',"")) %>%
  spread(Subcontractor_Cols,Value) %>%
  select(-c('Index'))
write.csv(all_gsa_subcontractor_long,"gsa_14_17_subcontract_nodup.csv",row.names = FALSE,na = "")
write.csv(all_gsa_contract,"gsa_14_17_primecontract_nodup.csv", row.names = FALSE, na = "")

####################################################################################################################
# Stage1 - Standardizing Column Names 
####################################################################################################################
# Standardize variable names according to Lookup-Tables/style/Lookup_StandardizeVariableNames.csv 
primecon <- read.csv("gsa_14_17_primecontract_nodup.csv", check.names=FALSE, stringsAsFactors = FALSE)
subcon <- read.csv("gsa_14_17_subcontract_nodup.csv",check.names=FALSE, stringsAsFactors = FALSE)
names(primecon) <- names(standardize_process(primecon))
names(subcon) <- names(standardize_process(subcon))
#write.csv(primecon,"gsa_14_17_primecontract_nodup.csv", row.names = FALSE, na = "")
#write.csv(subcon,"gsa_14_17_subcontract_nodup.csv",row.names = FALSE,na = "")

####################################################################################################################
# Second-round Data Cleaning for Identified Specific Data Issues (Stage1 ~ Stage2)
####################################################################################################################
# Data issue 1: Special puncts ("$", "-", "," and whitespace) in currency-type columns 
# ('Total_Action_Obligation','Total_Base_and_All_Options_Value')
# Check and flag currency-type columns mis-read as character class by R
# Remove special puncts
punct_remover <- function (colname_list, input_df) {
  for (i in colname_list){
    input_df <- input_df %>%
      mutate(i)
    check_data <- str_trim(input_df[[i]])
    if (any(lapply(unique(check_data), function (x) str_detect(x, '\\,')))) {
      check_data <- lapply(check_data, function(x) gsub("\\,","",x))
    } else if (any(lapply(unique(check_data), function (x) str_detect, '\\$'))) {
      check_data <- lapply(check_data, function(x) gsub("\\4","",x))
    } else if (any(lapply(unique(check_data), function (x) str_detect, '\\-'))) {
      check_data <- lapply(check_data, function(x) gsub("\\-","",x))
    }
  }
  input_df
}

check_cols <- c(`Total_Action_Obligation`,`Total_Base_and_All_Options_Value`)
test <- punct_remover(check_cols, primecon)

# Data issue 1: Excel Automatic Mis-scientific-formatting
# Check and flag Excel Data Error "12E3 (1.2+E04)" in 4-digit ID-related columns: 
# (e.g. `Contracting_Agency_ID`,`DepartmentID`,`Funding_Agency_ID`,`Funding_Department_ID`) 
# Check and change values of numeric columns from scienfic-formatted numbers to plain numbers
# (e.g. 'Action_Obligation','Total_Contract_Value','Base_and_All_Options_Value','Total_Dollar_Amount_Invoiced',
#       'Number_of_Contractor_Hours_Invoiced','Number_of_Contractor_Full_Time_Equivalent_Employees_FTEs',
#       'Prime_Contractor_Hours_Invoiced', 'Prime_Contractor_Full_Time_Equivalent_Employees_FTEs')
errorsf_fixer <- function (colname_list, input_df) {
  for (i in colname) {
    check_data <- input_df[[i]]
    if (class(check_data) == 'character') {
      
    } else if (class(check_data) == ) {
      
    } else () {
      
    }
  }
}










