## clear the workspace ###################
rm(list = ls()); gc()
######################################
######## install packages ############
######################################
install.packages("ggplot2")
install.packages("eeptools")
install.packages("plyr")
install.packages("dplyr")
install.packages("gridExtra")
library(ggplot2)
library(eeptools)
library(plyr)
library(dplyr)
library(gridExtra)
library(RColorBrewer)

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "sql.hic-tre.dundee.ac.uk",
                 Database = "RDMP_3564_ExampleData",
                 UID="project-3564", PWD="", TrustServerCertificate="Yes")

#########################################
###### Scatter plot for referenceRange ##
############### 22/08/2023 ##############
## load demography ##############
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
Demography_Lothian$anon_date_of_birth <- as.Date(as.character(Demography_Lothian$anon_date_of_birth),format = "%d/%m/%Y")
Demography_HIC$From <- "HIC"
Demography_Glasgow$From <- "Glasgow"
Demography_DaSH$From <- "DaSH"
Demography_Lothian$From <- "Lothian"
Demography <- rbind(Demography_HIC[,c("PROCHI", "sex", "anon_date_of_birth","From")], 
                    Demography_Glasgow[,c("PROCHI", "sex", "anon_date_of_birth","From")], 
                    Demography_Lothian[,c("PROCHI", "sex", "anon_date_of_birth","From")], 
                    Demography_DaSH[,c("PROCHI", "sex", "anon_date_of_birth","From")])
Demography <- unique(Demography)

SHList <- c("HIC","Glasgow","Lothian","DaSH")
rc="43Z2."
#print(i)
data_allfour <- c()
for (SH in SHList) {
  Q = paste0("SELECT * FROM FHIR_", SH," WHERE code = '", rc,"'")
  data <- dbGetQuery(con, Q)
  data_allfour <- rbind(data_allfour, data)
}
#########################################################################################
#HIC
t <- data_allfour[data_allfour$healthBoard=="F"|data_allfour$healthBoard=="T",c("subject","referenceRangeHigh","referenceRangeLow","effectiveDate" )]
t <- merge(t, Demography_HIC[,c("PROCHI", "sex", "anon_date_of_birth")], by.x = "subject", by.y = "PROCHI")
t$range <- paste0(round(t$referenceRangeLow,3),"--", round(t$referenceRangeHigh,3))
t$SafeHaven <- "HIC"
D <- t

#Glasgow
t <- data_allfour[data_allfour$healthBoard=="Glasgow",c("subject","referenceRangeHigh","referenceRangeLow","effectiveDate" )]
t <- merge(t, Demography_Glasgow[,c("PROCHI", "sex", "anon_date_of_birth")], by.x = "subject", by.y = "PROCHI")
t$range <- paste0(round(t$referenceRangeLow,3),"--", round(t$referenceRangeHigh,3))
t$SafeHaven <- "Glasgow"
D <- rbind(D, t)

#Lothian
t <- data_allfour[data_allfour$healthBoard=="Lothian",c("subject","referenceRangeHigh","referenceRangeLow","effectiveDate" )]
t <- merge(t, Demography_Lothian[,c("PROCHI", "sex", "anon_date_of_birth")], by.x = "subject", by.y = "PROCHI")
t$range <- paste0(round(t$referenceRangeLow,3),"--", round(t$referenceRangeHigh,3))
t$SafeHaven <- "DataLoch"
D <- rbind(D, t)

#DaSH
t <- data_allfour[data_allfour$healthBoard=="Grampian",c("subject","referenceRangeHigh","referenceRangeLow","effectiveDate" )]
t <- merge(t, Demography_DaSH[,c("PROCHI", "sex", "anon_date_of_birth")], by.x = "subject", by.y = "PROCHI")
t$range <- paste0(round(t$referenceRangeLow,3),"--", round(t$referenceRangeHigh,3))
t$SafeHaven <- "DaSH"
D <- rbind(D, t)

eliminated <-D
eliminated <- subset(eliminated, range!="NA--NA")
eliminated <- subset(eliminated, range!="0--0")
eliminated <- subset(eliminated, range!="-32768---32768")
table(eliminated$range)  #0--2.5   0--3   0--4   0--5
##### find the best value seq ######
eliminated$CalculatedAge <- floor(age_calc(as.Date(as.character(eliminated$anon_date_of_birth,format("%Y-%m-%d"))), enddate = as.Date(as.character(eliminated$effectiveDate,format("%Y-%m-%d"))), units = "years", precise = TRUE))
####### ADD BAND COLUMN ########
eliminated <- eliminated %>% mutate(Band= case_when(CalculatedAge< 25  ~ "0-24",
                                  
                                  CalculatedAge>=25 & CalculatedAge< 35 ~ "25-34",
                                  
                                  CalculatedAge>=35 & CalculatedAge< 45 ~ "35-44",
                                  
                                  CalculatedAge>=45 & CalculatedAge< 55 ~ "45-54",
                                  
                                  CalculatedAge>=55 & CalculatedAge< 65 ~ "55-64",
                                  CalculatedAge>=65 & CalculatedAge< 75 ~ "65-74",
                                  CalculatedAge>=75 & CalculatedAge< 85 ~ "75-84",
                                  
                                  CalculatedAge>=85 ~ "85+"
))
##### Add a new column in the estiminated #####
eliminated <- eliminated %>% mutate(referenceRangeBoard= paste0(range,"  ",SafeHaven))
######################################
#### Plot Scatter Figures ############
######################################
eliminated_s <- eliminated[eliminated$SafeHaven=="DaSH",]
DfForPlot <- ddply(eliminated_s, .(eliminated_s$range, eliminated_s$Band, eliminated_s$SafeHaven), nrow)
names(DfForPlot) <- c("Range", "AGE_BAND", "SafeHaven","Counts")
scatter <- ggplot2::ggplot(DfForPlot, ggplot2::aes_string(x='AGE_BAND', y='Range'))
scatter_dash <- scatter + ggplot2::geom_point(ggplot2::aes_string(size='Counts',color='SafeHaven')) + scale_color_manual(values = c("chocolate"))

eliminated_s <- eliminated[eliminated$SafeHaven=="DataLoch",]
DfForPlot <- ddply(eliminated_s, .(eliminated_s$range, eliminated_s$Band, eliminated_s$SafeHaven), nrow)
names(DfForPlot) <- c("Range", "AGE_BAND", "SafeHaven","Counts")
scatter <- ggplot2::ggplot(DfForPlot, ggplot2::aes_string(x='AGE_BAND', y='Range'))
scatter_dataloch <- scatter + ggplot2::geom_point(ggplot2::aes_string(size='Counts',color='SafeHaven')) + scale_color_manual(values = c("brown1"))

eliminated_s <- eliminated[eliminated$SafeHaven=="Glasgow",]
DfForPlot <- ddply(eliminated_s, .(eliminated_s$range, eliminated_s$Band, eliminated_s$SafeHaven), nrow)
names(DfForPlot) <- c("Range", "AGE_BAND", "SafeHaven","Counts")
scatter <- ggplot2::ggplot(DfForPlot, ggplot2::aes_string(x='AGE_BAND', y='Range'))
scatter_glasgow <- scatter + ggplot2::geom_point(ggplot2::aes_string(size='Counts',color='SafeHaven')) + scale_color_manual(values = c("chartreuse3"))

eliminated_s <- eliminated[eliminated$SafeHaven=="HIC",]
DfForPlot <- ddply(eliminated_s, .(eliminated_s$range, eliminated_s$Band, eliminated_s$SafeHaven), nrow)
names(DfForPlot) <- c("Range", "AGE_BAND", "SafeHaven","Counts")
scatter <- ggplot2::ggplot(DfForPlot, ggplot2::aes_string(x='AGE_BAND', y='Range'))
scatter_hic <- scatter + ggplot2::geom_point(ggplot2::aes_string(size='Counts',color='SafeHaven')) + scale_color_manual(values = c("blue3"))


grid.arrange(scatter_dash, scatter_dataloch, scatter_glasgow, scatter_hic, ncol=2)

######################################
########### boxplot ##################
######################################
p<-ggplot(eliminated, aes(x=range, y=CalculatedAge, fill=SafeHaven)) +
  geom_boxplot(outlier.shape = NA, position=position_dodge(1,preserve = "single")) +
  scale_fill_brewer(palette="Set2") +
  xlab("Reference range") +
  ylab("Age at test") +
  theme(legend.position = "top") +
  theme_grey(base_size = 18)
p
