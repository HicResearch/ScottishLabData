## clear the workspace ###################
rm(list = ls()); gc()

install.packages("ggplot2", repos=NULL, contriburl="file:V:/R/3.6.2/")
install.packages("eeptools", repos=NULL, contriburl="file:V:/R/3.6.2/")
install.packages("plyr", repos=NULL, contriburl="file:V:/R/3.6.2/")
install.packages("dplyr", repos=NULL, contriburl="file:V:/R/3.6.2/")
library(ggplot2)
library(eeptools)
library(plyr)
library(dplyr)

#### set the working directory #######
setwd("P:/Project 3564/ScottishLabData")
source("0_functions.R")

load("./data/selectedCodes.RData")
ReadCodeList <- selectedCodes

##########################################
####### value Quantiy ####################
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
#quantityTable$p_HICGlasgow <- ""
#quantityTable$p_HICLothian <- ""
#quantityTable$p_HICDaSH <- ""
#quantityTable$p_GlasgowLothian <- ""
#quantityTable$p_GlasgowDaSH <- ""
#quantityTable$p_LothianDaSH <- ""
i=1
for (rc in ReadCodeList) {
  #print(i)
  data_allfour <- c()
  D <- data.frame(personId = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    load(paste0("./data/",SH,"_",rc,"D.RData"))
    data_allfour <- c(data_allfour, data[,"readCodeDescription"])
    
    t <- data[,c("valueQuantity" )]
    t <- t[!is.na(t)]
    if (length(t)!=0) {
      t <- as.numeric(t)
      quantityTable[quantityTable$ReadCode==rc,paste0(SH,"_valueQuantity")] <- paste0(round(median(t, na.rm = TRUE),1), " [", round(IQR(t, na.rm = TRUE),1),"]")
      d <- data[,c("personId","valueQuantity","effectiveDate")]
      colnames(d) <- c("personId","t", "effectiveDate")
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
  
  t <- D$t
  
  
  if (length(t)!=0 & length(unique(t))>1) {
  b <- seq(min(D$t),max(D$t),length.out = 30)
  if (length(D[D$From=="HIC","t"])!=0) {
    tt <- hist(D[D$From=="HIC","t"], breaks = b)
    c <- tt$counts
    cc <- c
    cc[c<6] <- 0
    tt$counts <- cc
    tt_HIC <- tt
  }
  if (length(D[D$From=="Glasgow","t"])!=0) {
    tt <- hist(D[D$From=="Glasgow","t"], breaks = b)
    c <- tt$counts
    cc <- c
    cc[c<6] <- 0
    tt$counts <- cc
    tt_Glasgow <- tt
  }
  if (length(D[D$From=="Lothian","t"])!=0) {
    tt <- hist(D[D$From=="Lothian","t"], breaks = b)
    c <- tt$counts
    cc <- c
    cc[c<6] <- 0
    tt$counts <- cc
    tt_Lothian <- tt  
  }
  if (length(D[D$From=="DaSH","t"])!=0) {
    tt <- hist(D[D$From=="DaSH","t"], breaks = b)
    c <- tt$counts
    cc <- c
    cc[c<6] <- 0
    tt$counts <- cc
    tt_DaSH <- tt
  }
  }
  
    #### set the working directory #######
    setwd("P:/Project 3564/ScottishLabData")
    #### plot the density distribution ###
    cl <- rainbow(5)
    png(paste0("./plot/a_",rc,"_rplot.png"), width = 1200, height = 1680, pointsize = 24)
    t <- D$t
   
    
    if (length(t)!=0 & length(unique(t))>1) {
      BW=bandwidthfunction(t)
      d <- density(t,bw=BW)
      par(mfrow=c(3,2))
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
    
    x_location <- 0.8*(max(D$t)-min(D$t))+min(D$t)
    y_location <- 0.2*max(d$y)
    text(x=x_location,y=0.8* y_location,tex[1],text.font = 8)
    #text(x=x_location,y=0.7* y_location,tex[2])
    #text(x=x_location,y=0.6* y_location,tex[3])
    #text(x=x_location,y=0.5* y_location,tex[4])
    #text(x=x_location,y=0.4* y_location,tex[5])
    #text(x=x_location,y=0.3* y_location,tex[6])
    #text(x=x_location,y=0.2* y_location,tex[7])
    
    ##### drag value to zero if the subgroup contains fewer than 5 patients
    t <- D %>% group_by(From) %>% count()
    t <- t[t$n<6,]
    j=1
    if (dim(t)[1]>0) {
    for (j in 1:dim(t)[1]) {
      D[D$From==as.character(t[j,"From"]),"t"]=0
    }
    }
    boxplot(D$t ~ D$From, data = D, col = "lightgray")
    b <- seq(min(D$t),max(D$t),length.out = 30)
    if (length(D[D$From=="HIC","t"])!=0) {
    plot(tt_HIC, xlab = "value", main = "Histogram of HIC data", text.font = 8)
    }
    if (length(D[D$From=="Glasgow","t"])!=0) {
    plot(tt_Glasgow, xlab = "value", main = "Histogram of Glasgow data", text.font = 8)
      }
    if (length(D[D$From=="Lothian","t"])!=0) {
      plot(tt_Lothian, xlab = "value", main = "Histogram of Lothian data", text.font = 8)  
      }
    if (length(D[D$From=="DaSH","t"])!=0) {
      plot(tt_DaSH, xlab = "value", main = "Histogram of DaSH data", text.font = 8)
      }
    
    #hist(as.integer(D$t), breaks=c((min(as.integer(D$t), na.rm=TRUE)-2):(max(as.integer(D$t),na.rm=TRUE)+1)), col='red', xlab="QuantityValue", main="Histogram")
    
    }
    dev.off()
    
    if (length(D[,"t"])!=0) {
   
    #### plot the scatter plot ###
    load("./data/Demography.RData")
    colnames(D)[2] <- "Value"
    D <- merge(D, Demography[,c("PROCHI","sex","anon_date_of_birth")], by.x="personId", by.y="PROCHI")
    ### group based on sex and age then plot
    ## age at test
    D$CalculatedAge <- floor(age_calc(as.Date(as.character(D$anon_date_of_birth,format("%Y-%m-%d"))), 
                                               enddate = as.Date(as.character(D$effectiveDate,format("%Y-%m-%d"))), 
                                               units = "years", precise = TRUE))
  
    ####### ADD BAND COLUMN ########
    D <- D %>% mutate(Band= case_when(CalculatedAge< 16  ~ "0-15",
                                      
                                      CalculatedAge>=16 & CalculatedAge< 25 ~ "16-24",
                                      
                                      CalculatedAge>=25 & CalculatedAge< 35 ~ "25-34",
                                      
                                      CalculatedAge>=35 & CalculatedAge< 45 ~ "35-44",
                                      
                                      CalculatedAge>=45 & CalculatedAge< 55 ~ "45-54",
                                      
                                      CalculatedAge>=55 & CalculatedAge< 65 ~ "55-64",
                                      
                                      CalculatedAge>=65 ~ "65+"
                                      ))
    ##### drag value to zero if the subgroup contains fewer than 5 patients
    t <- D %>% group_by(sex, Band) %>% count()
    t <- t[t$n<6,]
    j=1
    if (dim(t)[1]>0) {
    for (j in 1:dim(t)[1]) {
      D[D$sex==as.character(t[j,"sex"]) & D$Band==as.character(t[j,"Band"]),"Value"]=0
    }
    }
    ##### ggplot
    ggplot(D, aes(x=Band, y=Value, fill=sex)) + 
      geom_boxplot(alpha=0.3) +
      #theme(legend.position="none") +
      scale_fill_brewer(palette="BuPu")
   
    ggsave(paste0("./plot/b_",rc,"_rplot.png"), width = 10, height = 4.7, dpi=120,unit="in")
    
    }
    
  i=i+1
} 
save(quantityTable, file = "./data/quantityTable.RData")
#write.csv(quantityTable, "P:/Project 3564/ScottishLabData/quantityTable14032023.csv")