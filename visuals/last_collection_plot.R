#read in the cleaned and combined bin & osm data 
combined_bin_osm <- st_read("cleaned_data/combined_bin_osm_data/combined_bin_osm.shp")

#undoing some shortened naming when read to shape file
combined_bin_osm <- combined_bin_osm %>%
  rename("street_name" = "strt_nm",
        "total_vol_l3" = "ttl_v_3",
       "total_weight_kg" = "ttl_wg_",
       "cumul_total_vol_l3" = "cm_t__3",
       "cumul_total_weight_kg" = "cm_tt__",
       "highway_group" = "hghwy_g")

# read in all the .shp files in the cleaned osm data folder 
dir_path <- 'cleaned_data/osm_data/'
file_pattern <- '*.shp'
shp_files <- list.files(dir_path, pattern = file_pattern)

for (i in seq_along(shp_files)) {
  assign(str_remove(shp_files[i], ".shp"), st_read(paste0(dir_path, shp_files[i])))
}

#undoing some shortened naming when read to shape file
streets_simplified <- streets_simplified %>%
  rename("street_name" = "strt_nm",
         "highway_group" = "hghwy_g")

# setting the max and min lat/long for cropping visual
min_max_coords <- c(ymin= 55.928479867725436,
                    xmin= -3.227624857214751,
                    ymax= 55.98333902701634,
                    xmax= -3.140735628435386)

# ------------------------------------------------------------------------------

# subset the data so only the last bin collection date (so get 1 row per street) 
last_date <- combined_bin_osm %>%
  st_drop_geometry() %>% #no need for geometry 
  summarise(min_date = max(date))%>%
  pull()

last_date_bin_collection_sf <- combined_bin_osm %>%
  filter(date == last_date)


# Plots -------------------------------------

# Highlighting which streets have sensor bins on ----------------------------

ggplot() +
  geom_sf(data = water,
          fill = "steelblue",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = park_multipoly,
          fill = "green",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = park_poly,
          fill = "green",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = railways,
          color = "grey30",
          size = .2,
          linetype="dotdash",
          alpha = .5) +
  geom_sf(data = streets_simplified %>% 
            filter(highway_group == "small"),
          size = .1,
          color = "grey40") +
  geom_sf(data = streets_simplified %>% 
            filter(highway_group == "medium"),
          size = .3,
          color = "grey35") +
  geom_sf(data = streets_simplified %>% 
            filter(highway_group == "large"),
          size = .5,
          color = "grey30") +
  geom_sf(data =  last_date_bin_collection_sf, color = "red", size = .5, show.legend = "line") +
  labs(caption = 'Edinburgh - bin sensor project', size = 2) +
  coord_sf(ylim = c(min_max_coords[1], min_max_coords[3]),
           xlim = c(min_max_coords[2], min_max_coords[4]),
           expand = FALSE)


# Last bin collection thickness showing weight ----------------------------
ggplot() +
  geom_sf(data = water,
          fill = "steelblue",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = park_multipoly,
          fill = "green",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = park_poly,
          fill = "green",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = railways,
          color = "grey30",
          size = .2,
          linetype="dotdash",
          alpha = .5) +
  geom_sf(data = streets_simplified %>% 
            filter(highway_group == "small"),
          size = .1,
          color = "grey40") +
  geom_sf(data = streets_simplified %>% 
            filter(highway_group == "medium"),
          size = .3,
          color = "grey35") +
  geom_sf(data = streets_simplified %>% 
            filter(highway_group == "large"),
          size = .5,
          color = "grey30") +
  geom_sf(data =  last_date_bin_collection_sf, aes(colour = cumul_total_weight_kg), 
          size = 1,
          show.legend = "line") +
  scale_colour_gradient(low = "yellow", high = "red") +
  labs(caption = 'Edinburgh - bin sensor project', size = 2) +
  coord_sf(ylim = c(min_max_coords[1], min_max_coords[3]),
           xlim = c(min_max_coords[2], min_max_coords[4]),
           expand = FALSE)


# Streets over time ----------------------------

combined_bin_osm %>%
  ggplot(aes(x = date, y = cumul_total_weight_kg, group = street_name)) +
  geom_line()


combined_bin_osm %>%
  filter(street_name != "princes street") %>%
  ggplot(aes(x = date, y = cumul_total_weight_kg, group = street_name)) +
  geom_line()


#transform to a log axis on y to compare rate of change
combined_bin_osm %>%
  ggplot(aes(x = date, y = cumul_total_weight_kg, group = street_name)) +
  geom_line() +
  scale_y_continuous(trans = "log10") +
  labs(y = "Log transform of cumulative weight of rubbish in kg")

combined_bin_osm %>%
  filter(street_name %in% c("calton hill", "hermitage place")) %>%
  ggplot(aes(x = date, y = cumul_total_weight_kg, color = street_name)) +
  geom_line() +
  scale_y_continuous(trans ="log10") +
  labs(y = "Log transform of cumulative weight of rubbish in kg")

combined_bin_osm %>%
  filter(street_name %in% c("calton hill", "hermitage place")) %>%
  ggplot(aes(x = date, y = cumul_total_weight_kg, color = street_name)) +
  geom_line() +
  theme_minimal()