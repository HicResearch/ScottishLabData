## clear the workspace ######
rm(list = ls()); gc()

install.packages("ggvenn", repos=NULL, contriburl="file:V:/R/4.1.2/")
library(ggvenn)
load("./data/ReadCodeAggregates.RData")
###################################
###### venn diagram ###############
###################################
Lothian_ReadCodeAggregates <- Lothian_ReadCodeAggregates[order(-Lothian_ReadCodeAggregates$recordCount),]
HIC_ReadCodeAggregates <- HIC_ReadCodeAggregates[order(-HIC_ReadCodeAggregates$recordCount),]
Glasgow_ReadCodeAggregates <- Glasgow_ReadCodeAggregates[order(-Glasgow_ReadCodeAggregates$recordCount),]
DaSH_ReadCodeAggregates <- DaSH_ReadCodeAggregates[order(-DaSH_ReadCodeAggregates$recordCount),]

t <- c(HIC_ReadCodeAggregates[1:100,"code"],Glasgow_ReadCodeAggregates[1:100,"code"],Lothian_ReadCodeAggregates[1:100,"code"],DaSH_ReadCodeAggregates[1:100,"code"])
t <- unique(t)
t <- t[!t==""]    #180 codes

selectedCodes <- t
save(selectedCodes, file = "./data/selectedCodes.RData")

x <- list(
  HIC=HIC_ReadCodeAggregates[HIC_ReadCodeAggregates[,"code"] %in% t,"code"],  # 135
  Glasgow=Glasgow_ReadCodeAggregates[Glasgow_ReadCodeAggregates[,"code"] %in% t,"code"],  #128
  Lothian=Lothian_ReadCodeAggregates[Lothian_ReadCodeAggregates[,"code"] %in% t,"code"],  #121
  DaSH=DaSH_ReadCodeAggregates[DaSH_ReadCodeAggregates[,"code"] %in% t,"code"]   #126
)

ggvenn(x,
       fill_color =c("#0073C2FF","#EFC000FF","#868686FF","#9900FF"),
       stroke_size = 0.5, set_name_size = 4)

sum(HIC_ReadCodeAggregates[HIC_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(HIC_ReadCodeAggregates[,"recordCount"])  #0.989
sum(Glasgow_ReadCodeAggregates[Glasgow_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(Glasgow_ReadCodeAggregates[,"recordCount"])  #0.974
sum(Lothian_ReadCodeAggregates[Lothian_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(Lothian_ReadCodeAggregates[,"recordCount"])  #0.985
sum(DaSH_ReadCodeAggregates[DaSH_ReadCodeAggregates[,"code"] %in% t,"recordCount"])/sum(DaSH_ReadCodeAggregates[,"recordCount"])  #0.995
