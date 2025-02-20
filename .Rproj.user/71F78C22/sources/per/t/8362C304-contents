## clear the workspace ######
rm(list = ls()); gc()

# librarys 
library(DBI)
library(readr)

# dependent functions
source('./R code for data harmonisation/0_functions.R')

# read data
DaSH_original <- read.csv('ExemplarTestData/DaSH_original.csv')
DataLoch_original <- read.csv('ExemplarTestData/DataLoch_original.csv')
Glasgow_original <- read.csv('ExemplarTestData/Glasgow_original.csv')
HIC_original <- read.csv('ExemplarTestData/HIC_original.csv')

# create to SQLite DB
con <- dbConnect(RSQLite::SQLite(), ":memory:")

#write example data into database
dbCreateTable(con, 'DaSH', DaSH_original)


# read sql
sql <- read_lines("./SQL code for table structure/test.sql", skip=0)
sql <- paste0(sql, collapse = "  ")

# excute the sql
dbExecute(con, sql)

sql <- strsplit(sql, ";")
lapply(
  sql[[1]],
  function(s) {DBI::dbExecute(con, s)}
)