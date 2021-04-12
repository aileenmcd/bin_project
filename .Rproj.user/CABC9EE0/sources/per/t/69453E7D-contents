# first check to join by 'street_name' column
full_bin_data_first_join <- bins %>%
  inner_join(streets_cropped, by = c("street_name" = "name"))

# for any ones which don't match on 'street_name' try on 'sub_street_name' as this has info on smaller sub streets
full_bin_data_second_join <- bins %>%
  anti_join(streets_cropped, by = c("street_name" = "name")) %>%
  inner_join(streets_cropped, by = c("street_name" = "sub_street_name")) %>%
  select(-name)

# combine data from first and second join checks 
full_bin_data_sf <- bind_rows(full_bin_data_first_join, full_bin_data_second_join) %>%
  st_as_sf() #convert to sf object

#there isn't a row at every date for every street 
full_bin_data_sf %>%
  arrange(street_name, sub_street_name, date) %>% 
  mutate(joining_street = coalesce(street_name, sub_street_name)) %>%
  complete(joining_street, nesting(date))

# TO FINISH - complete cumulative amounts 

p <- ggplot() +
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
  geom_sf(data =  full_bin_data_sf, aes(size = cum_total), color = "red", show.legend = "line") +
  labs(caption = 'Edinburgh - bin sensor project', size = 2) +
  coord_sf(ylim = c(bbox[1], bbox[3]),
           xlim = c(bbox[2], bbox[4]),
           expand = FALSE)

p + transition_time(date) +
  labs(title = "Date: {frame_time}")