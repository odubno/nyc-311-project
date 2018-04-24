library(ggmap)

x <- get_map(location = c(lon = -74.00597, lat = 40.71278), zoom = 11)

saveRDS(x, "nyc_map.rds")

