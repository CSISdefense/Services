# Libraries Used
library(readxl) 
library(stringr)
library(dplyr)
library(plyr)
library(lubridate)
library(tidyverse)
library(csis360)

# Load CFTE Tables 
read_allxlsx <- function (path, tibble = FALSE) {
  # straight data.frames
  # not in tidyverse tibble
  read_xlsxfile <- function (filename, tibble = FALSE) {
    sheets <- readxl::excel_sheets(filename)
    x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
    if(!tibble) x <- lapply(x, as.data.frame)
    names(x) <- sheets
    x
  }
  # bulk reading from path
  filenames <- list.files(path, pattern = "^FY*")
  data_list <- lapply(filenames, function(x) read_xlsxfile(x))
  names(data_list) <- unlist(lapply(filenames, function (X) unlist(strsplit(X, ":"))[1]))
  data_list
}


# Some changes are made to the original xlsx files 
# Renaming files: adding FY[[:digit:]]{2} at the beginning of each filename
# Removing special text headers: FY12 (First note row in each sheet), 
# Removing special text sheet: FY13 ("Notes" Sheet), FY14 ("Notes" Sheet), FY15 ("Notes" Sheet)
# Pivot table to data table: FY16
# Select the full data table: FY17("ICS Invoice Factor Export")
all_cfte <- read_allxlsx("C:/Users/XYuan/Desktop/CFTE Tables")

# Merging data for each year
collect <- function(df_list) {
  df_number = length(df_list)
  if (df_number > 1) {
    merged_df = do.call("rbind", df_list)
    }
  else{
    merged_df = df_list[[1]]
  }
  merged_df
}

fy12_df = collect(all_cfte[[1]])
fy13_df = collect(all_cfte[[2]])
fy14_df = collect(all_cfte[[3]])
fy15_df = collect(all_cfte[[4]])
fy16_df = collect(all_cfte[[5]][1:4])
fy17_df = collect(all_cfte[[6]])

# Create Empty DataFrame
# df_all <- data.frame(`OCO/GF` = character(),
#                      `PSC` = character(),
#                      `PSC Description` = character(),
#                      `FSC` = character(),
#                      `FSC Description` = character(),
#                      `Direct Non-Labor Cost` = numeric(),
#                      `Direct Labor Dollars` = numeric(),
#                      `Number of Contractor FTEs`= numeric(),
#                      `Contract Invoiced Amount` = numeric(),
#                      `CFTE Rate` = numeric(),
#                      `CFTE Factor` = numeric(),
#                      `Location Count` = integer(),
#                      `Fiscal Year` = integer(),
#                      stringsAsFactors=FALSE)

# Standardize Column names


# for (i in (1:length(df_list))){
#   df_list[[i]] <- standardize_variable_names(df_list[[i]], path = "C:/Users/XYuan/Desktop/CFTE Tables/")
# }

fy12_df <- standardize_variable_names(fy12_df, path = "C:/Users/XYuan/Desktop/CFTE Tables/")
fy13_df <- standardize_variable_names(fy13_df, path = "C:/Users/XYuan/Desktop/CFTE Tables/")
fy14_df <- standardize_variable_names(fy14_df, path = "C:/Users/XYuan/Desktop/CFTE Tables/")
fy15_df <- standardize_variable_names(fy15_df, path = "C:/Users/XYuan/Desktop/CFTE Tables/")
fy16_df <- standardize_variable_names(fy16_df, path = "C:/Users/XYuan/Desktop/CFTE Tables/")
fy17_df <- standardize_variable_names(fy17_df, path = "C:/Users/XYuan/Desktop/CFTE Tables/")

df_list <- mget(ls( pattern = "^fy[[:digit:]]" ))

# Add OCO column and Fiscal Year
for (i in (1:length(df_list))) {
  if (i != 6) {
    df_list[[i]] <- df_list[[i]] %>%
      dplyr::mutate( `OCO/GF` = ifelse(str_detect(rownames(.), "OCO"), 'OCO','GF')) %>%
      dplyr::mutate(`Fiscal Year` = ifelse(i==1, 2012, 2011+i))
  }else{
    df_list[[i]] <- df_list[[i]] %>%
      dplyr::mutate( `OCO/GF` = ifelse(`OCO` == 'Y', 'OCO','GF')) %>%
      dplyr::mutate(`Fiscal Year` = ifelse(i==1, 2012, 2011+i)) %>%
      select(-c(`OCO`,`PSC1`))
  }
  
}

# Merge all the dataframes
cfte_new <- bind_rows(df_list)

# Disable scientific notation
#str(cfte_new)
rm_scientific <- function(colnames, df) {
  for (i in colnames) {
    df[i] <- format(df[i], scientific = FALSE)
  }
  df
}

cfte_new <- rm_scientific(c("Contract Invoiced Amount","CFTE Factor","Direct Non-Labor Cost", "Direct Labor Dollars", "Number of Contractor FTEs","CFTE Rate"), cfte_new)
cfte_new[cfte_new == '           NA']<- NA

write.csv(cfte_new,"cfte_factor.csv", na = "", row.names = FALSE)
