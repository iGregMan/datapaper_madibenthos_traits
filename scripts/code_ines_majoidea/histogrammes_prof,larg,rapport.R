
setwd("~/R")

#profondeur
traits_complet_profondeur <- read_csv("traits complet - profondeur.csv")

hist(traits_complet_profondeur$`0 - 35 m`,2)
hist(traits_complet_profondeur$`35 - 200 m`,2)
hist(traits_complet_profondeur$`> 200 m`,2)


#largeur et rapport long/larg
spp_traits <- read_csv("spp_traits.csv")

hist(spp_traits$`larg Moy`,65)
hist(spp_traits$`larg Moy`)

hist(spp_traits$`rapport long/larg`,65)
hist(spp_traits$`rapport long/larg`)

#largeur et rapport long/larg sans la valeur très grande
traits_complet_Sheet4 <- read_csv("traits complet - Sheet4.csv")

hist(traits_complet_Sheet4$`long Moy`,65)
hist(traits_complet_Sheet4$`long Moy`)

hist(traits_complet_Sheet4$`rapport long/larg`,65)
hist(traits_complet_Sheet4$`rapport long/larg`)
