
library(Metrics)
library(ggplot2)
library(e1071) 
library(psych)
library(randomForest)

# knn regression ----------------------------------------------------------------
# install libraries rgl and ISLR if not already installed
if(!require("tree")) { install.packages("tree"); require("tree") }
if(!require("ISLR")) { install.packages("ISLR"); require("ISLR") }
if(!require("rgl")) { install.packages("rgl"); require("rgl") }
if(!require("FNN")) { install.packages("FNN"); require("FNN") }

rm(list = ls(all = TRUE))

TestData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW3/GradedHW1-Test-Data.csv",header=T,sep=",",
                       stringsAsFactors = F,na.strings="")

TrainData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW3/GradedHW1-Train-Data.csv",header=T,sep=",",
                        stringsAsFactors = F,na.strings="")

ValData <- read.table("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW3/GradedHW1-Validation-Data.csv",header=T,sep=",",
                      stringsAsFactors = F,na.strings="")

TestData$Building.Age <- 2010 - TestData$Year.Built
TrainData$Building.Age <- 2010 - TrainData$Year.Built
ValData$Building.Age <- 2010 - ValData$Year.Built


#All Our Data should only be 1 fam but let's make sure
TestData <- TestData[TestData$Bldg.Type=="1Fam",]
TrainData <- TrainData[TrainData$Bldg.Type=="1Fam",]
ValData <- ValData[ValData$Bldg.Type=="1Fam",]

RelevantVars <- c("SalePrice", "Lot.Area", "Total.Bsmt.SF", "Gr.Liv.Area", "Full.Bath", "Bedroom.AbvGr", "Building.Age")
TestData <- TestData[RelevantVars]
TrainData <- TrainData[RelevantVars]
ValData <- ValData[RelevantVars]

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
ResultTable <- data.frame(matrix(, nrow=2, ncol=10))
colnames(ResultTable) <- c("BestKval","k=25val","k=50val","k=45train","k=45val","k=45test")
rownames(ResultTable) <- c("Best k","Raw RMSE")
ResultTable[is.na(ResultTable)] <- ""
#Question 1---------------------------------------------
# Note: minsize is the smallest size node to consider splitting
# mincut is the smallest node size allowed in any split that is made.
# mincut determines the minimum number of observations in a node - minsize does not.
# mindev is a fraction (like 1%). Nodes with a deviance less that this fraction
# of the original deviance will not be considered for splitting.

k <- c(20:60)
results=list()
for (i in k){
  tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0.00)
  out <- tree(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, control=tc)
  out1 <- prune.tree(out, best=i)
  Yhat <- predict(out1,newdata=ValData)
  rmse <- rmse(ValSP, Yhat)
  results[i] <- rmse 
}

table <- as.data.frame(as.numeric(unlist(results)))
table$k <- k
names(table) <- c("rmse","k")
origbest_k <- table[which.min(table$rmse),2]
origbestvalrmse <- table[which.min(table$rmse),1]
ResultTable[1,1] <- origbest_k
ResultTable[2,1] <- origbestvalrmse
ggplot(table, aes(x=k, y=rmse)) + geom_point() + ggtitle("RMSE vs k [Model 1]")


NNodes <- 25 #, control=tc)
tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0.00)
out <- tree(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, control=tc)
out1 <- prune.tree(out, best=NNodes)
Yhat <- predict(out1,newdata=ValData)
rmse <- rmse(ValSP, Yhat)
ResultTable[1,2] <- 25
ResultTable[2,2] <- rmse

NNodes <- 50 #, control=tc)
tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0.00)
out <- tree(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, control=tc)
out1 <- prune.tree(out, best=NNodes)
Yhat <- predict(out1,newdata=ValData)
rmse <- rmse(ValSP, Yhat)
ResultTable[1,3] <- 50
ResultTable[2,3] <- rmse

NNodes <- 45 #, control=tc)
tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0.00)
out <- tree(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, control=tc)
out1 <- prune.tree(out, best=NNodes)
Yhat <- predict(out1,newdata=TrainData)
rmse <- rmse(TrainSP, Yhat)
ResultTable[1,4] <- 45
ResultTable[2,4] <- rmse

NNodes <- 45 #, control=tc)
tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0.00)
out <- tree(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, control=tc)
out1 <- prune.tree(out, best=NNodes)
Yhat <- predict(out1,newdata=ValData)
rmse <- rmse(ValSP, Yhat)
ResultTable[1,5] <- 45
ResultTable[2,5] <- rmse

NNodes <- 45 #, control=tc)
tc <- tree.control(nrow(TrainData),minsize=2,mincut=1,mindev=0.00)
out <- tree(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, control=tc)
out1 <- prune.tree(out, best=NNodes)
Yhat <- predict(out1,newdata=TestData)
rmse <- rmse(TestSP, Yhat)
ResultTable[1,6] <- 45
ResultTable[2,6] <- rmse


k <- c(20:60)
results1=list()
for (i in k){
  out <- randomForest(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData, maxnodes=i)
  Yhat <- predict(out,newdata=TestData)
  rmse <- rmse(TestSP, Yhat)
  results1[i] <- rmse 
}

table2 <- as.data.frame(as.numeric(unlist(results1)))
table2$k <- k
names(table) <- c("rmse","k")
origbest_k <- table[which.min(table$rmse),2]
origbestvalrmse <- table[which.min(table$rmse),1]


out <- randomForest(SalePrice ~ Lot.Area + Total.Bsmt.SF + Gr.Liv.Area + Full.Bath + Bedroom.AbvGr + Building.Age, data=TrainData)
Yhat <- predict(out,newdata=TestData)
rmse <- rmse(TestSP, Yhat)
ResultTable[1,7] <- 45
ResultTable[2,7] <- rmse


