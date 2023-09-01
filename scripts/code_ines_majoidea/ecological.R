###################################
######## Ecological example #######
###################################

Ecolo <- read.csv("http://factominer.free.fr/missMDA/ecological.csv", header = TRUE, sep=";",dec=",")

## Delete species with only missing values for contiuous variables
ind <- which(rowSums(is.na(Ecolo[,-1])) == 6)
biome <- Ecolo[-ind,1]    ### Keep a categorical variable
Ecolo <- Ecolo[-ind,-1]   ### Select continuous variables
dim(Ecolo)

## proportion of missing values
sum(is.na(Ecolo))/(nrow(Ecolo)*ncol(Ecolo)) # 55% of missing values

## Delete species with missing values
dim(na.omit(Ecolo)) # only 72 remaining species!

#### Visualize the pattern
library(VIM)
aggr(Ecolo)
aggr(Ecolo,only.miss=TRUE,numbers=TRUE,sortVar=TRUE)
res <- summary(aggr(Ecolo,prop=TRUE,combined=TRUE))$combinations
res[rev(order(res[,2])),]

mis.ind <- matrix("o",nrow=nrow(Ecolo),ncol=ncol(Ecolo))
mis.ind[is.na(Ecolo)] <- "m"
dimnames(mis.ind) <- dimnames(Ecolo)
library(FactoMineR)
resMCA <- MCA(mis.ind)
plot(resMCA,invis="ind",title="MCA graph of the categories")

### Impute the incomplete data set
library(missMDA)
### nb <- estim_ncpPCA(Ecolo,method.cv="Kfold",nbsim=100) ### Time consuming!
res.comp <- imputePCA(Ecolo,ncp=2)

#Perform a PCA on the completed data set
imp <- cbind.data.frame(res.comp$completeObs,biome)
res.pca <- PCA(imp,quali.sup=7,graph=FALSE)
plot(res.pca, hab=7, lab="quali")
plot(res.pca, hab=7, lab="quali",invisible="ind")
plot(res.pca, choix="var")
