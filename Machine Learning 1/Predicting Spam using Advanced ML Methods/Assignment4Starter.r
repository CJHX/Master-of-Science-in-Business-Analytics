
DataOrig <- read.table("spambasedata-Orig.csv",sep=",",header=T,
                       stringsAsFactors=F)

load(file="SpamdataPermutation.RData")
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

OutSmall <- glm(SmallFm,family=binomial(link = "logit"),data=TrainData)


