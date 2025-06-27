## clear the workspace ###################
rm(list = ls()); gc()


SHList <- c("HIC","Glasgow","Lothian","DaSH")
load("./data/selectedCodes.RData")
ReadCodeList <- selectedCodes
source("0_functions.R")

## setup an empty dataframe ##############
load("./data/Demography.RData")

summaryTable <- data.frame(ReadCodeList)
colnames(summaryTable)[1] <- "ReadCode"

summaryTable$readCodeDescription <- ""

summaryTable$HIC_test_freq <- 0
summaryTable$Glasgow_test_freq <- 0
summaryTable$Lothian_test_freq <- 0
summaryTable$DaSH_test_freq <- 0

summaryTable$HIC_valueQuantity <- ""
summaryTable$Glasgow_valueQuantity <- ""
summaryTable$Lothian_valueQuantity <- ""
summaryTable$DaSH_valueQuantity <- ""

summaryTable$HIC_unit <- ""
summaryTable$Glasgow_unit <- ""
summaryTable$Lothian_unit <- ""
summaryTable$DaSH_unit <- ""

summaryTable$HIC_range <- ""
summaryTable$Glasgow_range <- ""
summaryTable$Lothian_range <- ""
summaryTable$DaSH_range <- ""

## filling the readcode description #####
i=1
for (rc in ReadCodeList) {
  
  print(i)
  i=i+1
  data_allfour <- c()
  #D <- data.frame(personId = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    load(paste0("./data/",SH,"_",rc,"D.RData"))
    data_allfour <- c(data_allfour, data[,"readCodeDescription"])
    
    t <- data[data$code==rc,"valueUnit"]
    if (length(t)[1]!=0) {
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_test_freq")] <- round(length(t)/dim(Demography[Demography$From==SH,])[1],3)
      tt <- unique(t)
      tt <- tt[!is.na(tt)]
      tt <- tt[tt!=""]
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_unit")] <- paste0(tt, collapse = "; ")} else {
        summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_test_freq")] <- "NoData"
        summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_unit")] <- "NoData"
      }
    
    t <- data[data$code==rc,c("subject","referenceRangeHigh","referenceRangeLow" )]
    if (dim(t)[1]!=0) {
      t$range <- paste0(round(t$referenceRangeLow,3),"--", round(t$referenceRangeHigh,3))
      tt <- unique(t$range)
      tt <- tt[tt!="0--0"]
      tt <- tt[tt!="NA--NA"]
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_range")] <- paste0(tt, collapse = "; ")
    } else {
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_range")] <- "NoData"
    }
    
    t <- data[data$code==rc,c("valueQuantity" )]
    t <- t[!is.na(t)]
    if (length(t)!=0) {
      t <- as.numeric(t)
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- paste0(round(median(t, na.rm = TRUE),1), " [", round(IQR(t, na.rm = TRUE),1),"] | ", round(mean(t, na.rm = TRUE),1), " (", round(sd(t, na.rm = TRUE),1),")")
      # save data to D for plot
      #d <- data[,c("personId","valueQuantity","effectiveDate")]
      #colnames(d) <- c("personId","t", "effectiveDate")
      #d$t <- as.numeric(d$t)
      #d$From <- SH
      #D <- rbind(D, d)
      
    } else {
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- "NoData"
    }
    
    
  }
  
}
save(summaryTable, file = "./data/summaryTable_preprocessed.RData")



