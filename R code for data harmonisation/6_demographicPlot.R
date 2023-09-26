### 20/09/2023 ###########################
## clear the workspace ###################

rm(list = ls()); gc()

load("./data/Demography.RData")
install.packages("ggpubr")
library(eeptools)
library(ggpubr)
library(RColorBrewer)
display.brewer.all()

###### change SCSIMD5 0 into NA #################
Demography_HIC[Demography_HIC$SCSIMD5==0,"SCSIMD5"] =NA
##### merge all demo infor together #############
Demography <- Demography_DaSH[,c("PROCHI","sex", "anon_date_of_birth", "SCSIMD5", "From")]
Demography <- rbind(Demography, Demography_Lothian[,c("PROCHI","sex", "anon_date_of_birth", "SCSIMD5", "From")])
Demography <- rbind(Demography, Demography_Glasgow[,c("PROCHI","sex", "anon_date_of_birth", "SCSIMD5", "From")])
Demography <- rbind(Demography, Demography_HIC[,c("PROCHI","sex", "anon_date_of_birth", "SCSIMD5", "From")])



## age by research ##############################
Demography$CalculatedAge <- floor(age_calc(as.Date(as.character(Demography$anon_date_of_birth,format("%Y-%m-%d"))), 
                                  enddate = as.Date(as.character("2022-01-01",format("%Y-%m-%d"))), 
                                  units = "years", precise = TRUE))


##### ggplot #########################
age <- ggplot(Demography, aes(x=From, y=CalculatedAge, fill=sex)) + 
  geom_boxplot(alpha=0.3, outlier.shape = NA) +
  #theme(legend.position="none") +
  scale_fill_brewer(palette="Dark2") +
  xlab("") +
  ylab("Age") +
  theme_grey(base_size = 16)
  #theme(legend.position = c(0.96, 0.2))



dprivation <- ggplot(Demography, aes(From)) + 
  geom_bar(position="fill",aes(fill = SCSIMD5), width = 0.5) +
  scale_fill_brewer(palette="Set2") +
  xlab("Safe Haven") +
  ylab("Count") +
  theme_grey(base_size = 16) +
  #theme(legend.position = c(0.96, 0.2)) +
  theme(legend.title = element_text(colour="black", size=9, 
                                     face="bold"))

figure <- ggarrange(age, dprivation,
                    ncol = 1, nrow = 2)
figure
