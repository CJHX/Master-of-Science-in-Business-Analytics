##HW2 Code cxi2

FileName <- "C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Machine Learning/HW2/SelfieImageData.csv"

Labs <- scan(file=FileName,what="xx",nlines=1,sep="|")
DataAsChars <- matrix(scan(file=FileName,what="xx",sep="|",skip=1),byrow=T,ncol=length(Labs))
colnames(DataAsChars) <- Labs
dim(DataAsChars)
# size in memory in MBs
as.double(object.size(DataAsChars)/1024/1024)

ImgData <- matrix(as.integer(DataAsChars[,-1]),nrow=nrow(DataAsChars))
colnames(ImgData) <- Labs[-1]
rownames(ImgData) <- DataAsChars[,1]
# size in memory in MBs
as.double(object.size(ImgData)/1024/1024)

# Take a look
ImgData[1:8,1:8]

# Free up some memory just in case
remove(DataAsChars)

# Show each Image
#for(whImg in 1:nrow(ImgData)) {
#  Img <- matrix(ImgData[whImg,],byrow=T,ncol=sqrt(ncol(ImgData)))
#  Img <- apply(Img,2,rev)
#  par(pty="s",mfrow=c(1,1))
#  image(z=t(Img),col = grey.colors(255),useRaster=T)
#  Sys.sleep(1)
#}

#########Question 2: Plot the Average Face####################
AvgFace <- apply(ImgData, 2, mean)
Avg_Face <- matrix(AvgFace,byrow=T,ncol=sqrt(ncol(ImgData)))
Avg_Face <- apply(Avg_Face,2,rev)
par(pty="s",mfrow=c(1,1))
image(z=t(Avg_Face),col = grey.colors(255),useRaster=T, main="cxi2: Average Face ")

####################Question5: Scree plot #######################
Centered_ImgData <- sweep(ImgData,2,apply(ImgData,2,mean),"-")
#sigma_hat <- (t(Centered_ImgData) %*% Centered_ImgData)/20 ????
SmallMatrix <- Centered_ImgData %*% t(Centered_ImgData)

#Calculating sigma hat eigenvalues using the small matrix eigenvalues
SmallMtrxEigenValue <- eigen(SmallMatrix)
SigmaH_EV <- SmallMtrxEigenValue$values/40.0

#Eigenvector calculation
SigmaH_EV_Pre <- t(Centered_ImgData) %*% SmallMtrxEigenValue$vectors
SigmaH_EV_Norm <- 1:41
for(i in 1:41){
  SigmaH_EV_Norm[i]<- sqrt(t(SigmaH_EV_Pre[,i])%*%SigmaH_EV_Pre[,i])
}
Sigma_EV <- sweep(SigmaH_EV_Pre,2,SigmaH_EV_Norm,"/") 

par(pty="s",mfrow=c(1,1))
plot(SigmaH_EV, type="b",xlab="Component Number",ylab="Eigenvalue")
title("cxi2: Scree Plot ")

####################Question6:Largest eigenvalue of sample VC matrix #######################
SigmaH_EV[1]
sprintf(SigmaH_EV[1], fmt = '%#.2f')
#22564932.09

####################Question7:85% of Total Variance #######################
sum(SigmaH_EV[1:19])/sum(SigmaH_EV)
sum(SigmaH_EV[1:20])/sum(SigmaH_EV)
sum(SigmaH_EV[1:21])/sum(SigmaH_EV)
#21

####################Question8: 20Dimension Face #######################
par(pty="s",mfrow=c(1,1))
PCompTrain20d <- Centered_ImgData%*%Sigma_EV[,1:20]
PCompTrain20d_Another <- PCompTrain20d%*%t(Sigma_EV[,1:20])
ReconTrain20d <- sweep(PCompTrain20d_Another,2,apply(ImgData,2,mean),"+")
ImageData2 <- matrix(ReconTrain20d[5,],byrow=T,ncol=451)
ImageData2 <- apply(ImageData2,2,rev)
image(z=t(ImageData2),col = grey.colors(255),useRaster=T, main="cxi2: My Face 20D")


####################Question 10: 8th Eigenface#########################
#Create weight image (eigenface)
Vector <- Sigma_EV[,8]
Vector <- (Vector-min(Vector))/(max(Vector)-min(Vector))
Vector <- Vector*255
range(Vector)
VectorImg <- matrix(Vector,byrow=T,ncol=451)
VectorImg <- apply(VectorImg,2,rev)
par(pty="s",mfrow=c(1,1))
image(z=t(VectorImg),col = grey.colors(255),useRaster=T, main="cxi2: Eigenface 8")


####################Question 11: Glasses#########################

#Printing all 20 Eigenvectors and exporting results to a 4k image for inspection
par(pty="s",mfrow=c(4,5))
for(j in 1:20) {
  Vector <- Sigma_EV[,j]
  VectorImg <- matrix(Vector,byrow=T,ncol=451)
  VectorImg <- apply(VectorImg,2,rev)
  image(z=t(VectorImg),col = grey.colors(255),useRaster=T,main=paste("Eigenvector",j))
}



###########################################


par(pty="s",mfrow=c(1,4))
vec <- Sigma_EV[,6]
vec <- (vec-min(vec))/(max(vec)-min(vec))
vec <- vec*255
range(vec)
vecImage <- matrix(vec,byrow=T,ncol=451)
vecImage <- apply(vecImage,2,rev)
par(pty="s",mfrow=c(1,1))
image(z=t(vecImage),col = grey.colors(255),useRaster=T, main="cxi2: Eigenface 6")

vec <- Sigma_EV[,9]
vec <- (vec-min(vec))/(max(vec)-min(vec))
vec <- vec*255
range(vec)
vecImage <- matrix(vec,byrow=T,ncol=451)
vecImage <- apply(vecImage,2,rev)
par(pty="s",mfrow=c(1,1))
image(z=t(vecImage),col = grey.colors(255),useRaster=T, main="cxi2: Eigenface 9")




vec <- Sigma_EV[,11]
vec <- (vec-min(vec))/(max(vec)-min(vec))
vec <- vec*255
range(vec)
vecImage <- matrix(vec,byrow=T,ncol=451)
vecImage <- apply(vecImage,2,rev)
par(pty="s",mfrow=c(1,1))
image(z=t(vecImage),col = grey.colors(255),useRaster=T, main="cxi2: Eigenface 11")

vec <- Sigma_EV[,14]
vec <- (vec-min(vec))/(max(vec)-min(vec))
vec <- vec*255
range(vec)
vecImage <- matrix(vec,byrow=T,ncol=451)
vecImage <- apply(vecImage,2,rev)
par(pty="s",mfrow=c(1,1))
image(z=t(vecImage),col = grey.colors(255),useRaster=T, main="cxi2: Eigenface 14")

