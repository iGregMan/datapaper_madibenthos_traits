R <- lapply(
  names(species),
  \(sf) {
    lapply(
      sort(unique(species[[sf]]$scientificName)),
      \(sp) {

        # sf <- "Muricoidea"
        # sp <- "Dermomurex alabastrum"

        print(sf)
        print(sp)

        # Isolement des stations dans lesquelles l'espèce d'intérête à été trouvée
        stn_sp <- species[[sf]] %>%
          filter(scientificName == sp) %>%
          select(STATION = collectStation) %>%
          unlist(use.names = F) %>%
          unique()

        bool1 <- if (length(stn_sp) == 1) {
          stn_sp %in% tb_na$STATION_REF
        } else {
          FALSE
        }

        if (length(stn_sp) == 1 & bool1) {
          # Ligne finale pour l'espèce
          row_sp <- c(
            LB_CODE_maj1 = NA,
            LB_CODE_maj2 = NA,
            LB_CODE_etg  = NA,
            LB_CODE_sub  = NA,
            LB_CODE_geo  = NA
          )

          return(row_sp)
        } else {

          # table de l'espèce filtrée des stations sans intitulés
          tb_sp <- tb %>%
            filter(STATION %in% stn_sp) %>%
            filter(TAXON == toupper(sf)) %>%
            filter(!is.na(LB_CODE)) %>%
            filter(!duplicated(.))

          # Attribution des poids à chaque habitat selon le nombre d'habitats contenu
          # dans chaque station
          poids_stations <- round(
            1/(
              tb_sp %>%
                group_by(STATION) %>%
                summarize(STATION = n())
            ),
            2
          )

          tb_poids <- tb_sp$STATION %>%
            unique() %>%
            sort() %>%
            cbind(poids = poids_stations)

          names(tb_poids) <- c("STATION", "poids")

          tb_sp <- tb_sp %>% left_join(tb_poids)

          if (nrow(tb_sp) == 1) {

            # Ligne finale pour l'espèce
            row_sp <- c(
              LB_CODE_maj1 = tb_sp$LB_CODE,
              LB_CODE_maj2 = NA,
              LB_CODE_etg  = tb_sp$LB_CODE_etg,
              LB_CODE_sub  = tb_sp$LB_CODE_sub,
              LB_CODE_geo  = tb_sp$LB_CODE_geo
            )

            return(row_sp)

          } else if (nrow(tb_sp) == 2) {

            # Ligne finale pour l'espèce
            row_sp <- c(
              LB_CODE_maj1 = paste(unique(tb_sp$LB_CODE), collapse = "/"),
              LB_CODE_maj2 = NA,
              LB_CODE_etg  = paste(unique(tb_sp$LB_CODE_etg), collapse = "/"),
              LB_CODE_sub  = paste(unique(tb_sp$LB_CODE_sub), collapse = "/"),
              LB_CODE_geo  = paste(unique(tb_sp$LB_CODE_geo), collapse = "/")
            )

            return(row_sp)
          } else {

            # habitat le plus fréquent, deuxième habitat le plus fréquent
            tt <- tb_sp %>%
              select(LB_CODE, poids) %>%
              group_by(LB_CODE) %>%
              summarise(somme = sum(poids))
            tt <- tt[order(tt$somme, decreasing = T), ]

            # Sélection des fréquences les plus importantes
            tt1 <- tt %>% filter(somme == max(tt$somme))
            tt2 <- tt %>%
              filter(somme != max(tt$somme)) %>%
              filter(., somme == max(.$somme))
            hab_freq_1 <- if (nrow(tt1) > 1) {
              paste(unique(tt1$LB_CODE), collapse = "/")
            } else {
              tt1$LB_CODE
            }
            hab_freq_2 <- if (nrow(tt2) > 0) {
              if (nrow(tt2) > 0) {
                paste(unique(tt2$LB_CODE), collapse = "/")
              } else if (nrow(tt2) > 1) {
                tt2$LB_CODE
              }
            } else {
              NA
            }

            # Étage, Étage x Substrat et Étage x substrat x géomorphologie majoritaires
            f <- tb_sp$LB_CODE_etg
            v <- c()
            clmns <- c("LB_CODE_etg", "LB_CODE_sub", "LB_CODE_geo")

            for (i in seq_along(clmns)) {

              clmn0 <- if (i == 1) { clmns[[i]] } else { clmns[[i - 1]] }
              clmn <- clmns[[i]]

              # Table LB_CODE, prévalence et effectif de chaque LB_CODE
              tt <- tb_sp %>%
                filter(get(clmn0) %in% f) %>%
                select(all_of(c(clmn, "poids"))) %>%
                group_by(get(clmn)) %>%
                summarise(somme = sum(poids), effectif = n())
              tt <- tt[order(tt$somme, decreasing = T), ]
              names(tt)[1] <- clmn

              # Y a-t-il au moins une catégorie au-dessus de 5 d'effectif ?
              bool5 <- sum(tt$effectif >= 5) > 0

              LB_CODE_maj <- if (nrow(tt) == 1) {
                tt[1]
              } else if (nrow(tt) != 1 & !bool5) {
                tt[1, 1]
              } else {
                tf <- tt %>% filter(effectif >= 5)

                print(tf)

                LB_CODE_maj <- if (nrow(tf) == 1) {
                  tf[[clmn]]
                } else {
                  tf$freq <- (tf$somme/sum(tf$somme))*100
                  print(tf)
                  res <- chisq.test(tf$freq)
                  tf[[clmn]][which.max(res$residuals)]
                }
              }

              f <- LB_CODE_maj
              v <- c(v, LB_CODE_maj)

            }

            # Ligne finale pour l'espèce
            row_sp <- c(
              LB_CODE_maj1 = hab_freq_1,
              LB_CODE_maj2 = hab_freq_2,
              LB_CODE_etg  = v[[1]],
              LB_CODE_sub  = v[[2]],
              LB_CODE_geo  = v[[3]]
            )

            return(row_sp)

          }

        }

      })
  })
names(R) <- names(species)
TB <- lapply(
  names(R),
  \(n) {
    l <- R[[n]]
    nn <- species[[n]] %>%
      select(scientificName) %>%
      unlist() %>%
      unique() %>%
      sort()
    cbind(scientificName = nn, do.call(rbind, l))
  }
)
names(TB) <- names(species)

# Sauvegarde
lapply(
  names(TB),
  \(sf) {
    tb <- TB[[sf]]
    write.csv(
      tb,
      here(
        "data", "raw", "hab",
        paste("table", tolower(sf), "habitats", "lb_code", sep = "_") %>%
          paste0(".csv")
      )
    )
  }
)
