tab_list <- mapply(
  function(path, name) {
    tb <- read.csv(path) %>% 
      as_tibble() %>% 
      select(-1) %>% 
      separate(sp, c("gen", "sp"), "_")
    name_vec <- name %>% 
      gsub(".csv", "", .) %>% 
      strsplit(., "_") %>% 
      unlist()
    name_vec[3] <- sprintf("%02d", as.numeric(name_vec[3]))
    tb$file <- name_vec[3]
    
    return(tb)
  },
  list.files(here("data", "raw", "data_ventral"), full.names = T),
  list.files(here("data", "raw", "data_ventral")),
  SIMPLIFY = F
)

tab <- do.call(rbind, tab_list)

write.csv(tab, here("data", "tidy", "df_vent.csv"))

# Standardisation Siratus michelae

tab_list <- mapply(
  function(path, name) {
    tb <- read.csv(path) %>% 
      as_tibble() %>% 
      select(-1) %>% 
      separate(sp, c("gen", "sp"), "_")
    name_vec <- name %>% 
      gsub(".JPG.csv", "", .) %>% 
      strsplit(., "_") %>% 
      unlist()
    # tb$id <- name_vec[1]
    tb$id <- paste(name_vec[1], name_vec[2], sep = "_")
    # tb$individual <- name_vec[2] %>% substr(1, 1)
    # tb$replicate <- name_vec[2] %>% substr(3, 3)
    tb$individual <- name_vec[3] %>% substr(1, 1)
    tb$replicate <- name_vec[3] %>% substr(3, 3)
    return(tb)
  },
  list.files(
    here(
      "data",
      "tidy",
      "standardisation_Siratus_michelae", 
      "ventral_measures"), 
    full.names = T
  ),
  list.files(
    here(
      "data",
      "tidy",
      "standardisation_Siratus_michelae", 
      "ventral_measures")
  ),
  SIMPLIFY = F
)

tab <- do.call(rbind, tab_list)

write.csv(
  tab, 
  here("data", "analysis", "standardisation_Smichelae_measures.csv"),
  row.names = F
)
