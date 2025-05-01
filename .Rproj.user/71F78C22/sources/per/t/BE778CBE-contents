# 30/11/2021
install.packages("graphics")
install.packages("Matrix")
install.packages("glmnet")
install.packages("pROC")
install.packages("caret")
install.packages("e1071")
install.packages("AUC")
install.packages("cutpointr")
install.packages("aod")
install.packages("survival")
install.packages("survminer")
install.packages("dplyr")

library(survival)
library(survminer)
library(dplyr)
library(aod)
library(AUC)
library(Matrix)
library(glmnet)
library(pROC)
library(caret)
library(e1071)
library(graphics)
library(cutpointr)
# 18/02/2022
####################################################
#### update BaselineCohort Final Diagnosis##########
####################################################
#####################################################
BaselineCohort <- rbind(NApatientAgree[,c(1,2,3,9,11,13,15)],PairedWithInTimeSelected[,c(1,2,3,9,11,13,12)])
BaselineCohort <- merge(BaselineCohort,final_check[,c("PROCHI","LVEF")],by="PROCHI", all.x=TRUE)
BaselineCohort$FinalDiagnosis <- as.character(BaselineCohort$FinalDiagnosis)
for (i in 1:dim(final_check)[1]) {
  p <- as.character(final_check[i,"PROCHI"]) 
  BaselineCohort[BaselineCohort$PROCHI==p,"FinalDiagnosis"] <- as.character(final_check[i,"ClinicalDiagnosis"]) 
}
BaselineCohort$FinalDiagnosis <- as.factor(BaselineCohort$FinalDiagnosis)
colnames(BaselineCohort)[8] <- "LVEFDiagnosis"
#####################################################
##################### demograph  ####################
#####################################################
BaselineCohort<- merge(Demography[,c(1,3,5,7)], BaselineCohort, by = c("PROCHI"))
BaselineCohort[BaselineCohort$FinalDiagnosis=="HFmrEF","FinalDiagnosis"] <- "HFrEF"

#####################################################
##################### table 1.3  ####################
#####################################################
# Biomarker BarcodetoProchi mapping
BiomarkerWithProchi <- merge(Biomarker, BarcodetoProchi, by.x=c("Barcode.ID"), by.y = ("Barcode"))
BiomarkerWithProchi_Selected <- subset(BiomarkerWithProchi, select=c(9,11,13,16))
BaselineCohort <- merge(BaselineCohort, BiomarkerWithProchi_Selected, by = c("PROCHI"), all.x = TRUE)
# RocheBiomarker BarcodetoProchi mapping
RocheBiomarkerWithProchi <- merge(RocheBiomarker, BarcodetoProchi, by.x=c("Barcode.ID"), by.y = ("Barcode"))
RocheBiomarkerWithProchi_Selected <- subset(RocheBiomarkerWithProchi, select=c(16,8:13))
BaselineCohort <- merge(BaselineCohort, RocheBiomarkerWithProchi_Selected, by = c("PROCHI"), all.x = TRUE)
# Bimarker Summary
n <- c("Control", "HFrEF", "HFpEF")
CM <- c(colnames(Biomarker)[c(9,11,13)],colnames(RocheBiomarker)[c(8:13)])
TableResult <- data.frame(CM)
colnames(TableResult)[1] <- "Biomarker"
TableResult$Control_186 <- 0
TableResult$HFrEF_156 <- 0
TableResult$HFpEF_236 <- 0
for (i in 1:3) {
  t <- subset(BaselineCohort, BaselineCohort$FinalDiagnosis == n[i])
  for (j in 1:length(CM)){
    q <- quantile(as.double(as.character(t[,CM[j]])), probs = c(.25,.5,.75), na.rm = TRUE)
    c <- dim(t)[1]
    TableResult[j,i+1] <- paste0(round(q[2],1)," [",round(q[1],1),"-",round(q[3],1),"], ")
    #TableResult[j,i+1] <- paste0(round(q[2],1)," [", round(sd(as.double(as.character(t[,CM[j]]))),1),"], ")
  }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/06032025table1.3.csv")
# Bimarker Wilcoxcon test
CM <- c(colnames(Biomarker)[c(9,11,13)],colnames(RocheBiomarker)[c(8:13)])
TableResult <- data.frame(CM)
colnames(TableResult)[1] <- "Biomarker"
TableResult$ControlvsHFrEF <- 0
TableResult$ControlvsHFpEF <- 0
TableResult$HFrEFvsHFpEF <- 0
  ControlData <- subset(BaselineCohort, BaselineCohort$FinalDiagnosis == "Control")
  HFrEFData <- subset(BaselineCohort, BaselineCohort$FinalDiagnosis == "HFrEF")
  HFpEFData <- subset(BaselineCohort, BaselineCohort$FinalDiagnosis == "HFpEF")
  for (j in 1:length(CM)){
    con <- as.double(as.character(ControlData[,CM[j]]))
    rEF <- as.double(as.character(HFrEFData[,CM[j]]))
    pEF <- as.double(as.character(HFpEFData[,CM[j]]))
    p <- wilcox.test(con,rEF)$p.value
    if ( p< 0.001) {
    TableResult[j,"ControlvsHFrEF"] <- "<0.001"
    } else {TableResult[j,"ControlvsHFrEF"] <- round(p,3)}
    
    p <- wilcox.test(con,pEF)$p.value
      if (p < 0.001) {
        TableResult[j,"ControlvsHFpEF"] <- "<0.001"
      } else {TableResult[j,"ControlvsHFpEF"] <- round(p,3)}
    
    p <- wilcox.test(pEF,rEF)$p.value
    if (p < 0.001) {
      TableResult[j,"HFrEFvsHFpEF"] <- "<0.001"
    } else {TableResult[j,"HFrEFvsHFpEF"] <- round(p,3)}
  }
write.csv(TableResult, "D:/Project-3634/R/EKOAI/06032025table1.3p.csv")
#####################################################
##################### table 1.4  ####################
#####################################################
# Bimarker Summary
n <- c("HFrEF", "HFpEF", "Control")
CM <- c(colnames(Biomarker)[c(9,11,13)],colnames(RocheBiomarker)[c(8:13)])
TableResult <- data.frame(CM)
colnames(TableResult)[1] <- "Biomarker"
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
for (i in 1:3) {
  data1 = BaselineCohort[BaselineCohort$FinalDiagnosis!=n[i],c("FinalDiagnosis",CM)]
  if (i<3){
    data1$FinalDiagnosis<-ifelse(data1$FinalDiagnosis=='Control', 0,1)  
  } else {
    data1$FinalDiagnosis<-ifelse(data1$FinalDiagnosis=='HFrEF', 0,1)
  }
  
  # data cleaning
  for (j in 2:dim(data1)[2]) {
    d <- data1[,j]
    if (is.numeric(d)==FALSE) {
      print(j)
      print(colnames(data1)[j])
      data1[,j]<- as.numeric(as.character(data1[,j]))
    }
  }
  
  # prepare the data
  Data <- data1
  l <- dim(Data)[2]

  
  # ROC plot
 
  for (j in 2:l){
    # prepare the data
    d <- Data[,c(1,j)]
    d_full <- BaselineCohort[,c(colnames(d)[2])]
    Q <- quantile(d_full, probs = c(.25, .75),na.rm = TRUE)
    iqr <- IQR(d_full, na.rm=TRUE)
    up <- Q[2]+10*iqr
    low <- Q[1]-10*iqr
    elimated <- subset(d, d[,2]>low & d[,2]<up)
    
    elimated$logValue <- log10(elimated[,2])
    Diagnose <- elimated[,1]
    p <- as.double(as.character(elimated[,3]))
    
    ROC_curve <- pROC::roc(factor(Diagnose),p)
    A <- round(pROC::auc(ROC_curve),2)
    CI <- ci.auc(ROC_curve)
    cp <- cutpointr(elimated[,3],elimated$FinalDiagnosis,method = maximize_metric, metric = youden, na.rm = TRUE)
    ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv","specificity","sensitivity"))
    cp_optimal=round(10^cp$optimal_cutpoint,2)
    TableResult[j-1,i+1] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",cp_optimal,"; ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
    #TableResult[j-1,i+1] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",cp_optimal,"; ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2),"; ",round(ppvnpv$specificity,2),"; ",round(ppvnpv$sensitivity,2))
  }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/06032025table1.4withspecandsens.csv")


#####################################################
##################### table 1.5  ####################
#####################################################

# Spilt data  #######
n <- c("HFrEF", "HFpEF", "Control")
for (i in 1:3) {
  data1 = BaselineCohort[BaselineCohort$FinalDiagnosis!=n[i],]
  if (i<3){
    data1$FinalDiagnosis<-ifelse(data1$FinalDiagnosis=='Control', 0,1)  
  } else {
    data1$FinalDiagnosis<-ifelse(data1$FinalDiagnosis=='HFrEF', 0,1)
  }
  
  # data cleaning
  for (j in 2:dim(data1)[2]) {
    d <- data1[,j]
    if (is.numeric(d)==FALSE) {
      print(j)
      print(colnames(data1)[j])
      data1[,j]<- as.numeric(as.character(data1[,j]))
    }
  }
  

  # Split the data to train and test
  split = sample(nrow(data1), floor(0.7*nrow(data1)))
  # Split the data to train and test
  train = data1[split,]
  test = data1[-split,]
  
  # rename
  if (n[i]=="HFrEF"){
    train_ControlHFpEF <- train
    test_ControlHFpEF <- test
  } else if (n[i]=="HFpEF") {
    train_ControlHFrEF <- train
    test_ControlHFrEF <- test
  } else {
    train_HFpEFHFrEF <- train
    test_HFpEFHFrEF <- test
  }
}

# Bimarker Summary

CM <- c(colnames(Biomarker)[c(9,11,13)],colnames(RocheBiomarker)[c(8:13)])
CM_combn <- combn(CM,2)  # all the possible combination of 2 elements from CM
TableResult <- data.frame(1:dim(CM_combn)[2])
colnames(TableResult)[1] <- "NO"
TableResult$Biomarker1 <- CM_combn[1,]
TableResult$Biomarker2 <- CM_combn[2,]
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
TableResult$ControlHFpEFAUC <- 0
TableResult$ControlHFrEFAUC <- 0
TableResult$HFrEFHFpEFAUC <- 0
for (i in 1:3) {
  for (j in 1:dim(CM_combn)[2]) {
  # rename
  if (n[i]=="HFrEF"){
    train <- train_ControlHFpEF[,c("FinalDiagnosis",TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
    test <- test_ControlHFpEF[,c("FinalDiagnosis",TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
  } else if (n[i]=="HFpEF") {
    train <- train_ControlHFrEF[,c("FinalDiagnosis",TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
    test <- test_ControlHFrEF[,c("FinalDiagnosis",TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
  } else {
    train <- train_HFpEFHFrEF[,c("FinalDiagnosis",TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
    test <- test_HFpEFHFrEF[,c("FinalDiagnosis",TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
  }
  colnames(train) <- c("FinalDiagnosis","V1","V2")
  colnames(test) <- c("FinalDiagnosis","V1","V2")
  mylogit <- glm(FinalDiagnosis ~ log10(V1) + log10(V2), data = train, family="binomial")
  test$predict <- predict(mylogit, newdata=test[,c(2,3)],type = "response") 
  ROC_curve <- pROC::roc(factor(test$FinalDiagnosis),test$predict)
  A <- round(pROC::auc(ROC_curve),2)
  CI <- ci.auc(ROC_curve)
  cp <- cutpointr(test$predict,test$FinalDiagnosis,method = maximize_metric, metric = sum_sens_spec, na.rm = TRUE)
  ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv"))
  TableResult[j,i+3] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
  TableResult[j,i+6] <- A
  
  }
  
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/06032025table1.5.csv")



#####################################################
############# table 1.6 and 1.7  ####################
#####################################################

##################### US2AI  ####################
setwd("D:/Project-3634/Dundee (2)")
getwd()
EKOImageData <- read.csv("MeasurementsDundeeJan3-v3.csv")
### 03032023 data update ##########
setwd("D:/Project-3634/USAI-50")
getwd()
EKOImageData_03032023 <- read.csv("Dundee-2023-02-15-v3 - strain.csv")
EKOImageData <- EKOImageData[,!colnames(EKOImageData) %in% colnames(EKOImageData_03032023)[7:10]]
EKOImageData <- merge(EKOImageData, EKOImageData_03032023[,c(1,6:10)], by=c("PatientID","Visit"))
EKOImageData <- EKOImageData[, -which(names(EKOImageData) %in% c("velocity..1001."))]
# add EKOImageData
EKOImageData_Selected <- EKOImageData
#colnames(EKOImageData_Selected)[1] <- "PROCHI"
#EKOImageData_Selected <- merge(EKOImageData_Selected, BaselineCohort[,c("PROCHI","US2AIDate")], by =c("PROCHI") )
EKOImageData_Selected$Time_Diff <- as.Date(as.character(EKOImageData_Selected$ExamDate),format="%Y-%m-%d")-as.Date(as.character(EKOImageData_Selected$US2AIDate),format="%d/%m/%Y")
EKOImageData_Selected <- EKOImageData_Selected[EKOImageData_Selected$Time_Diff==0,]
EKOImageData_Selected <- EKOImageData_Selected[,c(3,7:(dim(EKOImageData_Selected)[2]-1))]
#BaselineCohort <- merge(BaselineCohort, EKOImageData_Selected[,c(3,7:(dim(EKOImageData_Selected)[2]-1))], by = c("PROCHI"), all.x = TRUE)

#07032025
##### merge US2AI with training and testing data ###
train_ControlHFpEF <- merge(train_ControlHFpEF, EKOImageData_Selected, by = c("PROCHI"), all.x = TRUE) 
train_ControlHFrEF <- merge(train_ControlHFrEF, EKOImageData_Selected, by = c("PROCHI"), all.x = TRUE) 
train_HFpEFHFrEF <- merge(train_HFpEFHFrEF, EKOImageData_Selected, by = c("PROCHI"), all.x = TRUE) 
test_ControlHFpEF <- merge(test_ControlHFpEF, EKOImageData_Selected, by = c("PROCHI"), all.x = TRUE) 
test_ControlHFrEF <- merge(test_ControlHFrEF, EKOImageData_Selected, by = c("PROCHI"), all.x = TRUE) 
test_HFpEFHFrEF <- merge(test_HFpEFHFrEF, EKOImageData_Selected, by = c("PROCHI"), all.x = TRUE) 


# table Summary for US2AI only #####
n <- c("HFrEF", "HFpEF", "Control")
rowName <- "US2AI"
TableResult <- data.frame(rowName)
colnames(TableResult)[1] <- "Features"
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
for (i in 1:3) {
  print(i)
  # rename
  if (n[i]=="HFrEF"){
    train <- train_ControlHFpEF[,c("FinalDiagnosis",colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
    test <- test_ControlHFpEF[,c("FinalDiagnosis",colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
  } else if (n[i]=="HFpEF") {
    train <- train_ControlHFrEF[,c("FinalDiagnosis",colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
    test <- test_ControlHFrEF[,c("FinalDiagnosis",colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
  } else {
    train <- train_HFpEFHFrEF[,c("FinalDiagnosis",colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
    test <- test_HFpEFHFrEF[,c("FinalDiagnosis",colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
  }
  train_sparse = makeX(train[,c(2:dim(train)[2])], na.impute = TRUE)
  test_sparse = makeX(test[,c(2:dim(train)[2])], na.impute = TRUE)
  rm
  cv.glmmod = cv.glmnet(x=train_sparse, y=as.factor(train[,1]), alpha=1, family="binomial",type.measure = "auc",keep = TRUE)
  coefs = as.matrix(coef(cv.glmmod)) # convert to a matrix (618 by 1)
  ix = which(abs(coefs[,1]) > 0)
  length(ix)
  SF <- coefs[ix,1, drop=FALSE]
  print(SF)
  #write.table(SF,file = "US2AI and Biomarker Selected Feature.txt")
  test$predict <- predict(cv.glmmod,newx=test_sparse,type='response')[,1]
  ROC_curve <- pROC::roc(factor(test$FinalDiagnosis),test$predict)
  A <- round(pROC::auc(ROC_curve),2)
  CI <- ci.auc(ROC_curve)
  cp <- cutpointr(test$predict,test$FinalDiagnosis,method = maximize_metric, metric = sum_sens_spec, na.rm = TRUE)
  ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv"))
  TableResult[1,i+1] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
  # rename
  if (n[i]=="HFrEF"){
    SF_ControlHFpEF <- SF
  } else if (n[i]=="HFpEF") {
    SF_ControlHFrEF <- SF
  } else {
    SF_HFpEFHFrEF <- SF
  }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/07032025table1.6.0_US2AI.csv")
write.csv(SF_ControlHFpEF, "D:/Project-3634/R/EKOAI/07032025SF_ControlHFpEF_US2AI.csv")
write.csv(SF_ControlHFrEF, "D:/Project-3634/R/EKOAI/07032025SF_ControlHFrEF_US2AI.csv")
write.csv(SF_HFpEFHFrEF, "D:/Project-3634/R/EKOAI/07032025SF_HFpEFHFrEF_US2AI.csv")

#07032025
# table Summary for biomarker only #####
n <- c("HFrEF", "HFpEF", "Control")
rowName <- "Biomarker"
TableResult <- data.frame(rowName)
colnames(TableResult)[1] <- "Features"
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
for (i in 1:3) {
  print(i)
  # rename
  if (n[i]=="HFrEF"){
    train <- train_ControlHFpEF[,c("FinalDiagnosis",CM)]
    test <- test_ControlHFpEF[,c("FinalDiagnosis",CM)]
  } else if (n[i]=="HFpEF") {
    train <- train_ControlHFrEF[,c("FinalDiagnosis",CM)]
    test <- test_ControlHFrEF[,c("FinalDiagnosis",CM)]
  } else {
    train <- train_HFpEFHFrEF[,c("FinalDiagnosis",CM)]
    test <- test_HFpEFHFrEF[,c("FinalDiagnosis",CM)]
  }
  train_sparse = makeX(train[,c(2:dim(train)[2])], na.impute = TRUE)
  test_sparse = makeX(test[,c(2:dim(train)[2])], na.impute = TRUE)
  rm
  cv.glmmod = cv.glmnet(x=train_sparse, y=as.factor(train[,1]), alpha=1, family="binomial",type.measure = "auc",keep = TRUE)
  coefs = as.matrix(coef(cv.glmmod)) # convert to a matrix (618 by 1)
  ix = which(abs(coefs[,1]) > 0)
  length(ix)
  SF <- coefs[ix,1, drop=FALSE]
  print(SF)
  #write.table(SF,file = "US2AI and Biomarker Selected Feature.txt")
  test$predict <- predict(cv.glmmod,newx=test_sparse,type='response')[,1]
  ROC_curve <- pROC::roc(factor(test$FinalDiagnosis),test$predict)
  A <- round(pROC::auc(ROC_curve),2)
  CI <- ci.auc(ROC_curve)
  cp <- cutpointr(test$predict,test$FinalDiagnosis,method = maximize_metric, metric = sum_sens_spec, na.rm = TRUE)
  ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv"))
  TableResult[1,i+1] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
  # rename
  if (n[i]=="HFrEF"){
    SF_ControlHFpEF <- SF
  } else if (n[i]=="HFpEF") {
    SF_ControlHFrEF <- SF
  } else {
    SF_HFpEFHFrEF <- SF
  }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/07032025table1.6.0_biomarker.csv")
write.csv(SF_ControlHFpEF, "D:/Project-3634/R/EKOAI/07032025SF_ControlHFpEF_biomarker.csv")
write.csv(SF_ControlHFrEF, "D:/Project-3634/R/EKOAI/07032025SF_ControlHFrEF_biomarker.csv")
write.csv(SF_HFpEFHFrEF, "D:/Project-3634/R/EKOAI/07032025SF_HFpEFHFrEF_biomarker.csv")

# table Summary for US2AI and Biomarkers #####
n <- c("HFrEF", "HFpEF", "Control")
rowName <- "US2AI&Biomarker"
TableResult <- data.frame(rowName)
colnames(TableResult)[1] <- "Features"
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
for (i in 1:3) {
  print(i)
  # rename
  if (n[i]=="HFrEF"){
    train <- train_ControlHFpEF[,c("FinalDiagnosis",CM, colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
    test <- test_ControlHFpEF[,c("FinalDiagnosis",CM, colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
  } else if (n[i]=="HFpEF") {
    train <- train_ControlHFrEF[,c("FinalDiagnosis",CM, colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
    test <- test_ControlHFrEF[,c("FinalDiagnosis",CM, colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
  } else {
    train <- train_HFpEFHFrEF[,c("FinalDiagnosis",CM, colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
    test <- test_HFpEFHFrEF[,c("FinalDiagnosis",CM, colnames(EKOImageData)[7:dim(EKOImageData)[2]])]
  }
  train_sparse = makeX(train[,c(2:dim(train)[2])], na.impute = TRUE)
  test_sparse = makeX(test[,c(2:dim(train)[2])], na.impute = TRUE)
  rm
  cv.glmmod = cv.glmnet(x=train_sparse, y=as.factor(train[,1]), alpha=1, family="binomial",type.measure = "auc",keep = TRUE)
  coefs = as.matrix(coef(cv.glmmod)) # convert to a matrix (618 by 1)
  ix = which(abs(coefs[,1]) > 0)
  length(ix)
  SF <- coefs[ix,1, drop=FALSE]
  print(SF)
  #write.table(SF,file = "US2AI and Biomarker Selected Feature.txt")
  test$predict <- predict(cv.glmmod,newx=test_sparse,type='response')[,1]
  ROC_curve <- pROC::roc(factor(test$FinalDiagnosis),test$predict)
  A <- round(pROC::auc(ROC_curve),2)
  CI <- ci.auc(ROC_curve)
  cp <- cutpointr(test$predict,test$FinalDiagnosis,method = maximize_metric, metric = sum_sens_spec, na.rm = TRUE)
  ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv"))
  TableResult[1,i+1] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
  # rename
  if (n[i]=="HFrEF"){
    SF_ControlHFpEF <- SF
  } else if (n[i]=="HFpEF") {
    SF_ControlHFrEF <- SF
  } else {
    SF_HFpEFHFrEF <- SF
  }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/07032025table1.6.0_US2AI&Biomarker.csv")
write.csv(SF_ControlHFpEF, "D:/Project-3634/R/EKOAI/07032025SF_ControlHFpEF_US2AI&Biomarker.csv")
write.csv(SF_ControlHFrEF, "D:/Project-3634/R/EKOAI/07032025SF_ControlHFrEF_US2AI&Biomarker.csv")
write.csv(SF_HFpEFHFrEF, "D:/Project-3634/R/EKOAI/07032025SF_HFpEFHFrEF_US2AI&Biomarker.csv")


# table summry for US2AI with one Biomarker  #####
n <- c("HFrEF", "HFpEF", "Control")
CM <- c(colnames(Biomarker)[c(9,11,13)],colnames(RocheBiomarker)[c(8:13)])
rowName <- c(paste0("US2AI + ", CM))
TableResult <- data.frame(rowName)
colnames(TableResult)[1] <- "Features"
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
for (i in 1:3) {
  # rename
  if (n[i]=="HFrEF"){
    SF <- SF_ControlHFpEF
  } else if (n[i]=="HFpEF") {
    SF <- SF_ControlHFrEF
  } else {
    SF <- SF_HFpEFHFrEF
  }

 
  for (j in 1:length(CM)) {
    # rename
    if (n[i]=="HFrEF"){
      train <- train_ControlHFpEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],CM[j])]
      test <- test_ControlHFpEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],CM[j])]
    } else if (n[i]=="HFpEF") {
      train <- train_ControlHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],CM[j])]
      test <- test_ControlHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],CM[j])]
    } else {
      train <- train_HFpEFHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],CM[j])]
      test <- test_HFpEFHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],CM[j])]
    }
    train_sparse = makeX(train[,c(2:dim(train)[2])], na.impute = TRUE)
    train_sparse = data.frame(cbind(train[,1],train_sparse))
    colnames(train_sparse)[1] <- "FinalDiagnosis"
    test_sparse = makeX(test[,c(2:dim(test)[2])], na.impute = TRUE)
    test_sparse = data.frame(cbind(test[,1],test_sparse))
    colnames(test_sparse)[1] <- "FinalDiagnosis"
    train_sparse[,dim(train_sparse)[2]] <- log10(train_sparse[,dim(train_sparse)[2]])
    test_sparse[,dim(test_sparse)[2]] <- log10(test_sparse[,dim(test_sparse)[2]])
    mylogit <- glm(FinalDiagnosis ~ ., data = train_sparse, family="binomial")
    test$predict <- predict(mylogit, newdata=test_sparse[,c(2:dim(test_sparse)[2])],type = "response") 
    ROC_curve <- pROC::roc(factor(test$FinalDiagnosis),test$predict)
    A <- round(pROC::auc(ROC_curve),2)
    CI <- ci.auc(ROC_curve)
    cp <- cutpointr(test$predict,test$FinalDiagnosis,method = maximize_metric, metric = sum_sens_spec, na.rm = TRUE)
    ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv"))
    TableResult[j,i+1] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
  }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/07032025table1.6.csv")

# table summry for US2AI with two Biomarker  #####
n <- c("HFrEF", "HFpEF", "Control")
CM <- c(colnames(Biomarker)[c(9,11,13)],colnames(RocheBiomarker)[c(8:13)])
CM_combn <- combn(CM,2)  # all the possible combination of 2 elements from CM
TableResult <- data.frame(1:(dim(CM_combn)[2]))
colnames(TableResult)[1] <- "NO"
TableResult$Biomarker1 <- c(CM_combn[1,])
TableResult$Biomarker2 <- c(CM_combn[2,])
TableResult$ControlHFpEF <- 0
TableResult$ControlHFrEF <- 0
TableResult$HFrEFHFpEF <- 0
TableResult$ControlHFpEFAUC <- 0
TableResult$ControlHFrEFAUC <- 0
TableResult$HFrEFHFpEFAUC <- 0
for (i in 1:3) {
  # rename
  if (n[i]=="HFrEF"){
    SF <- SF_ControlHFpEF
  } else if (n[i]=="HFpEF") {
    SF <- SF_ControlHFrEF
  } else {
    SF <- SF_HFpEFHFrEF
  }

  for (j in 1:dim(CM_combn)[2]) {
    # rename
    if (n[i]=="HFrEF"){
      train <- train_ControlHFpEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
      test <- test_ControlHFpEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
    } else if (n[i]=="HFpEF") {
      train <- train_ControlHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
      test <- test_ControlHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
    } else {
      train <- train_HFpEFHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
      test <- test_HFpEFHFrEF[,c("FinalDiagnosis",row.names(SF)[2:dim(SF)[1]],TableResult[j,"Biomarker1"],TableResult[j,"Biomarker2"])]
    }
    train_sparse = makeX(train[,c(2:dim(train)[2])], na.impute = TRUE)
    train_sparse = data.frame(cbind(train[,1],train_sparse))
    colnames(train_sparse)[1] <- "FinalDiagnosis"
    test_sparse = makeX(test[,c(2:dim(test)[2])], na.impute = TRUE)
    test_sparse = data.frame(cbind(test[,1],test_sparse))
    colnames(test_sparse)[1] <- "FinalDiagnosis"
    train_sparse[,dim(train_sparse)[2]] <- log10(train_sparse[,dim(train_sparse)[2]])
    test_sparse[,dim(test_sparse)[2]] <- log10(test_sparse[,dim(test_sparse)[2]])
    train_sparse[,dim(train_sparse)[2]-1] <- log10(train_sparse[,dim(train_sparse)[2]-1])
    test_sparse[,dim(test_sparse)[2]-1] <- log10(test_sparse[,dim(test_sparse)[2]-1])
    mylogit <- glm(FinalDiagnosis ~ ., data = train_sparse, family="binomial")
    test$predict <- predict(mylogit, newdata=test_sparse[,c(2:dim(test_sparse)[2])],type = "response") 
    ROC_curve <- pROC::roc(factor(test$FinalDiagnosis),test$predict)
    A <- round(pROC::auc(ROC_curve),4)
    CI <- ci.auc(ROC_curve)
    cp <- cutpointr(test$predict,test$FinalDiagnosis,method = maximize_metric, metric = sum_sens_spec, na.rm = TRUE)
    ppvnpv <- coords(ROC_curve,cp$optimal_cutpoint,"threshold",ret = c("ppv","npv"))
    TableResult[j,i+3] <- paste0(A,"; (",round(CI[1],2),"-",round(CI[3],2),"); ",round(ppvnpv$ppv,2),"; ",round(ppvnpv$npv,2))
    TableResult[j,i+6] <- A
    }
}
write.csv(TableResult, "D:/Project-3634/R/EKOAI/07032025table1.7.csv")


