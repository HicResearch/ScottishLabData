## clear the workspace ###################
rm(list = ls()); gc()

#install.packages("ggplot2")
#install.packages("eeptools")
#install.packages("plyr")
#install.packages("dplyr")
library(ggplot2)
library(eeptools)
library(plyr)
library(dplyr)

source("0_functions.R")
load("./data/Demography.RData")

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


load("./data/selectedCodes.RData")
ReadCodeList <- selectedCodes

##########################################
########## plot a  #######################
##########################################
SHList <- c("HIC","Glasgow","Lothian","DaSH")
i=1
for (rc in ReadCodeList) {
####### load raw data  ############
  print(i)
  D <- data.frame(subject = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    Q = paste0("SELECT * FROM FHIR_", SH," WHERE code = '", rc,"'")
    
    data <- dbGetQuery(con, Q)
    t <- data[data$code==rc,"valueUnit"]
    if (length(t)[1]!=0) {
      tt <- unique(t)
      tt <- tt[!is.na(tt)]
      tt <- tt[tt!=""]
      }
    
    t <- data[data$code==rc,c("subject","referenceRangeHigh","referenceRangeLow" )]
    if (dim(t)[1]!=0) {
      t$range <- paste0(round(t$referenceRangeLow,3),"--", round(t$referenceRangeHigh,3))
      tt <- unique(t$range)
      tt <- tt[tt!="0--0"]
      tt <- tt[tt!="NA--NA"]
      } else {
      }
    
    t <- data[data$code==rc,c("valueQuantity" )]
    t <- t[!is.na(t)]
    if (length(t)!=0) {
      t <- as.numeric(t)
      # save data to D for plot
      d <- data[,c("subject","valueQuantity","effectiveDate")]
      colnames(d) <- c("subject","t", "effectiveDate")
      d$t <- as.numeric(d$t)
      d$From <- SH
      D <- rbind(D, d)
      
    } else {
      }
    
    
  }
  
  D <- na.omit(D)
  D_raw <- D
###### load preprocessed data  ###########
  
  #print(i)
  D <- data.frame(subject = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    load(paste0("./data/",SH,"_",rc,"D.RData"))
    t <- data[,c("valueQuantity" )]
    t <- t[!is.na(t)]
    if (length(t)!=0) {
      t <- as.numeric(t)
      d <- data[,c("subject","valueQuantity","effectiveDate")]
      colnames(d) <- c("subject","t", "effectiveDate")
      d$t <- as.numeric(d$t)
      d$From <- SH
      D <- rbind(D, d)
    } 
  }
  D <- na.omit(D)
  D_preprocessed <- D
  
  #p
  {
    tex <- ""
    p <- p_value_calculate_kruskal(D)
    tex[1] <- paste0("p_all=",p)
  
  }
  #######################################################
  ### manually change bar plot with count lower than 6 ##
  #######################################################  
  t <- D$t
  if (length(t)!=0 & length(unique(t))>1) {
    b <- seq(min(D$t),max(D$t),length.out = 30)
    if (length(D[D$From=="HIC","t"])!=0) {
      tt <- hist(D[D$From=="HIC","t"], breaks = b)
      c <- tt$counts
      cc <- c
      cc[c<6] <- 0
      tt$counts <- cc
      tt_HIC <- tt     #bar plot object for HIC
    }
    if (length(D[D$From=="Glasgow","t"])!=0) {
      tt <- hist(D[D$From=="Glasgow","t"], breaks = b)
      c <- tt$counts
      cc <- c
      cc[c<6] <- 0
      tt$counts <- cc
      tt_Glasgow <- tt   #bar plot object for Glasgow
    }
    if (length(D[D$From=="Lothian","t"])!=0) {
      tt <- hist(D[D$From=="Lothian","t"], breaks = b)
      c <- tt$counts
      cc <- c
      cc[c<6] <- 0
      tt$counts <- cc
      tt_Lothian <- tt  #bar plot object for Lothian
    }
    if (length(D[D$From=="DaSH","t"])!=0) {
      tt <- hist(D[D$From=="DaSH","t"], breaks = b)
      c <- tt$counts
      cc <- c
      cc[c<6] <- 0
      tt$counts <- cc
      tt_DaSH <- tt     #bar plot object for DaSH
    }
############################################  
########## plot ############################
######## 09/15/2023 ########################
par(mfrow=c(1,1))
cl <- rainbow(5)
png(paste0("./plot/a_",rc,"_rplot.png"), width = 2480, height = 1240, pointsize = 30)
#png(paste0("./plot/a_",rc,"_rplot.png"))
par(mfrow=c(2,4))
#### plot the density distribution for raw ###
  D <-D_raw
  t <- D$t
  if (length(t)!=0 & length(unique(t))>1) {
    BW=bandwidthfunction(t)
    d <- density(t,bw=BW)
    plot(density(t,bw=BW),main = "Density plot before preprocess",lwd=5, xlab="ValueQuantity", cex=1.5)
    
    
    t <- D[D$From=="HIC","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[1],lwd=3)  #HIC red line
    }
    t <- D[D$From=="Glasgow","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[2],lwd=3)  # glasgow green line
    }
    t <- D[D$From=="Lothian","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[4],lwd=3)  # Lothian blue line
    }
    t <- D[D$From=="DaSH","t"]
    if (length(t)!=0) {
      #BW=bandwidthfunction(t)
      lines(density(t,bw=BW),col=cl[5],lwd=3)  # DaSH pink line
    }
    
    legend(x=0.5*(max(D$t)-min(D$t))+min(D$t),y=0.9*max(d$y),legend=c("ALL","HIC","Glasgow","Lothian","DaSH"),
           col = c("black",cl[1],cl[2],cl[4],cl[5]), lty=1, lwd=c(5,3,3,3,3),cex=0.8,
           title = "Data From", text.font = 4, bg="lightblue")
      
#### plot the density distribution after preprocess###
    D <- D_preprocessed
    t <- D$t

      BW=bandwidthfunction(t)
      plot(density(t,bw=BW),main = "Density plot after preprocess",lwd=5, xlab="ValueQuantity", cex=1.5)
      
      
      t <- D[D$From=="HIC","t"]
      if (length(t)!=0) {
        #BW=bandwidthfunction(t)
        lines(density(t,bw=BW),col=cl[1],lwd=3)  #HIC red line
      }
      t <- D[D$From=="Glasgow","t"]
      if (length(t)!=0) {
        #BW=bandwidthfunction(t)
        lines(density(t,bw=BW),col=cl[2],lwd=3)  # glasgow green line
      }
      t <- D[D$From=="Lothian","t"]
      if (length(t)!=0) {
        #BW=bandwidthfunction(t)
        lines(density(t,bw=BW),col=cl[4],lwd=3)  # Lothian blue line
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
             
##### bar plot of HIC and Glasgow after preprocess ####
      if (length(D[D$From=="HIC","t"])!=0) {
        plot(tt_HIC, xlab = "valueQuantity", ylab = "Count", main = "Histogram of HIC data", text.font = 8)
      }
      if (length(D[D$From=="Glasgow","t"])!=0) {
        plot(tt_Glasgow, xlab = "valueQuantity",  ylab = "Count", main = "Histogram of Glasgow data", text.font = 8)
      }  
      
##### plot box plot raw ###################################
      D <- D_raw
      ##### drag value to zero if the subgroup contains fewer than 5 patients
      t <- D %>% group_by(From) %>% count()
      t <- t[t$n<6,]
      j=1
      if (dim(t)[1]>0) {
        for (j in 1:dim(t)[1]) {
          D[D$From==as.character(t[j,"From"]),"t"]=0
        }
      }
      boxplot(D$t ~ D$From, outline=FALSE, xlab="SafeHaven", ylab = "valueQuantity", data = D, col = "lightgray", main="Boxplot before preprocess")
      
##### plot box plot preprocessed ###############################
      D <- D_preprocessed
      ##### drag value to zero if the subgroup contains fewer than 5 patients
      t <- D %>% group_by(From) %>% count()
      t <- t[t$n<6,]
      j=1
      if (dim(t)[1]>0) {
        for (j in 1:dim(t)[1]) {
          D[D$From==as.character(t[j,"From"]),"t"]=0
        }
      }
      boxplot(D$t ~ D$From, outline=FALSE, xlab="SafeHaven", ylab = "valueQuantity", data = D, col = "lightgray", main="Boxplot after preprocess")
      
##### bar plot of Lothian and DaSH after preprocess ####
      if (length(D[D$From=="Lothian","t"])!=0) {
        plot(tt_Lothian, xlab = "valueQuantity", ylab = "Count", main = "Histogram of Lothian data", text.font = 8)  
      }
      if (length(D[D$From=="DaSH","t"])!=0) {
        plot(tt_DaSH, xlab = "valueQuantity", ylab = "Count", main = "Histogram of DaSH data", text.font = 8)
      }
      
################# close off plot  #####################
      dev.off()      
  } 
}
  i=i+1
}


# depends on the size of the data, the following
# code can take a long time to run, hence separated 
# from the plot a
##########################################
######## plot b ##########################
##########################################
i=1
for (rc in ReadCodeList) {
  ###### load preprocessed data  ###########
  
  print(i)
  D <- data.frame(subject = character(), t = double(), effectiveDate =character(), From = character())
  for (SH in SHList) {
    load(paste0("./data/",SH,"_",rc,"D.RData"))
    t <- data[,c("valueQuantity" )]
    t <- t[!is.na(t)]
    if (length(t)!=0) {
      t <- as.numeric(t)
      d <- data[,c("subject","valueQuantity","effectiveDate")]
      colnames(d) <- c("subject","t", "effectiveDate")
      d$t <- as.numeric(d$t)
      d$From <- SH
      D <- rbind(D, d)
    } 
  }
  D <- na.omit(D)
  D_preprocessed <- D
  
  
    ############################################  
    ########## plot ############################
    ######## 09/15/2023 ########################
    par(mfrow=c(1,1))
    t <- D$t
    if (length(t)!=0 & length(unique(t))>1) {
    D <- D_preprocessed
    colnames(D)[2] <- "Value"
    D <- merge(D, Demography[,c("PROCHI","sex","anon_date_of_birth")], by.x="subject", by.y="PROCHI")
    ### group based on sex and age then plot
    ## age at test
    
    ### following are highly computational expensive 
    ### but calculate the extact age considering the month variable
    #D$CalculatedAge <- floor(age_calc(as.Date(as.character(D$anon_date_of_birth)), 
    #                                  enddate = as.Date(as.character(D$effectiveDate)), 
    #                                 units = "years", precise = TRUE))
    
    
    ### to reduce the computational cost
    ### for the project we simply calucated the difference between year of birth and year of test
    ### we recomment to use the above function if possible
      D$year_of_birth <- format(as.Date(D$anon_date_of_birth),"%Y")
      D$year_of_test <- format(as.Date(D$effectiveDate),"%Y")
      D$CalculatedAge <- as.integer(D$year_of_test)-as.integer(D$year_of_birth)
    
    
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
    ##### ggplot #########################
    ggplot(D, aes(x=Band, y=Value, fill=sex)) + 
      geom_boxplot(alpha=0.3, outlier.shape = NA) +
      #theme(legend.position="none") +
      scale_fill_brewer(palette="Set2") +
      xlab("Age band at test") +
      ylab("valueQuantity") +
      ylim(0, 180) +
      theme_grey(base_size = 18)
    ###### ggsave ########################
    ggsave(paste0("./plot/b_",rc,"_rplot.png"), width = 10, height = 4.7, dpi=120,unit="in")
    }
    i=i+1
}


