###############################
#### Import the ozone data set
###############################

don <- read.table("ozoneNA.csv",header=TRUE,sep=",",row.names=1)
WindDirection <- don[,12]
don <- don[,1:11]           #### keep the continuous variables

######################################################
#### Visualization of the pattern of missing values
######################################################
library(VIM)
aggr(don)
aggr(don,only.miss=TRUE,sortVar=TRUE)
res <- summary(aggr(don,prop=TRUE,combined=TRUE))$combinations
res[rev(order(res[,2])),]
 
matrixplot(don,sortby=2)
marginplot(don[,c("T9","maxO3")])

# Creation of a categorical data set with "o" when observed and "m" when missing
mis.ind <- matrix("o",nrow=nrow(don),ncol=ncol(don))
mis.ind[is.na(don)] <- "m"
dimnames(mis.ind) <- dimnames(don)
mis.ind

# Performing a multiple correspondence analysis to visualize the association
library(FactoMineR)
resMCA <- MCA(mis.ind)
plot(resMCA,invis="ind",title="MCA graph of the categories")

###############################################
#### EM algorithm to estimate mu and Sigma ####
###############################################
library(norm)
pre <- prelim.norm(as.matrix(don))
thetahat <- em.norm(pre)
getparam.norm(pre,thetahat)

###########################
#### Single imputation ####
###########################

## Single imputation using a draw from a normal distribution
library(norm)
pre <- prelim.norm(as.matrix(don))
thetahat <- em.norm(pre)
rngseed(123)           ### must be done!
imp <- imp.norm(pre,thetahat,don)

## Single imputation with PCA 
library(missMDA)
## nb <- estim_ncpPCA(don,method.cv="Kfold") # estimation of the number of dimensions - Time consuming
## nb$ncp 
## plot(0:5,nb$criterion,xlab="dim",ylab="MSEP")
res.comp <- imputePCA(don,ncp=2)
res.comp$completeObs
indvar="T9"
indNA=which(is.na(don[,indvar]))
plot(density(res.comp$completeObs[indNA,indvar]),main="Observed and imputed values for T9",xlab="T9")
lines(density(res.comp$completeObs[which(!((1:nrow(don))%in%indNA)),indvar]),col="red")
legend("topleft",text.col=c("black","red"),legend=c("Observed values","Imputations"))
#Performing a PCA on the completed data set
imp <- cbind.data.frame(res.comp$completeObs, WindDirection)
res.pca <- PCA(imp,quanti.sup=1,quali.sup=12)
plot(res.pca, hab=12, lab="quali")
plot(res.pca, choix="var")
res.pca$ind$coord #scores (principal components)
res.pca$var$coord

#####################################
######## Multiple Imputation ########
#####################################

don <- read.table("ozoneNA.csv",header=TRUE,sep=",",row.names=1)
WindDirection <- don[,12]
don <- don[,1:11]           #### keep the continuous variables

library(Amelia)
res.amelia <- amelia(don,m=100,p2s=0)

library(mice)
res.mice <- mice(don,m=100,defaultMethod="norm", printFlag=F) # here the variability of the regression parameters is obtained by bootstrap

library(missMDA)
res.MIPCA <- MIPCA(don,ncp=2)

## Checking and visualization of the imputations 
plot(res.amelia)
par(mfrow=c(1,1))
compare.density(res.amelia, var="T12")
overimpute(res.amelia, var="maxO3")
# visualization with PCA 
plot(res.MIPCA,choice= "ind.supp"); plot(res.MIPCA,choice="var")

## Pooling the results 

lm.mice.out <- with(res.mice, lm(maxO3 ~ T9+T12+T15+Ne9+Ne12+Ne15+Vx9+Vx12+Vx15+maxO3v))
pool.mice <- pool(lm.mice.out)
resultmice <- summary(pool.mice)
