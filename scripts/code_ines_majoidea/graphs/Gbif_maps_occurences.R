

# https://cran.r-project.org/web/packages/spocc/vignettes/spocc.html
install.packages("rgbif", dependencies = T)
install.packages("spocc", dependencies = T)
install.packages("ggplot2", dependencies = T)

library(spocc)
library(raster)
library(maptools)
library(ggplot2)
library(rgdal)

setwd("C:/Users/Salomé/Google Drive/coclime_ostreo/R/coastline/shp/GSHHS_shp/i") # set working directory

# charge la couche continent
continent<-readOGR("GSHHS_i_L1.shp", "GSHHS_i_L1")
#continent<-crop(continent, extent(min(-87), max(-58), min(7), max(30)))

A.petiverii <- occ(query = 'Acanthonyx petiverii', from = c('gbif'))
str(df)
df<-occ2df(df)

ggplot()+
  geom_polygon(data=continent,aes(x=long, y=lat, group = group))+
  geom_point(data=df, aes(x=longitude, y=latitude), color='red')






