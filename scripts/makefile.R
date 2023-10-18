# makefile
source(here::here("scripts", "boot.R"))

# Morphométrie ----
#   Mesures
source(here("scripts", "aggregation_mesures_imagej.R"))
source(here("scripts", "calcul_mesures_imagej.R"))
#   Formes
source(here("scripts", "invmar_morphometry.R"))
#   Standardisation
source(here("scripts", "standardisation_morphometry_apical.R"))
source(here("scripts", "standardisation_morphometry.R"))
source(here("scripts", "pca_standardisation_mesures.R"))

# Habitats ----
source(here("scripts", "table_station_habitat.R"))
source(here("scripts", "habitat_majoritaire_cdhab.R"))
source(here("scripts", "habitat_majoritaire_lbcode.R"))

# Traits ----
source(here("scripts", "modification_table_traits.R"))
