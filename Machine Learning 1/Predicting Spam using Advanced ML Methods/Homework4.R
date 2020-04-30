#HW4
if(!require("tree")) { install.packages("tree"); require("tree") }
if(!require("ISLR")) { install.packages("ISLR"); require("ISLR") }
if(!require("rgl")) { install.packages("rgl"); require("rgl") }
#-----------ROC Graph Function

ROCPlot <- function(Pvec,Cvec,Plot=T,Add=F) {
  NHam <- sum(Cvec==0)
  NSpam <- sum(Cvec==1)
  PvecS <- unique(sort(Pvec))
  x <- rep(NA,length(PvecS))
  y <- rep(NA,length(PvecS))
  for(i in 1:length(PvecS)) {
    x[i] <- sum(Pvec>=PvecS[i]&Cvec==0)/NHam
    y[i] <- sum(Pvec>=PvecS[i]&Cvec==1)/NSpam
  }
  x <- c(0,x,1)
  y <- c(0,y,1)
  ord <- order(x)
  x <- x[ord]
  y <- y[ord]
  
  AUC <- sum((x[2:length(x)]-x[1:(length(x)-1)])*(y[2:length(y)]+y[1:(length(y)-1)])/2)
  
  if(Add) {
    plot(x,y,type="l",xlim=c(0,1),ylim=c(0,1),xlab="P( classified + | Is - )",ylab="P( classified + | Is + )")
    title(paste("ROC Curve\nAUC = ",round(AUC,3)))
    abline(0,1)
    par(pty="m")
  } else {
    if(Plot) {
      par(pty="s")
      plot(x,y,type="l",xlim=c(0,1),ylim=c(0,1),xlab="P( classified + | Is - )",ylab="P( classified + | Is + )")
      title(paste("ROC Curve\nAUC = ",round(AUC,3)))
      abline(0,1)
      par(pty="m")
    }
  }
  invisible(list(x=c(0,x,1),y=c(0,y,1),AUC=AUC))
}
#Data Prep---------------
DataOrig <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW4/spambasedata-Orig.csv",sep=",",header=T, stringsAsFactors=F)
load(file="C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW4/SpamdataPermutation.RData")
DataOrig <- DataOrig[ord,]

# Doing a 60-40 split
TrainInd <- ceiling(nrow(DataOrig)*0.6)
TrainData <- DataOrig[1:TrainInd,]
ValData <- DataOrig[(TrainInd+1):nrow(DataOrig),]

# Question 1

SmallFm <- IsSpam ~ 1
Vars <- names(TrainData)
BigFm <- paste(Vars[58],"~",paste(Vars[1:57],collapse=" + "),sep=" ")
BigFm <- formula(BigFm)


#------------------Stepwise
OutSmall <- glm(SmallFm,family=binomial(link = "logit"),data=TrainData)
OutBig <- glm(BigFm,family=binomial(link = "logit"),data=TrainData)

#DataComp <- Data[complete.cases(Data),]
#OutBig <- lm(BigFm,data=DataComp)
#OutSmall <- lm(SmallFm,data=DataComp)
summary(OutSmall)
summary(OutBig)

sc <- list(lower=SmallFm,upper=BigFm) 
out <- step(OutSmall,scope=sc,direction="both") #stepwise
summary(out)
AIC(out)

out2 <- predict(out, type="response", newdata = ValData)
#as.numeric(names(out2))
Probabilities <- as.numeric(out2)
# Pvec if the vector of probabilities predicted by your model
# Cvec is the vector of 0's and 1's indicating the realized
# classifications of each observation.
ROC1 <- ROCPlot(Pvec=Probabilities, Cvec = ValData$IsSpam)
AUC1 <- ROC1$AUC
AUC1

#Question 2----------------------------------------------------
TrainData$IsSpam <- factor(TrainData$IsSpam)
ValData$IsSpam <- factor(ValData$IsSpam)

tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0)
OutBig2 <- tree(BigFm,data=TrainData, method="deviance",control=tc)
NNodes2 <- summary(OutBig2)$size
NNodes2
# Find the best tree size
AUC.tree <- rep(NA,NNodes2)
for(NNodes2 in 3:NNodes2) {
  out1 <- prune.tree(OutBig2,best=NNodes2)
  ypred <- predict(out1,newdata=ValData, type="vector")
  Probabilities2a <- ypred[,2]
  AUC.tree[NNodes2] <- ROCPlot(Pvec=Probabilities2a, Cvec = ValData$IsSpam)$AUC
}

plot(AUC.tree,type="l",xlab = "Number of Nodes",ylab="AUC")
title(paste(paste("AUC vs # of Nodes\nBest AUC = ",round(AUC.tree[BestN],3)),paste("\nBest # of Nodes = ",BestN)))
BestN <- which.max(AUC.tree)
abline(v=BestN)
max(AUC.tree,na.rm=T)
AUC.tree[BestN]

out1 <- prune.tree(OutBig2,best=BestN)
out2 <- predict(out1,newdata = ValData, type="vector")
Probabilities2 <- out2[,2]
ROC2 <- ROCPlot(Pvec=Probabilities2, Cvec = ValData$IsSpam)
AUC2 <- ROC2$AUC
AUC2

#Question 3------------------------------------
if(!require("randomForest")) { install.packages("randomForest"); require("randomForest") }
# When mtry = #of x's, randomForest is the same as bagging.

OutSmall3 <- randomForest(SmallFm, data=TrainData, ntree=500, mtry=57)
OutBig3 <- randomForest(BigFm, data=TrainData, ntree=500, mtry=57)
summary(OutSmall3)
summary(OutBig3)

#sc <- list(lower=SmallFm,upper=BigFm) 
#out <- step(OutSmall2,scope=sc,direction="both") #stepwise
#summary(out)
#AIC(out)

out3 <- predict(OutBig3,newdata=ValData, type="prob")
Probabilities3 <- out3[,2]
ROC3 <- ROCPlot(Pvec=Probabilities3, Cvec = ValData$IsSpam)
AUC3 <- ROC3$AUC
AUC3

#Question 4----------------------------------
if(!require("randomForest")) { install.packages("randomForest"); require("randomForest") }

OutSmall4 <- randomForest(SmallFm, data=TrainData, ntree=500)
OutBig4 <- randomForest(BigFm, data=TrainData, ntree=500)
summary(OutSmall4)
summary(OutBig4)

#sc <- list(lower=SmallFm,upper=BigFm) 
#out <- step(OutSmall2,scope=sc,direction="both") #stepwise
#summary(out)
#AIC(out)

ypred <- predict(out2,newdata=NewDF)
ypred <- matrix(ypred,nrow=n)

out4 <- predict(OutBig4,newdata=ValData, type="prob")
Probabilities4 <- out4[,2]
ROC4 <- ROCPlot(Pvec=Probabilities4, Cvec = ValData$IsSpam)
AUC4 <- ROC4$AUC
AUC4
