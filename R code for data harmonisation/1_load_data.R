## clear the workspace ######
rm(list = ls())

######################################
######## install packages ############
######################################
install.packages("DBI")
install.packages("odbc")
install.packages("dplyr")
install.packages("dbplyr")
install.packages("haven")
install.packages("writexl")
install.packages("tidyverse")
install.packages("plotly")
install.packages("ggvenn")
library(ggvenn)
library(odbc)
library(DBI)
library(dplyr)
library(dbplyr)
library(readxl)
library(plotly)
######################################
#### Connecting to the SQL Server ####
######################################
#List drivers -check which ones are available
#sort(unique(odbcListDrivers()[[1]]))
######################################
######################################
#Set up the connection
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "sql.hic-tre.dundee.ac.uk",
                 Database = "RDMP_3564_ExampleData",
                 UID="project-3564", PWD="", TrustServerCertificate="Yes")

#Check the table header names for data table.
#NOTE: You may need to replace 'STAGING' with another schema if this is different. 
#NOTE: Replace 'SE04_53_FP' with the table names.
#tbl(con, in_schema("dbo","FHIR_HIC")) %>% head

#Set up schema for reading table.
#NOTE: You may need to replace 'STAGING' with schema of this is different.
#NOTE: Replace 'SE04_53_FP' with the table name.
TblRead <- DBI::Id(
                   schema = "dbo",
                   table = "HIC_ReadCodeAggregates")
TblRead2 <- DBI::Id(
                   schema = "dbo",
                   table = "Glasgow_ReadCodeAggregates")
TblRead3 <- DBI::Id(
                   schema = "dbo",
                   table = "Lothian_ReadCodeAggregates")
TblRead4 <- DBI::Id(
                   schema = "dbo",
                   table = "DaSH_ReadCodeAggregates")
#This reads the above table as defined under TblRead
HIC_ReadCodeAggregates <- dbReadTable(con, TblRead)
Glasgow_ReadCodeAggregates <- dbReadTable(con, TblRead2)
Lothian_ReadCodeAggregates <- dbReadTable(con, TblRead3)
DaSH_ReadCodeAggregates <- dbReadTable(con, TblRead4)
dim(HIC_ReadCodeAggregates) #size of DF
save(HIC_ReadCodeAggregates,Glasgow_ReadCodeAggregates,Lothian_ReadCodeAggregates,DaSH_ReadCodeAggregates,file = "./data/ReadCodeAggregates.RData")

# 12/12/2022
####################################################################
################# load data table ##################################
####################################################################
#NOTE: Replace 'FHIR_HIC' with the table name.
TblRead <- DBI::Id(
  schema = "dbo",
  table = "FHIR_HIC")
TblRead2 <- DBI::Id(
  schema = "dbo",
  table = "FHIR_Glasgow")
TblRead3 <- DBI::Id(
  schema = "dbo",
  table = "FHIR_Lothian")
TblRead4 <- DBI::Id(
  schema = "dbo",
  table = "FHIR_DaSH")

#This reads the above table as defined under TblRead
D <- dbReadTable(con, TblRead)
save(D, file = "./data/FHIR_HIC.RData")
rm(D)
D <- dbReadTable(con, TblRead2)
save(D, file = "./data/FHIR_Glasgow.RData")
rm(D)
D <- dbReadTable(con, TblRead3)
save(D, file = "./data/FHIR_Lothian.RData")
rm(D)
D <- dbReadTable(con, TblRead4)
save(D, file = "./data/FHIR_DaSH.RData")
rm(D)
# 14/12/2022
####################################################################
################# load demography data table #######################
####################################################################
#### tt will have the duplicated records ####
p_dup <- Demography[duplicated(Demography$PROCHI), "PROCHI"] 
tt <- Demography[Demography$PROCHI %in% p_dup,]
#### there are 361 patients has two date of birth thus two records
#### select the records based on the date of birth
Demography <- Demography %>% group_by(PROCHI) %>% top_n(1, anon_date_of_birth)
#### select the records based on the from
Demography <- Demography %>% group_by(PROCHI) %>% top_n(1, From)
length(unique(Demography$PROCHI))  #150217 equals to the dim of Demogrpahy
save(Demography_HIC, Demography_Glasgow, Demography_Lothian, Demography_DaSH, Demography, file = "./data/Demography.RData")
