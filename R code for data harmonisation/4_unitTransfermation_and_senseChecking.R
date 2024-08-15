## clear the workspace ###################
rm(list = ls()); gc()

source("0_functions.R")

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "sql.hic-tre.dundee.ac.uk",
                 Database = "RDMP_3564_ExampleData",
                 UID="project-3564", PWD="", TrustServerCertificate="Yes")

######################################
#### unit and value transformation ###
######################################
unitchange <- read_excel("unitTransfermation.xls")
colnames(unitchange)[8] <- "Rule"
SHList <- c("HIC","Glasgow","Lothian","DaSH")
# dataframe to host data for censored data percentage
cenceredtest <- data.frame(SafeHaven = character(), code = character(), totaltest = double(), censoredtest = double())
# dataframe to host data for unit transfer data lost
unittransferdatalose <- data.frame(SafeHaven = character(), code = character(), totaltest = double(), afterunittransfer = double())
###### loop #########################
for (SH in SHList) {
load("./data/selectedCodes.RData")
ReadCodeList <- selectedCodes
i=1
for (rc in ReadCodeList) {
  print(i)
  unitinfor <- unitchange[unitchange$ReadCode==rc,]
  Q = paste0("SELECT * FROM FHIR_", SH," WHERE code = '", rc,"'")
  data <- dbGetQuery(con, Q)
  data[,"valueQuantity"] <- as.double(as.character(data[,"valueQuantity"]))
  data$originalValueQuantity <- data$valueQuantity
  dimoriginal <- dim(data)      # calculate how many records before change
  data <- unitTransferFunction(data,unitinfor,rc)
  ## calculate the percentage of records lose through unit transer
  d <- data.frame(SafeHaven = SH) 
  d$code <- rc
  d$totaltest <- dimoriginal[1]
  d$afterunittransfer <- dim(data)[1]
  unittransferdatalose <- rbind(unittransferdatalose,d)
  #############################################
  data <- outlierCutFunction(data)
  data <- CensoredValueFunction(data)
  ## calculate the percentage of censored value
  d <- data.frame(SafeHaven = SH) 
  d$code <- rc
  d$totaltest <- dim(data)[1]
  d$censoredtest <- dim(data[data$valueQuantity!=data$originalValueQuantity,])[1]
  cenceredtest <- rbind(cenceredtest,d)
  #############################################
  save(data, file = paste0("./data/",SH,"_",rc,"D.RData"))
  ##D_t <- rbind(D_t,data)
  i=i+1
  
}
save(cenceredtest, file ="./data/cenceredtest.RData" )
save(unittransferdatalose, file ="./data/unittransferdatalose.RData" )

}

#############################################
########## test the unit ####################
#############################################
ReadCodeList <- selectedCodes
################################################################
summaryTable <- data.frame(ReadCodeList)
colnames(summaryTable)[1] <- "ReadCode"

summaryTable$readCodeDescription <- ""

summaryTable$HIC_unit <- ""
summaryTable$Glasgow_unit <- ""
summaryTable$Lothian_unit <- ""
summaryTable$DaSH_unit <- ""

i=1
for (rc in ReadCodeList) {
  #print(i)
  data_allfour <- c()
  
  for (SH in SHList) {
  load(paste0("./data/",SH,"_",rc,"D.RData"))
  data_allfour <- c(data_allfour, data[,"readCodeDescription"])
  
  t <- data[,"valueUnit"]
  if (length(t)[1]!=0) {
    
    tt <- unique(t)
    if (is.na(tt)) {
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_unit")] <- "NA"
    } else {
      tt <- tt[!is.na(tt)]
      tt <- tt[tt!=""]
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_unit")] <- paste0(tt, collapse = "; ")
    }
  } else {
    
    summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_unit")] <- "NoData"
  }
  
  }
  tt <- data.frame(table(data_allfour))
  tt <- tt[tt$data_allfour != "",]
  if (length(tt)>0) {
    summaryTable[summaryTable$ReadCode==rc,"readCodeDescription"] <- paste0(tt[tt$Freq==max(tt$Freq),"data_allfour"], collapse = "; ")
  } 
  
  i=i+1
} 
