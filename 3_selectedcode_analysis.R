## clear the workspace ###################
rm(list = ls()); gc()


setwd("P:/Project 3564/ScottishLabData")
SHList <- c("HIC","Glasgow","Lothian","DaSH")
load("./data/selectedCodes.RData")
ReadCodeList <- selectedCodes
source("0_functions.R")

## spilt data based on code ##############
for (SH in SHList) {
  load(paste0("./data/FHIR_",SH,".RData"))
  
  i=1
  
  for (rc in ReadCodeList) {
    #print(i)
    data <- D[D$code==rc,]
    save(data, file = paste0("./data/raw_",SH,"_",rc,"D.RData"))
    i=i+1
  }
}

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
  
  #print(i)
  data_allfour <- c()
  D <- data.frame(personId = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    load(paste0("./data/raw_",SH,"_",rc,"D.RData"))
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
    
    t <- data[data$code==rc,c("personId","referenceRangeHigh","referenceRangeLow" )]
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
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- paste0(round(median(t, na.rm = TRUE),1), " [", round(IQR(t, na.rm = TRUE),1),"]")
      # save data to D for plot
      d <- data[,c("personId","valueQuantity","effectiveDate")]
      colnames(d) <- c("personId","t", "effectiveDate")
      d$t <- as.numeric(d$t)
      d$From <- SH
      D <- rbind(D, d)
      
    } else {
      summaryTable[summaryTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- "NoData"
    }
    
    
  }
  
  D <- na.omit(D)
  tt <- data.frame(table(data_allfour))
  tt <- tt[tt$data_allfour != "",]
  summaryTable[summaryTable$ReadCode==rc,"readCodeDescription"] <- paste0(tt[tt$Freq==max(tt$Freq),"data_allfour"], collapse = "; ")
  
  
  #### set the working directory #######
  setwd("P:/Project 3564/ScottishLabData")
  #### plot the density distribution ###
  cl <- rainbow(5)
  png(paste0("./plot/raw_",rc,"_rplot.png"), width = 1200, height = 560, pointsize = 14)
  t <- D$t
  
  
  if (length(t)!=0 & length(unique(t))>1) {
    BW=bandwidthfunction(t)
    d <- density(t,bw=BW)
    par(mfrow=c(1,2))
    plot(density(t,bw=BW),main = "Density plot",lwd=5, xlab="Value", cex=1.5)
    
    
    t <- D[D$From=="HIC","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[1],lwd=3)  #HIC rea line
    }
    t <- D[D$From=="Glasgow","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[2],lwd=3)  # glasgow green line
    }
    t <- D[D$From=="Lothian","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[4],lwd=3)  # glasgow blue line
    }
    t <- D[D$From=="DaSH","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[5],lwd=3)  # DaSH pink line
    }
    
    legend(x=0.8*(max(D$t)-min(D$t))+min(D$t),y=0.9*max(d$y),legend=c("ALL","HIC","Glasgow","Lothian","DaSH"),
           col = c("black",cl[1],cl[2],cl[4],cl[5]), lty=1, lwd=c(5,3,3,3,3),cex=0.8,
           title = "Data From", text.font = 4, bg="lightblue")
    
    ##### drag value to zero if the subgroup contains fewer than 5 patients
    t <- D %>% group_by(From) %>% count()
    t <- t[t$n<6,]
    if (dim(t)[1]>0) {
    for (j in 1:dim(t)[1]) {
      D[D$From==as.character(t[j,"From"]),"t"]=0
    }
    }
    boxplot(D$t ~ D$From, data = D, col = "lightgray")
 
  }
  dev.off()
  i=i+1
}
save(summaryTable, file = "./data/summaryTable.RData")
####################################################
####################################################
####################################################
  
  
  