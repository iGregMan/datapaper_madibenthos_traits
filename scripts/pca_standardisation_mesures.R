# PCA for standardisation
# Siratus michelae
# Madibenthos

tb <- read.csv(
  here(
    "data",
    "analysis", 
    "standardisation_Smichelae_measures.csv"
  )
)

tb$ID <- paste0(tb$individual, tb$replicate)
cast <- tb %>% 
  dcast(
    ID ~ measure, 
    value.var = "value"
  )
row.names(cast) <- cast$ID
cast <- cast[, -1]
pca.res <- prcomp(cast, scale = T)
pca.res$rotation <- pca.res$rotation * (-1) # reverse the signs
pca.res$rotation

#reverse the signs of the scores
pca.res$x <- -1*pca.res$x

#display the first six scores
head(pca.res$x)

x11()
biplot(
  pca.res, 
  choices = c(1,2),
  scale = 0
)