# import
shape_initial <- chc2Out(
  here(
    "data",
    "tidy",
    "standardisation_Siratus_michelae",
    "apical_silhouette",
    "Siratus_michelae_standardisation_shape_apical_2.chc"
  ),
  skip = 5
)
names(shape_initial) <- names(shape_initial) %>%
  substr(18, 20)
my_shape <- "apical"

shape_centered <- coo_center(shape_initial)
shape_scaled   <- coo_scale(shape_centered)

# calibration
shape_calibration  <- calibrate_harmonicpower_efourier(
  shape_scaled,
  nb.h = 100,
  thresh = c(90, 99, 99.9, 99.99)
)

saveRDS(
  shape_calibration,
  here(
    "data",
    "tidy",
    paste(
      "calibration", my_shape, "standardisation.rds", collapse = "_"
    )
  )
)
shape_calibration <- readRDS(
  here(
    "data",
    "tidy",
    paste(
      "calibration", my_shape, "standardisation.rds", collapse = "_"
    )
  )
)

# harmoniques
shape_harmonics <- as.numeric(shape_calibration$minh[2])

shape_calibration <- shape_calibration$q %>%
  as_tibble()%>%
  gather(harmonics, values)%>%
  mutate(harmonics=as.numeric(str_remove(harmonics, "h")))%>%
  group_by(harmonics)%>%
  summarise(mean=mean(values),
            sd=sd(values),
            mean_sd=mean(values)-sd(values),
            mean_and_sd=mean(values)+sd(values),
            q25=quantile(values, probs = 0.25),
            q75=quantile(values, probs = 0.75),
            q10=quantile(values, probs = 0.10),
            q90=quantile(values, probs = 0.90))

# plot harmoniques
ggplot(shape_calibration, mapping=aes(x=harmonics)) +
  geom_ribbon(aes(ymin=q25, ymax=q75, group=1), alpha=0.3) +
  geom_path(aes(y=mean, group=1),  size=1) +
  geom_hline(yintercept=99.9, linetype="dashed",
             color = "red", size=1)+
  geom_vline(xintercept = shape_harmonics,
             color = "black", size=1)+
  xlab("Harmoniques")+
  ylab("Somme cumulée des contributions des harmoniques") +
  ggtitle(
    "Évolution de l'inertie expliquée par les harmoniques (faces shapees)"
  )

ggsave(
  here(
    "figures",
    paste(
      "harmonics",
      my_shape,
      "standardisation",
      "Siratus",
      "michelae",
      "madibenthos.png",
      collapse = "_"
    )
  ),
  width = 16,
  height = 10,
  units = "cm"
)

# traitement de la position des formes
shape_centered <- coo_center(shape_initial)
panel(shape_centered, names = T)
# Formes 13a et 23a légèrement tournées, va avoir des conséquences
# sur les alignements
# shape_centered[[1]]$`13a` <- coo_rotate(shape_centered[[1]]$`13a`, theta = -pi/8)
# shape_centered[[1]]$`23a` <- coo_rotate(shape_centered[[1]]$`23a`, theta = -pi/10)
# panel(shape_centered)
shape_scaled   <- coo_scale(shape_centered)
shape_aligned  <- coo_align(shape_scaled)
shape_slided   <- coo_slidedirection(shape_aligned, "W")

panel(shape_centered)
panel(shape_scaled)
panel(shape_aligned)
panel(shape_slided)

stack(shape_slided)
pile(shape_slided)

# analyse de fourier et PCA
shape_ellipse_fourier <- efourier(
  shape_aligned, nb.h = shape_harmonics, norm = FALSE
)
shape_pca <- Momocs::PCA(
  shape_ellipse_fourier, scale. = FALSE, center = TRUE
)

# modèle des bâtons brisés
shape_evplot <- shape_pca$sdev^2
png(
  here(
    "figures",
    paste(
      "evplot",
      my_shape,
      "standardisation",
      "Siratus",
      "michelae",
      "madibenthos.png",
      collapse = "_"
    )
  )
)
evplot(shape_evplot)
dev.off()
cumsum(shape_pca$eig)*100
shape_pca$eig <- shape_pca$x
# on conserve le premier Axe

# essai infructueux
# png("essai_shape.png")
# x11()
# par(mar = rep(0, 4))
# plot_PCA(shape_pca)
# shape_ellipse_fourier %>%
#   FactoMineR::PCA() %>%
#   plot_PCA(
#     ~col3,
#     labelpoints = TRUE,
#     points = "o"
#   )
# dev.off()

# Espace morphométrique
# paramètres de morphospace_position
# "range", "full", "circle", "xy", "range_axes", "full_axes"
plot_PCA(
  shape_pca,
  zoom                 = 1,
  points = FALSE,
  eigen                = FALSE,
  morphospace_position = "range",
  chullfilled          = TRUE,
  labelpoints          = TRUE
)
# layer_labelpoints(
#   list(shape_pca$fac$col4),
#   col = shape_pca$fac$col3
# )
plot_PCA(shape_pca, axes = c(2,3), labelpoints = T)
plot_PCA(shape_pca, axes = c(1,4))
