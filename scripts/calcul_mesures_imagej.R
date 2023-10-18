# Importation
tb <- read.csv(here("data", "tidy", "df_vent.csv"))

# Nombre de spécimens par espèce
l <- split(tb, f = paste(tb$gen, tb$sp))
specimens_count <- l %>%
  lapply(\(x) max(as.numeric(x$file))) %>%
  unlist()

# Calcul des moyennes et des écarts-types
lc <- l %>%
  lapply(\(x) {
    x %>%
      group_by(measure) %>%
      summarise(
        mean = mean(value, na.rm = T),
        stdv = sd(value, na.rm = T)
      )
  })

lcs <- lapply(
  lc,
  \(e) {
    e <- e %>% as.data.frame()
    row.names(e) <- e$measure
    e <- e[c("H", "HLW", "HAS", "HA", "WA", "D", "HS", "AA", "AAS"), ]
    e$measure <- c("sh", "lwh", "asih", "sih", "aw", "sw", "sic", "aa", "aao")
    row.names(e) <- e$measure
    f <- t(e) %>%
      apply(2,
            \(x) {
              out <- tibble(as.numeric(x[2]), as.numeric(x[3]))
              names(out) <- c("mean", "stdv")
              out
            })
    g <- do.call(cbind, f)
    names(g) <- gsub("\\.", "_", names(g))
    g
  }
)

tbf <- cbind(specimens_count = specimens_count, do.call(rbind, lcs))
tbf[, 2:ncol(tbf)] <- apply(tbf[, 2:ncol(tbf)], 2, \(x) round(x, 2))
tbf$scientificName <- row.names(tbf)
tbf <- tbf %>% select(ncol(tbf), everything())
tbf$scientificName[11] <- "Coralliophila caribaea"
tbf$scientificName[31] <- "Muricopsis caribbaea"
tbf <- tbf %>% rbind(NA)
tbf <- tbf[c(1:50, nrow(tbf), 51:(nrow(tbf) - 1)), ]
tbf$scientificName[51] <- "Talityphis pallidus"

write.csv(
  tbf, here("data", "tidy", "muricidae_mesures_metriques.csv"), row.names = F
)
