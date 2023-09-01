setwd("~/Google Drive/ATER/Stages/Ines_Normand_Chebbi/Database/majoidea2")

install.packages("foreign")
install.packages("tidyverse")
install.packages("dplyr")
install.packages("rgdal")
install.packages("raster")
install.packages("WriteXLS")
library(foreign)
library(dplyr)
library(tidyverse)
library(rgdal)
library(raster)
library(WriteXLS)
library(readxl)
data<-as_tibble(read_excel("INVMAR_2020_11_12.xlsx"))
data
names(data)
data<-data[data$CAMPAGNE.ACRONYME=="MADIBENTHOS",]
data<-data[which(data$TAXON.SUPER_FAMILLE=="Majoidea"),]
unique(data$TAXON.SUPER_FAMILLE)
data$species<-paste0(data$TAXON.GENRE,"_" ,data$TAXON.ESPECE)


######### shapefile by family
family<-data



######### shapefile by species
species<-data


