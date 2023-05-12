# This's the function file
#p value function
p_value_calculate_kruskal <- function(D) {
  if (dim(D)[1]!=0 & length(unique(D$From))>1 & length(unique(D$t))>1){
  t <- kruskal.test(D$t ~ D$From, data = D)
  if (t[["p.value"]]<0.05) {
    return("< 0.05") 
  } else {
    return(round(t[["p.value"]],3))
  }} else {
    return("NA")
  }
}


#p value function
p_value_calculate_mann <- function(D) {
  if (dim(D)[1]!=0 & length(unique(D$From))>1 & length(unique(D$t))>1){
    t <- wilcox.test(D$t ~ D$From, data = D)
    if (t[["p.value"]]<0.05) {
      return("< 0.05") 
    } else {
      return(round(t[["p.value"]],3))
    }} else {
      return("NA")
    }
}

#band weith function
bandwidthfunction <- function(t) {
  if (sum(abs(round(t)-t))/length(t)<0.1){
      return(10) 
    } else if (sum(abs(round(t,1)-t))/length(t)<0.01) {
      return(1) 
    } else if (sum(abs(round(t,2)-t))/length(t)<0.001){
      return(0.1)
    } else {
      return((max(t)-min(t))/50)
    }
}

#outlier cut function
outlierCutFunction <- function(data) {
  t <- data$valueQuantity
  t <- t[!is.na(t)]
  #outlier cut
  Q <- quantile(as.double(t), probs=c(.25, .75), na.rm = TRUE)
  iqr <- IQR(as.double(t), na.rm = TRUE)
  up <- Q[2]+5*iqr   # Upper Range
  low <- Q[1]-5*iqr   # Lower Range
  if (length(t)!=0&iqr!=0) {
    data <- data[as.double(data$valueQuantity) > low & as.double(data$valueQuantity) < up,]
  }
  return(data)
}

#unit transfer function
unitTransferFunction <- function(data,unitinfor) {
  if (is.na(unitinfor$Rule)==TRUE) {
    data[data$code==rc,"valueUnit"] <- unitinfor$Unit
    
  } else {
    data <- data[!is.na(data$valueUnit),]        #remove na
    data <- data[!is.na(data$valueQuantity),]    #remove na
    rules <- strsplit(as.character(unitinfor$Rule),";")
    for (rulenumber in 1:length(rules[[1]])) {
      r=rules[[1]][rulenumber] 
      r_u <- lapply(strsplit(as.character(r)," "),function(x) x[pmax(0,which(x=="value")-1)])
      r_r <- lapply(strsplit(as.character(r)," "),function(x) x[pmax(0,which(x=="value")+1)])
      if (dim(na.omit(data[data$code==rc & data$valueUnit==r_u,]))[1]>0) { 
        data[data$code==rc & data$valueUnit==r_u,"valueQuantity"] <- as.double(r_r)*data[data$code==rc & data$valueUnit==r_u,"valueQuantity"] 
      }
    }
    if (dim(data[data$code==rc,])[1]>0)
      data[data$code==rc,"valueUnit"] <- unitinfor$Unit
  }
  return(data)
}


# censored value function
CensoredValueFunction <- function(data) {
  t <- data
  t[grepl(">", t$valueString, ignore.case = TRUE),"valueQuantity"] <- t[grepl(">", t$valueString, ignore.case = TRUE),"valueQuantity"]*2
  t[grepl("<", t$valueString, ignore.case = TRUE),"valueQuantity"] <- t[grepl("<", t$valueString, ignore.case = TRUE),"valueQuantity"]/2
  return(t)
}


