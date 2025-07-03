### 20/09/2023 ###########################
## clear the workspace ###################

rm(list = ls()); gc()

library(eeptools)
library(ggpubr)
library(RColorBrewer)
library(ggplot2)
display.brewer.all()

load("./data/Demography.RData")

Demography[is.na(Demography$scsimd5), "scsimd5"] <- "NoData"
Demography <- Demography[Demography$anon_date_of_birth!="",]
## age by research ##############################
Demography$CalculatedAge <- floor(age_calc(as.Date(as.character(Demography$anon_date_of_birth),format("%d/%m/%Y")), 
                                  enddate = Sys.Date(), 
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
  geom_bar(position="fill",aes(fill = scsimd5), width = 0.5) +
  scale_y_continuous(labels = waiver()) +
  scale_fill_brewer(palette="Set2") +
  xlab("Safe Haven") +
  ylab("Percentage") +
  theme_grey(base_size = 16) +
  #theme(legend.position = c(0.96, 0.2)) +
  theme(legend.title = element_text(colour="black", size=9, 
                                     face="bold"))

figure <- ggarrange(age, dprivation,
                    ncol = 1, nrow = 2)
figure
