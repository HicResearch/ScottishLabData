## clear the workspace ######
rm(list = ls()); gc()
###################################
######## load data ################
###################################

#### Connecting to the SQL Server ####
#con <- dbConnect(odbc(),
#                 Driver = "SQL Server",
#                 Server = "sql.hic-tre.dundee.ac.uk",
#                 Database = "RDMP_3564_ExampleData",
#                 UID="project-3564", PWD="", TrustServerCertificate="Yes")

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "localhost\\SQLEXPRESS",   
                 Database = "example", 
                 UID = "examplelogin",
                 PWD = rstudioapi::askForPassword("Database password"),
                 TrustServerCertificate="Yes")

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
  DataLoch=Lothian_ReadCodeAggregates[Lothian_ReadCodeAggregates[,"code"] %in% t,"code"],  #121
  DaSH=DaSH_ReadCodeAggregates[DaSH_ReadCodeAggregates[,"code"] %in% t,"code"]   #126
)

tt <- ggvenn(x,
       fill_color =c("#0073C2FF","#EFC000FF","#868686FF","#9900FF"),
       stroke_size = 0.5, set_name_size = 4,  show_percentage = FALSE)

plot(tt)

sum(HIC_ReadCodeAggregates[HIC_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(HIC_ReadCodeAggregates[,"recordCount"])  #0.989
sum(Glasgow_ReadCodeAggregates[Glasgow_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(Glasgow_ReadCodeAggregates[,"recordCount"])  #0.974
sum(Lothian_ReadCodeAggregates[Lothian_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(Lothian_ReadCodeAggregates[,"recordCount"])  #0.985
sum(DaSH_ReadCodeAggregates[DaSH_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(DaSH_ReadCodeAggregates[,"recordCount"])  #0.995

#merge all readcodeaggregates
all_aggregate <- rbind(HIC_ReadCodeAggregates, DaSH_ReadCodeAggregates, Lothian_ReadCodeAggregates, Glasgow_ReadCodeAggregates)
all_aggregate <- all_aggregate[,c("code","recordCount")]
all_aggregate <- aggregate(all_aggregate$recordCount, by=list(Category=all_aggregate$code), FUN=sum)
colnames(all_aggregate) <- c("code", "recordCount")
#all4 percentage 
lall4 <- Reduce(intersect, list(x$HIC,x$Glasgow,x$DataLoch,x$DaSH))
l <- lall4
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.79
# three
lhdd <- Reduce(intersect, list(x$HIC,x$DataLoch,x$DaSH))
l <- setdiff(lhdd,lall4)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.072

lhgd <- Reduce(intersect, list(x$HIC,x$Glasgow,x$DaSH))
l <- setdiff(lhgd,lall4)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.0026

lhgl <- Reduce(intersect, list(x$HIC,x$Glasgow,x$DataLoch))
l <- setdiff(lhgl,lall4)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.00996

# two
lgl <- Reduce(intersect, list(x$Glasgow,x$DataLoch))
l <- setdiff(lgl,lall4)
l <- setdiff(l,lhgl)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.0024

lhd <- Reduce(intersect, list(x$HIC,x$DaSH))
l <- setdiff(lhd,lall4)
l <- setdiff(l,lhdd)
l <- setdiff(l,lhgd)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.0145

lhl <- Reduce(intersect, list(x$HIC,x$DataLoch))
l <- setdiff(lhl,lall4)
l <- setdiff(l,lhgl)
l <- setdiff(l,lhdd)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.00173

lhg <- Reduce(intersect, list(x$HIC,x$Glasgow))
l <- setdiff(lhg,lall4)
l <- setdiff(l,lhgd)
l <- setdiff(l,lhgl)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.0159

lld <- Reduce(intersect, list(x$DataLoch,x$DaSH))
l <- setdiff(lld,lall4)
l <- setdiff(l,lhdd)
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.0047

#just one
l <- x$HIC
l <- l[!(l %in% x$Glasgow)]
l <- l[!(l %in% x$DataLoch)]
l <- l[!(l %in% x$DaSH)]
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.0215

l <- x$Glasgow
l <- l[!(l %in% x$HIC)]
l <- l[!(l %in% x$DataLoch)]
l <- l[!(l %in% x$DaSH)]
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.014

l <- x$DataLoch
l <- l[!(l %in% x$Glasgow)]
l <- l[!(l %in% x$HIC)]
l <- l[!(l %in% x$DaSH)]
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.001

l <- x$DaSH
l <- l[!(l %in% x$Glasgow)]
l <- l[!(l %in% x$DataLoch)]
l <- l[!(l %in% x$HIC)]
sum(all_aggregate[all_aggregate[,"code"] %in% l,"recordCount"])/sum(all_aggregate[,"recordCount"])  #0.035
