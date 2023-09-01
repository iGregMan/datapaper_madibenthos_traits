setwd("C:/Users/Salomé/Google Drive/ATER/Stages/Ines_Normand_Chebbi/cartographie/data habitat/Sig")
library(rgdal)
biocenose_sh<-readOGR("biocenoses0_50.shp")
plot(biocenose_sh)

biocenose_csv<-read.csv("C:/Users/Salomé/Google Drive/ATER/Stages/Ines_Normand_Chebbi/cartographie/data habitat/biocenose 0_50m.csv")


names(biocenose_sh)
names(biocenose_csv)


biocenose_csv<-biocenose_csv[order(biocenose_csv$ID,biocenose_csv$Code, biocenose_csv$Surface ),]
biocenose_sh<-biocenose_sh[order(biocenose_sh$ID,biocenose_sh$Code, biocenose_sh$Surface ),]

biocenose_sh<-biocenose_sh[,-1]
biocenose_sh<-biocenose_sh[,c(7,1:6)]
biocenose_csv<-biocenose_csv[,c(2:8)]

biocenose_sh$Biocenoses<-biocenose_csv$Biocenoses
biocenose_sh$Surface<-biocenose_csv$Surface
biocenose_sh$Carte<-biocenose_csv$Carte
biocenose_sh$Commune<-biocenose_csv$Commune
biocenose_sh$Code<-biocenose_csv$Code
biocenose_sh$LIFEFORM<-biocenose_csv$LIFEFORM
biocenose_sh$ID<-biocenose_csv$ID


writeOGR(biocenose_sh,dsn="biocenose_corr.shp", layer="biocenose_corr", driver="ESRI Shapefile")
