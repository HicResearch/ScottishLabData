## clear the workspace ######
rm(list = ls()); gc()
###################################
######## load data ################
###################################

#### Connecting to the SQL Server ####
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "sql.hic-tre.dundee.ac.uk",
                 Database = "RDMP_3564_ExampleData",
                 UID="project-3564", PWD="", TrustServerCertificate="Yes")

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
###################################
###### venn diagram ###############
###################################
Lothian_ReadCodeAggregates <- Lothian_ReadCodeAggregates[order(-Lothian_ReadCodeAggregates$recordCount),]
HIC_ReadCodeAggregates <- HIC_ReadCodeAggregates[order(-HIC_ReadCodeAggregates$recordCount),]
Glasgow_ReadCodeAggregates <- Glasgow_ReadCodeAggregates[order(-Glasgow_ReadCodeAggregates$recordCount),]
DaSH_ReadCodeAggregates <- DaSH_ReadCodeAggregates[order(-DaSH_ReadCodeAggregates$recordCount),]

### calculate how many unique test across SHs##
########### 09/14/2023 ########################
all <- rbind(Lothian_ReadCodeAggregates, HIC_ReadCodeAggregates, Glasgow_ReadCodeAggregates, DaSH_ReadCodeAggregates)
length(unique(all$code))

t <- c(HIC_ReadCodeAggregates[1:100,"code"],Glasgow_ReadCodeAggregates[1:100,"code"],Lothian_ReadCodeAggregates[1:100,"code"],DaSH_ReadCodeAggregates[1:100,"code"])
t <- unique(t)
t <- t[!t==""]    #180 codes

selectedCodes <- t
save(selectedCodes, file = "./data/selectedCodes.RData")

x <- list(
  HIC=HIC_ReadCodeAggregates[HIC_ReadCodeAggregates[,"code"] %in% t,"code"],  # 135
  Glasgow=Glasgow_ReadCodeAggregates[Glasgow_ReadCodeAggregates[,"code"] %in% t,"code"],  #128
  Lothian=Lothian_ReadCodeAggregates[Lothian_ReadCodeAggregates[,"code"] %in% t,"code"],  #121
  DaSH=DaSH_ReadCodeAggregates[DaSH_ReadCodeAggregates[,"code"] %in% t,"code"]   #126
)

ggvenn(x,
       fill_color =c("#0073C2FF","#EFC000FF","#868686FF","#9900FF"),
       stroke_size = 0.5, set_name_size = 4)

sum(HIC_ReadCodeAggregates[HIC_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(HIC_ReadCodeAggregates[,"recordCount"])  #0.989
sum(Glasgow_ReadCodeAggregates[Glasgow_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(Glasgow_ReadCodeAggregates[,"recordCount"])  #0.974
sum(Lothian_ReadCodeAggregates[Lothian_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(Lothian_ReadCodeAggregates[,"recordCount"])  #0.985
sum(DaSH_ReadCodeAggregates[DaSH_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(DaSH_ReadCodeAggregates[,"recordCount"])  #0.995
