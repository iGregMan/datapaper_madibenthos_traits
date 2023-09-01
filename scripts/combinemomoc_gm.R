source(here::here("scripts", "boot.R"))
source(here("scripts", "FUN_evplot.R"))
source(here("scripts", "FUN_chc2out.R"))

# import


shape_large <- chc2Out(
  here("data", "raw", "large.chc"), 
  skip = 10
)

shape_long <- chc2Out(
  here("data", "raw", "long.chc"), 
  skip = 10
)


shape_long <- shape_long %>% 
  coo_scale() %>%
  coo_center() %>% 
  coo_align()

shape_large <- shape_large %>% 
  coo_align() %>%
  coo_rotate(theta=-3.14/2)

shape_total <- Momocs::combine(
  list(shape_long, shape_large)
)
panel(shape_total)