# Libraries à charger
libs_to_call <- list(

  "ade4",
  "data.table",
  "FactoMineR",
  "geomorph",
  "ggplot2",
  "ggpubr",
  "here",
  "Momocs",
  "remotes",
  "reshape2",
  "sf",
  "stars",
  "stringr",
  "terra",
  "tidyverse",
  NULL

)

# Appel des librairies
lapply(
  libs_to_call,

  function(i) {

    if (!is.null(i)) {

      bool <- is.element(i, .packages(all.available = TRUE))

      if (!bool) {
        install.packages(i)
      }

      library(i, character.only = TRUE)

    }
  }
)

# remote libraries (github)
Sys.getenv("GITHUB_PAT")
Sys.unsetenv("GITHUB_PAT")
Sys.getenv("GITHUB_PAT")

# remote_libs_to_call <- list(
#   "rbbt"
# )
#
# github_accounts <- list(
#   "paleolimbot"
# )
#
# mapply(
#   function(pckg, usr) {
#
#     bool <- is.element(pckg, .packages(all.available = TRUE))
#
#     if (!bool) {
#       remotes::install_github(paste0(usr, "/", pckg))
#     }
#
#     library(pckg, character.only = TRUE)
#
#   },
#   remote_libs_to_call,
#   github_accounts,
#   SIMPLIFY = FALSE
# )

# Appel des fonctions
lapply(
  list.files(
    here("scripts", "FUN"),
    full.names = T
  ),
  source
)

# paths
superfamilies <- c("Majoidea", "Muricoidea")
names(superfamilies) <- superfamilies

# projection Martinique
utm20N <- "EPSG:32620"

# Importation des données d'occurrences

# De tous les crustacés et mollusques de Madibenthos
# cmd <- "rsync -avuc --delete /home/borea/Documents/mosceco/r_projects/MOSCECO_L2/data_occurrences/data/raw/occ/*.csv /home/borea/Documents/mosceco/datapaper/datapaper_madibenthos_traits/data/raw/occ/"
# system(cmd)
phyla <- list.files(
  here("data", "raw", "occ"),
  pattern = "jacim",
  full.names = T
) %>%
  lapply(read.csv, fileEncoding = "UTF-16")
names(phyla) <- c("crusta", "mollsc")
lapply(phyla, dim) # Nombre d'évènements de collecte

# Des Majoidea et des Muricidae nettoyées
# cmd <- "rsync -avuc --delete /home/borea/Documents/mosceco/r_projects/MOSCECO_L2/data_occurrences/data/tidy/occ/mtq_invmar_clean.csv /home/borea/Documents/mosceco/datapaper/datapaper_madibenthos_traits/data/raw/occ/"
# system(cmd)

species <- read.csv(here("data", "raw", "occ", "mtq_invmar_clean.csv")) %>%
  add_column(
    superfamily = ifelse(.$family == "Muricidae", "Muricoidea", "Majoidea")
  ) %>%
  split(., .$superfamily)

# Importation des données de stations
# cmd <- "rsync -avuc --delete /home/borea/Documents/mosceco/r_projects/MOSCECO_L2/data_occurrences/data/raw/shp/stations_me_mtq* /home/borea/Documents/mosceco/datapaper/datapaper_madibenthos_traits/data/raw/shp/"
# system(cmd)
stn <- st_read(here("data", "raw", "shp", "stations_me_mtq.shp"))

# profondeurs
bathy_MNT <- here("data", "raw", "shp") %>%
  list.files(pattern = "MNT.+grd", full.names = T) %>%
  read_stars()
bbox_mtq <- c(-61.33667, 14.27667, -60.64367, 15.02067)
names(bbox_mtq) <- c("xmin", "ymin", "xmax", "ymax")
bathy <- bathy_MNT %>%
  st_crop(st_bbox(bbox_mtq))
names(bathy) <- "depth"

# polygones
plg <- st_read(here("data", "raw", "shp", "polygons_MTQ.shp"))

# ggplot() +
#   geom_stars(data = bathy) +
#   geom_sf(data = plg) +
#   geom_sf(data = stn) +
#   xlab("Longitude") +
#   ylab("Latitude")

# Informations sur les habitats :

# Import de HABREF
habref <- read.csv(
  here("data", "raw", "hab", "HABREF_70.csv"),
  sep = ";"
) %>%
  filter(CD_TYPO == 108)

# Import de le table de correspondance habitats marins benthiques de Martinique
# / nomenclature de HABREF (CD_HAB)
hab <- read_csv(
  here("data", "raw", "hab", "typo_martinique_mer_70.csv"),
  show_col_types = F
)

# Anciences codes et nouveaux codes habitats (LB_CODE)
lb <- read_csv(
  here("data", "raw", "hab", "typo_martinique_mer_70_intitule_vi_vf_jd_sa.csv"),
  show_col_types = F
) %>%
  select(LB_CODEi = `Code initial`, LB_CODE = `Code finale`)

# Import de la correspondance stations / habitats
cc <- read.csv(
  here("data", "raw", "hab", "correspondance_station_hab.csv"),
  # show_col_types = F,
  sep = ";"
) %>%
  select(LB_CODEi = Code_habitat, STATION_REF)

# Correspondance station/station_ref
stn_ref <- read_csv(
  here("data", "raw", "hab", "correspondance_station_station_ref.csv"),
  show_col_types = F
) %>%
  select(STATION, STATION_REF)

# Mesures ----
mur_mesures <- read.csv(here("data", "tidy", "muricidae_mesures_metriques.csv"))

# Traits ----
tr <- list.files(here("data", "raw", "traits"), full.names = T) %>%
  lapply(read.csv, fileEncoding = "UTF-16")
names(tr) <- c("Majoidea", "Muricoidea")

