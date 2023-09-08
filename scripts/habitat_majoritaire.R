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
            CD_HAB_maj1 = NA,
            CD_HAB_maj2 = NA,
            CD_HAB_etg  = NA,
            CD_HAB_sub  = NA,
            CD_HAB_geo  = NA
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
              CD_HAB_maj1 = tb_sp$CD_HAB,
              CD_HAB_maj2 = NA,
              CD_HAB_etg  = tb_sp$CD_HAB_etg,
              CD_HAB_sub  = tb_sp$CD_HAB_sub,
              CD_HAB_geo  = tb_sp$CD_HAB_geo
            )

            return(row_sp)

          } else if (nrow(tb_sp) == 2) {

            # Ligne finale pour l'espèce
            row_sp <- c(
              CD_HAB_maj1 = paste(unique(tb_sp$CD_HAB), collapse = "/"),
              CD_HAB_maj2 = NA,
              CD_HAB_etg  = paste(unique(tb_sp$CD_HAB_etg), collapse = "/"),
              CD_HAB_sub  = paste(unique(tb_sp$CD_HAB_sub), collapse = "/"),
              CD_HAB_geo  = paste(unique(tb_sp$CD_HAB_geo), collapse = "/")
            )

            return(row_sp)
          } else {

            # habitat le plus fréquent, deuxième habitat le plus fréquent
            tt <- tb_sp %>%
              select(CD_HAB, poids) %>%
              group_by(CD_HAB) %>%
              summarise(somme = sum(poids))
            tt <- tt[order(tt$somme, decreasing = T), ]

            # Sélection des fréquences les plus importantes
            tt1 <- tt %>% filter(somme == max(tt$somme))
            tt2 <- tt %>%
              filter(somme != max(tt$somme)) %>%
              filter(., somme == max(.$somme))
            hab_freq_1 <- if (nrow(tt1) > 1) {
              paste(unique(tt1$CD_HAB), collapse = "/")
            } else {
              tt1$CD_HAB
            }
            hab_freq_2 <- if (nrow(tt2) > 0) {
              if (nrow(tt2) > 0) {
                paste(unique(tt2$CD_HAB), collapse = "/")
              } else if (nrow(tt2) > 1) {
                tt2$CD_HAB
              }
            } else {
              NA
            }

            # Étage, Étage x Substrat et Étage x substrat x géomorphologie majoritaires
            f <- tb_sp$CD_HAB_etg
            v <- c()
            clmns <- c("CD_HAB_etg", "CD_HAB_sub", "CD_HAB_geo")

            for (i in seq_along(clmns)) {

              clmn0 <- if (i == 1) { clmns[[i]] } else { clmns[[i - 1]] }
              clmn <- clmns[[i]]

              # Table cd_hab, prévalence et effectif de chaque cd_hab
              tt <- tb_sp %>%
                filter(get(clmn0) %in% f) %>%
                select(all_of(c(clmn, "poids"))) %>%
                group_by(get(clmn)) %>%
                summarise(somme = sum(poids), effectif = n())
              tt <- tt[order(tt$somme, decreasing = T), ]
              names(tt)[1] <- clmn

              # Y a-t-il au moins une catégorie au-dessus de 5 d'effectif ?
              bool5 <- sum(tt$effectif >= 5) > 0

              cd_hab_maj <- if (nrow(tt) == 1) {
                tt[1]
              } else if (nrow(tt) != 1 & !bool5) {
                tt[1, 1]
              } else {
                tf <- tt %>% filter(effectif >= 5)

                print(tf)

                cd_hab_maj <- if (nrow(tf) == 1) {
                  tf[[clmn]]
                } else {
                  tf$freq <- (tf$somme/sum(tf$somme))*100
                  print(tf)
                  res <- chisq.test(tf$freq)
                  tf[[clmn]][which.max(res$residuals)]
                }
              }

              f <- cd_hab_maj
              v <- c(v, cd_hab_maj)

            }

            # Ligne finale pour l'espèce
            row_sp <- c(
              CD_HAB_maj1 = hab_freq_1,
              CD_HAB_maj2 = hab_freq_2,
              CD_HAB_etg  = v[[1]],
              CD_HAB_sub  = v[[2]],
              CD_HAB_geo  = v[[3]]
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
    cbind(nn, do.call(rbind, l))
  }
)
