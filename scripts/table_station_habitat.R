# Ajout des correspondances nouveau (LB_CODE) et anciens (LB_CODEi) intitulés
hab2 <- hab %>%
  left_join(lb) %>%
  select(1:4, 28, everything())

# Ajout des correspondances habitat / nouveaux intitulés et CD_HAB
# par correspondance avec les anciens intitulés (LB_CODEi)
cc2 <- cc %>%
  left_join(
    hab2 %>% select(LB_CODEi, LB_CODE, CD_HAB)
  )

# Des anciens intitulés n'ont pas de correspondance avec de nouveaux intitulés
cc_nona <- cc2 %>%
  filter(!is.na(CD_HAB))
cc_na <- cc2 %>%
  filter(is.na(CD_HAB)) %>%
  filter(!duplicated(.))
unique(cc_na$LB_CODEi)



# séparation des LB_CODE en différents niveaux d'habitat
# (étage, géomorphologie, substrat, peuplement)
hs <- cc_nona %>%
  mutate(
    LB_CODE_geo = str_split(LB_CODE, "\\.") %>% lapply(pluck, 1) %>% unlist(),
    LB_CODE_sub = str_split(LB_CODE, "-") %>% lapply(pluck, 1) %>% unlist(),
    LB_CODE_etg = substr(LB_CODE, 1, 1)
  )
# ajout des CD_HAB pour chaque niveau d'habitat
cdhabs <- apply(
  hs[, c("LB_CODE_geo", "LB_CODE_sub", "LB_CODE_etg")],
  2,
  \(l) {
    habref$CD_HAB[match(l, habref$LB_CODE)]
  }
) %>%
  as.data.frame()
names(cdhabs) <- paste("CD_HAB", c("geo", "sub", "etg"), sep = "_")
hs <- hs %>%
  cbind(cdhabs) %>%
  select(
    "LB_CODEi", "STATION_REF", "LB_CODE", "CD_HAB", "LB_CODE_geo",
    "CD_HAB_geo", "LB_CODE_sub", "CD_HAB_sub", "LB_CODE_etg", "CD_HAB_etg"
    )


# Correspondance avec stations de collecte Majo/Muri

# Concaténation des stations où Muricoidea et Majoidea sont présents
tb_majo <- tibble(
  TAXON = "MAJOIDEA",
  STATION = unique(species$Majoidea$collectStation)
)
tb_muri <- tibble(
  TAXON = "MURICOIDEA",
  STATION = unique(species$Muricoidea$collectStation)
)
tb <- rbind(tb_majo, tb_muri)

# Ajout des correspondances stations de références puis intitulés/CD_HAB
tb <- tb %>%
  left_join(stn_ref) %>%
  left_join(hs)

# Plusieurs stations sans intitulés
tb_na <- tb %>%
  filter(is.na(CD_HAB)) %>%
  select(-TAXON) %>%
  filter(!duplicated(.))

length(unique(tb_na$STATION))
length(unique(tb_na$STATION_REF))
unique(tb_na$STATION_REF)
