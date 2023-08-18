## clear the workspace ###################
rm(list = ls()); gc()

#### set the working directory #######
source("0_functions.R")

######################################
#### unit and value transformation ###
######################################
unitchange <- read_excel("unitTransfermation.xls")
colnames(unitchange)[8] <- "Rule"

### HIC ##############
SHList <- c("HIC","Glasgow","Lothian","DaSH")
# dataframe to host data for censored data percentage
cenceredtest <- data.frame(SafeHaven = character(), code = character(), totaltest = double(), censoredtest = double())

for (SH in SHList) {
load(paste0("./data/FHIR_",SH,".RData"))
load("./data/selectedCodes.RData")
##eval(paste0("D <- FHIR_",SH))
ReadCodeList <- selectedCodes
##rm(list=paste0("FHIR_",SH))
##D_t <- data.frame(matrix(ncol = 14, nrow = 0))
##colnames(D_t) <- c("personId","category","code","effectiveDate","valueQuantity","valueUnit","valueString","referenceRangeHigh","referenceRangeLow","encounterId","specimentType","healthBoard","readCodeDescription","originalValueQuantity")
D[,"valueQuantity"] <- as.double(as.character(D[,"valueQuantity"]))

i=1
#print((j-1)*10+1)

for (rc in ReadCodeList) {
  print(i)
  unitinfor <- unitchange[unitchange$ReadCode==rc,]
  data <- D[D$code==rc,]
  data$originalValueQuantity <- data$valueQuantity
  
  data <- unitTransferFunction(data,unitinfor)
  data <- outlierCutFunction(data)
  data <- CensoredValueFunction(data)
  ## calculate the percentage of censored value
  d <- data.frame(SafeHaven = SH) 
  d$code <- rc
  d$totaltest <- dim(data)[1]
  d$censoredtest <- dim(data[data$valueQuantity!=data$originalValueQuantity,])[1]
  cenceredtest <- rbind(cenceredtest,d)
  save(data, file = paste0("./data/",SH,"_",rc,"D.RData"))
  ##D_t <- rbind(D_t,data)
  i=i+1
  
}
save(cenceredtest, file ="./data/cenceredtest.RData" )
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
  summaryTable[summaryTable$ReadCode==rc,"readCodeDescription"] <- paste0(tt[tt$Freq==max(tt$Freq),"data_allfour"], collapse = "; ")
  
  
  i=i+1
} 
