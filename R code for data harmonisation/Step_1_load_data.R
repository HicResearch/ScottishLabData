##### this file is for testing the sql server connection #######
####  as well as backup all necessary data in R as #############

## clear the workspace ######
rm(list = ls()); gc()

source("./0_functions.R")


######################################
#### Connecting to the SQL Server ####
######################################
#List drivers -check which ones are available
#sort(unique(odbcListDrivers()[[1]]))
######################################
######################################
#Set up the connection, uncomment when running example
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "localhost\\SQLEXPRESS",   
                 Database = "example", 
                 UID = "examplelogin",
                 PWD="password",
                 TrustServerCertificate="Yes")


#connections used when conducting this project, comment when running example
#con <- dbConnect(odbc(),
#                 Driver = "SQL Server",
#                 Server = "sql.hic-tre.dundee.ac.uk",   
#                 Database = "RDMP_3564_ExampleData", 
#                 UID = "project-3564",
#                 PWD = "",
#                 TrustServerCertificate="Yes")

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

# creat a folder for data
mainDir <- "./"
subDir <- "data"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

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
TblRead <- DBI::Id(
  schema = "dbo",
  table = "Demography_HIC")
TblRead2 <- DBI::Id(
  schema = "dbo",
  table = "Demography_Glasgow")
TblRead3 <- DBI::Id(
  schema = "dbo",
  table = "Demography_Lothian")
TblRead4 <- DBI::Id(
  schema = "dbo",
  table = "Demography_DaSH")

#This reads the above table as defined under TblRead
Demography_HIC <- dbReadTable(con, TblRead)
Demography_Glasgow <- dbReadTable(con, TblRead2)
Demography_Lothian <- dbReadTable(con, TblRead3)
Demography_DaSH <- dbReadTable(con, TblRead4)
#Demography_Lothian$anon_date_of_birth <- as.Date(as.character(Demography_Lothian$anon_date_of_birth),format = "%d/%m/%Y")
Demography_HIC$From <- "HIC"
Demography_Glasgow$From <- "Glasgow"
Demography_DaSH$From <- "DaSH"
Demography_Lothian$From <- "Lothian"
Demography <- rbind(Demography_HIC[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")], 
                    Demography_Glasgow[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")], 
                    Demography_Lothian[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")], 
                    Demography_DaSH[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")])
Demography <- unique(Demography)
save(Demography_HIC, Demography_Glasgow, Demography_Lothian, Demography_DaSH, Demography, file = "./data/Demography.RData")
