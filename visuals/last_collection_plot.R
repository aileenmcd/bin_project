combined_bin_osm <- st_read("cleaned_data/combined_bin_osm.shp")


last_date <- combined_bin_osm %>%
  st_drop_geometry() %>% #no need for geometry 
  summarise(min_date = max(date))%>%
  pull()

last_date_bin_collection_sf <- combined_bin_osm %>%
  filter(date == last_date)

# Plot -------------------------------------

ggplot() +
  blankbg +
  geom_sf(data = water_cropped,
          fill = "steelblue",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = park_multipoly,
          fill = "green",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = park_poly_cropped,
          fill = "green",
          # size = .8,
          lwd = 0,
          alpha = .3) +
  geom_sf(data = railways_cropped,
          color = "grey30",
          size = .2,
          linetype="dotdash",
          alpha = .5) +
  geom_sf(data = streets_cropped %>% 
            filter(highway_group == "small"),
          size = .1,
          color = "grey40") +
  geom_sf(data = streets_cropped %>% 
            filter(highway_group == "medium"),
          size = .3,
          color = "grey35") +
  geom_sf(data = streets_cropped %>% 
            filter(highway_group == "large"),
          size = .5,
          color = "grey30") +
  geom_sf(data =  last_date_bin_collection_sf, color = "red", size = .5, show.legend = "line") +
  labs(caption = 'Edinburgh - bin sensor project', size = 2) +
  coord_sf(ylim = c(bbox[1], bbox[3]),
           xlim = c(bbox[2], bbox[4]),
           expand = FALSE)
