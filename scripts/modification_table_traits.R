# modifications manuelles tables de traits de vie ----

# 2023-10-18 : Discussion avec Juliette
mur <- tr$Muricoidea
names(mur)[which(names(mur) == "zone_of_description")] <- "type_locality"
names(mur)[which(names(mur) == "interaction")] <- "interaction_type"
mur <- mur %>%
  add_column(interaction_target = NA, .after = "interaction_type")
names(mur)[28:36] <- c(
  # Measures taken from the ventral view
  # Except for sic_mean taken in lateral view
  # Heights (Vertical lengths)
  "sh_mean",   # Shell Height
  "lwh_mean",  # Last Whorl Height
  "asih_mean", # Aperture & Siphonal Identation Height
  "sih_mean",  # Siphonal Identation Height
  # Widths (Horizontal lengths)
  "aw_mean",   # Aperture Width
  "sw_mean",   # Shell Width
  # Angles
  "sic_mean",  # Siphonal Identation Curvature [Lateral View]
  "aa_mean",   # Apical Angle
  "aao_mean"   # Apical Angle with Ornamentations
)
# ajout des écarts-types + nombre de spécimens ----
mur <- mur[, -c(28:36)]
mur <- mur %>%
  cbind(mur_mesures) %>%
  select(., all_of(names(.)[c(1:27, 55:ncol(.), 28:53)]))
# mur$scientificName[which(!mur$scientificName %in% mur_mesures$scientificName)]

# Ajout des habitats ----
hab <- read.csv(here("data", "raw", "hab") %>%
                  list.files(pattern = "muricoidea.+cd_hab", full.names = T))

# Problème d'actualisation des noms scientifiques
# à changer plus tôt dans les scripts?
mur$scientificName[which(!mur$scientificName %in% hab$scientificName)] <-
  c(
    "Coralliophila salebrosa",
    "Siratus consuelae",
    "Muricopsis corallina",
    "Muricopsis linealba",
    "Typhina pallida",
    "Typhina lamyi"
  )

hab <- hab %>%
  select(
    scientificName,
    CD_HAB_main = CD_HAB_maj1,
    CD_HAB_tid  = CD_HAB_etg,
    CD_HAB_sub,
    CD_HAB_geo
  ) %>%
  filter(scientificName %in% mur$scientificName)
hab <- hab[order(hab$scientificName), ]
mur <- mur[order(mur$scientificName), ]

mur <- mur[, -c(13:15)]
mur <- mur %>%
  cbind(hab[,-1]) %>%
  select(., all_of(names(.)[c(1:12, 70:ncol(.), 13:69)]))

# sauvegarde ----
write.csv(
  mur,
  here("data", "tidy", "traits", "traits_database_muricidae_martinique.csv"),
  row.names = F
)
