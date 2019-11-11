library(Metrics)
library(ggplot2)
library(e1071) 
library(psych)

# knn regression ----------------------------------------------------------------
# install libraries rgl and ISLR if not already installed
if(!require("ISLR")) { install.packages("ISLR"); require("ISLR") }
if(!require("rgl")) { install.packages("rgl"); require("rgl") }
if(!require("FNN")) { install.packages("FNN"); require("FNN") }

AllData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW1/GradedHW1-All-Data.csv",header=T,sep=",",
                      stringsAsFactors = F,na.strings="")

TestData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW1/GradedHW1-Test-Data.csv",header=T,sep=",",
                      stringsAsFactors = F,na.strings="")

TrainData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW1/GradedHW1-Train-Data.csv",header=T,sep=",",
                      stringsAsFactors = F,na.strings="")

ValData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW1/GradedHW1-Validation-Data.csv",header=T,sep=",",
                      stringsAsFactors = F,na.strings="")

AllData$Building.Age <- 2010 - AllData$Year.Built
TestData$Building.Age <- 2010 - TestData$Year.Built
TrainData$Building.Age <- 2010 - TrainData$Year.Built
ValData$Building.Age <- 2010 - ValData$Year.Built

AllData <- AllData[AllData$Bldg.Type=="1Fam",]
TestData <- TestData[TestData$Bldg.Type=="1Fam",]
TrainData <- TrainData[TrainData$Bldg.Type=="1Fam",]
ValData <- ValData[ValData$Bldg.Type=="1Fam",]

RelevantVars <- c("SalePrice", "Lot.Area", "Total.Bsmt.SF", "Gr.Liv.Area", "Full.Bath", "Bedroom.AbvGr", "Building.Age")
AllData <- AllData[RelevantVars]
TestData <- TestData[RelevantVars]
TrainData <- TrainData[RelevantVars]
ValData <- ValData[RelevantVars]

AllData <- na.omit(AllData)
TestData <- na.omit(TestData)
TrainData <- na.omit(TrainData)
ValData <- na.omit(ValData)

TrainSP <- TrainData$SalePrice
ValSP <- ValData$SalePrice
TestSP <- TestData$SalePrice

ValX = subset(ValData, select = -SalePrice)
TrainX = subset(TrainData, select = -SalePrice)
TestX = subset(TestData, select = -SalePrice)

#-------------------------------
#results table
ResultTable <- data.frame(matrix(, nrow=3, ncol=4))
colnames(ResultTable) <- c("Model 1","Model 2","Model 3","Model 4")
rownames(ResultTable) <- c("Best k","Raw RMSE","Log(RMSE)")
ResultTable[is.na(ResultTable)] <- ""
#----------------------------
#sum(is.na(AllData$Lot.Area))
#sum(is.na(AllData$Total.Bsmt.SF))
#sum(is.na(TestData$Total.Bsmt.SF))
#sum(is.na(TrainData$Total.Bsmt.SF))
#sum(is.na(ValData$Total.Bsmt.SF))

#sum(is.na(AllData$Gr.Liv.Area))
#sum(is.na(AllData$Full.Bath))
#sum(is.na(AllData$Bedroom.AbvGr))
#sum(is.na(AllData$Building.Age))

#-------------------3--------------------
k <- c(1:40)
results=list()
for (i in k){
  result <- knn.reg(train=TrainX,test=ValX,y=TrainSP,k=i)
  ypred <-matrix(result$pred)
  rmse <- rmse(ValSP, ypred)
  results[i] <- rmse 
}

table <- do.call(rbind.data.frame, Map('c', k, results))
names(table) <- c("k","rmse")
origbest_k <- table[which.min(table$rmse),1]
origbestvalrmse <- table[which.min(table$rmse),2]
ResultTable[1,1] <- origbest_k
ggplot(table, aes(x=k, y=rmse)) + geom_point() + ggtitle("RMSE vs k [Model 1]","No Standardization, No Transformation")
#-------------------4--------------------
bestknn <- knn.reg(train=TrainX,test=TestX,y=TrainSP,k=origbest_k)
ypred <-matrix(bestknn$pred)
origbestkrmse <- rmse(TestSP, ypred)
ResultTable[2,1] <- origbestkrmse
ResultTable[3,1] <- rmse(log(TestSP), log(ypred))

#-------------------5--Scaling---------------
ScaledTrainX <- as.data.frame(scale(TrainX, center = TRUE, scale = TRUE))
#ScaledValX <- as.data.frame(scale(ValX, center = TRUE, scale = TRUE))
#ScaledTestX2 <- as.data.frame(scale(TestX, center = TRUE, scale = TRUE))

ScaledValX <- data.frame(matrix(, nrow=nrow(ValX), ncol=ncol(ValX)))
colnames(ScaledValX) <- colnames(ValX)
ScaledValX[is.na(ScaledValX)] <- ""
for (i in c(1:ncol(ValX))){
  ScaledValX[,i] <- (ValX[,i]-mean(TrainX[,i]))/sd(TrainX[,i])
}

ScaledTestX <- data.frame(matrix(, nrow=nrow(TestX), ncol=ncol(TestX)))
colnames(ScaledTestX) <- colnames(TestX)
ScaledTestX[is.na(ScaledTestX)] <- ""
for (i in c(1:ncol(TestX))){
  ScaledTestX[,i] <- (TestX[,i]-mean(TrainX[,i]))/sd(TrainX[,i])
}
#-----------------------Scaled--------------
for (i in k){
  result <- knn.reg(train=ScaledTrainX,test=ScaledValX,y=TrainSP,k=i)
  ypred <-matrix(result$pred)
  rmse <- rmse(ValSP, ypred)
  results[i] <- rmse 
}

table2 <- do.call(rbind.data.frame, Map('c', k, results))
names(table2) <- c("k","rmse")
scaledbest_k <- table2[which.min(table2$rmse),1]
scalebestvalrmse <- table2[which.min(table2$rmse),2]
ResultTable[1,2] <- scaledbest_k
ggplot(table2, aes(x=k, y=rmse)) + geom_point() + ggtitle("RMSE vs k [Model 2]","Standardized, No Transformation")
#-------------------6--------------------
scaledbestknn <- knn.reg(train=ScaledTrainX,test=ScaledTestX,y=TrainSP,k=scaledbest_k)
ypred <-matrix(scaledbestknn$pred)
scaledbestkrmse <- rmse(TestSP, ypred)
ResultTable[2,2] <- scaledbestkrmse
ResultTable[3,2] <- rmse(log(TestSP), log(ypred))

#-------------------7--------------------
#pairs(AllData)

#many variables suffer from severe heteroskedasticity
#test <- AllData$Bedroom.AbvGr+0.33
#install.packages("standardize")
#library(standardize)
#, nrow=nrow(testXsd))
#-------------------Transform Histograms---------------
#describe((AllData$SalePrice))
#describe((AllData$Lot.Area))
#describe((AllData$Total.Bsmt.SF))
#describe((AllData$Gr.Liv.Area))
#describe((AllData$Full.Bath))
#describe((AllData$Bedroom.AbvGr))
#describe((AllData$Building.Age))

#hist((AllData$SalePrice))
#hist((AllData$Lot.Area))
#hist((AllData$Total.Bsmt.SF))
#hist((AllData$Gr.Liv.Area))
#hist((AllData$Full.Bath))
#hist((AllData$Bedroom.AbvGr))
#hist((AllData$Building.Age))

#---------------Transform Y----------
TranTrainSP <- log(TrainData$SalePrice)
TranValSP <- log(ValData$SalePrice)#(1/2) 0.87sk, (1/3)0.59sk, log()-0.06sk
TranTestSP <- log(TestData$SalePrice) #1.73sk

#-----------------Transform X---------------------------------------
TranTrainX <- TrainX
TranValX <- ValX
TranTestX <- TestX

TranTrainX$Lot.Area <- log(TranTrainX$Lot.Area) #log 45559.52
TranValX$Lot.Area <- log(TranValX$Lot.Area) #(1/2) 4.6sk, (1/3)3.03sk, log(+0)1.16sk
TranTestX$Lot.Area <- log(TranTestX$Lot.Area) #16+ sk

TranTrainX$Total.Bsmt.SF <- TranTrainX$Total.Bsmt.SF^(1/2) 
TranValX$Total.Bsmt.SF <- TranValX$Total.Bsmt.SF^(1/2) #(1/2) -1.1sk, (1/3)-2.77sk, log(+1/3)-5.84sk
TranTestX$Total.Bsmt.SF <- TranTestX$Total.Bsmt.SF^(1/2)#1.5 sk
#cubic, log, 1/3, 2/1

TranTrainX$Gr.Liv.Area <- log(TranTrainX$Gr.Liv.Area) #log 55564.78, (1/2)42114.73
TranValX$Gr.Liv.Area <- log(TranValX$Gr.Liv.Area) #(1/2) 0.54sk, (1/3)0.35sk, log()-0.02sk
TranTestX$Gr.Liv.Area <- log(TranTestX$Gr.Liv.Area) #1.25sk

TranTrainX$Full.Bath <- TranTrainX$Full.Bath #log 40676.54, none 40568.79
TranValX$Full.Bath <- TranValX$Full.Bath #(1/2) -0.23sk, (1/3)-1sk, log(+1/3)-0.33sk
TranTestX$Full.Bath <- TranTestX$Full.Bath #0.23sk

TranTrainX$Bedroom.AbvGr <- TranTrainX$Bedroom.AbvGr #no change
TranValX$Bedroom.AbvGr <- TranValX$Bedroom.AbvGr #(1/2) -1.19sk, (1/3)-2.48sk, log(+1/3)-1.99sk
TranTestX$Bedroom.AbvGr <- TranTestX$Bedroom.AbvGr #-0.11sk

TranTrainX$Building.Age <- TranTrainX$Building.Age^(1/2) #no change
TranValX$Building.Age <- TranValX$Building.Age^(1/2) #(1/2) -0.1sk, (1/3)-0.32sk, log(+1/3)-0.73sk
TranTestX$Building.Age <- TranTestX$Building.Age^(1/2) #0.49sk

#------------Transformed knn---------------
for (i in k){
  result <- knn.reg(train=TranTrainX,test=TranValX,y=TranTrainSP,k=i) #y=TranTrainSP
  ypred <-matrix(result$pred)
  #ypred <- ypred^3 or exp(ypred)
  rmse <- rmse(TranValSP, ypred) #ValSP
  results[i] <- rmse 
}

table3 <- do.call(rbind.data.frame, Map('c', k, results))
names(table3) <- c("k","rmse")
tranbest_k <- table3[which.min(table3$rmse),1]
tranbestvalrmse <- table3[which.min(table3$rmse),2]
ResultTable[1,3] <- tranbest_k
ggplot(table3, aes(x=k, y=rmse)) + geom_point() + ggtitle("RMSE vs k [Model 3]","No Standardization, Transformed")

#------------8:  Best Trans knn---------------
tranbestknn <- knn.reg(train=TranTrainX,test=TranTestX,y=TranTrainSP,k=tranbest_k) #TranTrainSP
ypred <-matrix(tranbestknn$pred)
#ypred <- ypred^3 or exp(ypred)
tranbestkrmse <- rmse(TranTestSP, ypred) #TestSP
ResultTable[2,3] <- rmse(exp(TranTestSP), exp(ypred))
ResultTable[3,3] <- tranbestkrmse

#------Model 4------Standardize x------------------------------------
ScaleTranTrainX <- as.data.frame(scale(TranTrainX, center = TRUE, scale = TRUE))

ScaleTranValX <- data.frame(matrix(, nrow=nrow(TranValX), ncol=ncol(TranValX)))
colnames(ScaleTranValX) <- colnames(TranValX)
ScaleTranValX[is.na(ScaleTranValX)] <- ""
for (i in c(1:ncol(TranValX))){
  ScaleTranValX[,i] <- (TranValX[,i]-mean(TranTrainX[,i]))/sd(TranTrainX[,i])
}

ScaleTranTestX <- data.frame(matrix(, nrow=nrow(TranTestX), ncol=ncol(TranTestX)))
colnames(ScaleTranTestX) <- colnames(TranTestX)
ScaleTranTestX[is.na(ScaleTranTestX)] <- ""
for (i in c(1:ncol(TranTestX))){
  ScaleTranTestX[,i] <- (TranTestX[,i]-mean(TranTrainX[,i]))/sd(TranTrainX[,i])
}

#------------Transformed knn----------------------------------
for (i in k){
  result <- knn.reg(train=ScaleTranTrainX,test=ScaleTranValX,y=TranTrainSP,k=i) #y=TranTrainSP
  ypred <-matrix(result$pred)
  #ypred <- ypred^3 or exp(ypred)
  rmse <- rmse(TranValSP, ypred) #ValSP
  results[i] <- rmse 
}

table4 <- do.call(rbind.data.frame, Map('c', k, results))
names(table4) <- c("k","rmse")
scaletranbest_k <- table4[which.min(table4$rmse),1]
scaletranbestvalrmse <- table4[which.min(table4$rmse),2]
ResultTable[1,4] <- scaletranbest_k
ggplot(table4, aes(x=k, y=rmse)) + geom_point() + ggtitle("RMSE vs k [Model 4]","Standardized, Transformed")

#------------8:  Best Trans knn---------------
scaletranbestknn <- knn.reg(train=ScaleTranTrainX,test=ScaleTranTestX,y=TranTrainSP,k=scaletranbest_k) #TranTrainSP
ypred <-matrix(scaletranbestknn$pred)
#ypred <- exp(ypred)
scaletranbestkrmse <- rmse(TranTestSP, ypred) #TestSP
ResultTable[2,4] <- rmse(exp(TranTestSP), exp(ypred))
ResultTable[3,4] <- scaletranbestkrmse
