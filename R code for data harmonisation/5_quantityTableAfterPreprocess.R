## clear the workspace ###################
rm(list = ls()); gc()

install.packages("ggplot2")
install.packages("eeptools")
install.packages("plyr")
install.packages("dplyr")
library(ggplot2)
library(eeptools)
library(plyr)
library(dplyr)

source("0_functions.R")

load("./data/selectedCodes.RData")
ReadCodeList <- selectedCodes

##########################################
####### value Quantity ####################
##########################################
SHList <- c("HIC","Glasgow","Lothian","DaSH")
quantityTable <- data.frame(ReadCodeList)
colnames(quantityTable)[1] <- "ReadCode"
quantityTable$readCodeDescription <- ""
quantityTable$HIC_valueQuantity <- ""
quantityTable$Glasgow_valueQuantity <- ""
quantityTable$Lothian_valueQuantity <- ""
quantityTable$DaSH_valueQuantity <- ""
quantityTable$p_all <- ""
i=1
for (rc in ReadCodeList) {
  #print(i)
  data_allfour <- c()
  D <- data.frame(subject = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    load(paste0("./data/",SH,"_",rc,"D.RData"))
    data_allfour <- c(data_allfour, data[,"readCodeDescription"])
    
    t <- data[,c("valueQuantity" )]
    t <- t[!is.na(t)]
    if (length(t)!=0) {
      t <- as.numeric(t)
      quantityTable[quantityTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- paste0(round(median(t, na.rm = TRUE),1), " [", round(IQR(t, na.rm = TRUE),1),"]")
      d <- data[,c("subject","valueQuantity","effectiveDate")]
      colnames(d) <- c("subject","t", "effectiveDate")
      d$t <- as.numeric(d$t)
      d$From <- SH
      D <- rbind(D, d)
    } else {
      quantityTable[quantityTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- "NoData"
    }
  }
  D <- na.omit(D)
  tt <- data.frame(table(data_allfour))
  tt <- tt[tt$data_allfour != "",]
  quantityTable[quantityTable$ReadCode==rc,"readCodeDescription"] <- paste0(tt[tt$Freq==max(tt$Freq),"data_allfour"], collapse = "; ")
  
  
  
  #p
  {
  tex <- ""
  p <- p_value_calculate_kruskal(D)
  quantityTable[quantityTable$ReadCode==rc,"p_all"] <- p
  tex[1] <- paste0("p_all=",p)
  
  #p <- p_value_calculate_mann(D[D$From=="HIC"|D$From=="Glasgow",])
  #quantityTable[quantityTable$ReadCode==rc,"p_HICGlasgow"] <- p
  #tex[2] <- paste0("p_HICGlasgow=",p)
  
  #p <- p_value_calculate_mann(D[D$From=="HIC"|D$From=="Lothian",])
  #quantityTable[quantityTable$ReadCode==rc,"p_HICLothian"] <- p
  #tex[3] <- paste0("p_HICLothian=",p)
  
  #p <- p_value_calculate_mann(D[D$From=="HIC"|D$From=="DaSH",])
  #quantityTable[quantityTable$ReadCode==rc,"p_HICDaSH"] <- p
  #tex[4] <- paste0("p_HICDaSH=",p)
  
  #p <- p_value_calculate_mann(D[D$From=="Glasgow"|D$From=="Lothian",])
  #quantityTable[quantityTable$ReadCode==rc,"p_GlasgowLothian"] <- p
  #tex[5] <- paste0("p_GlasgowLothian=",p)
  
  #p <- p_value_calculate_mann(D[D$From=="Glasgow"|D$From=="DaSH",])
  #quantityTable[quantityTable$ReadCode==rc,"p_GlasgowDaSH"] <- p
  #tex[6] <- paste0("p_GlasgowDaSH=",p)
  
  #p <- p_value_calculate_mann(D[D$From=="Lothian"|D$From=="DaSH",])
  #quantityTable[quantityTable$ReadCode==rc,"p_LothianDaSH"] <- p
  #tex[7] <- paste0("p_LothianDaSH=",p)
  }
  i=i+1
} 
save(quantityTable, file = "./data/quantityTable.RData")