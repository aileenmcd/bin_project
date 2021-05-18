# Combining the bin & OSM data ----------------------------------------------------------------

# loading in cleaned bin & osm data 
bins <- read_csv("cleaned_data/bin_data/aggregated_bin_data.csv")
streets <- st_read("cleaned_data/osm_data/streets_simplified.shp")

#when write a spatial file condenses column names and undoes lowering of street names (need to check this?) so undoing some of this
streets <- streets %>%
  rename("street_name" = "strt_nm", "substreet_name" = "sb_str_") %>%
  mutate(substreet_name = str_to_lower(substreet_name)) %>%
  mutate(street_name = str_to_lower(street_name)) 


# EDA on bin data streets ----------------------------------
bin_streets <- bins %>%
  select(street_name) %>%
  distinct()

bin_streets %>% 
  count()

map_streets <- as_tibble(streets$street_name) %>%
  mutate(value = str_to_lower(value)) %>%
  distinct() 

map_streets %>% 
  count()

#no matches for 23 streets 
no_match <- bin_streets %>% anti_join(map_streets, by = c("street_name" = "value"))
no_match
#from inspection these look to be small streets so may not be named in the osmdata 

#try to match on 'substreet_name' for those that have no match using 'street_name'
map_streets_substreet <- as_tibble(streets$substreet_name) %>%
  mutate(value = str_to_lower(value)) %>%
  distinct()

no_match %>% inner_join(map_streets_substreet, by = c("street_name" = "value"))

# notes from manual inspection:
# promanade & st mark's place is in portebello - outside area looking to concentrate on 
# gayfield square park, leith links, princes street gardens east, princes street gardens west are all parks so decide to omit do to visualising 'amount' of data via thickness of line of street which would not be approrpiate for park polygon space
# restalrig railway path is a cycleway on OSM so choose to omit. 


# Cleaning from join checks -----------------------------------------------
bins_cleaned <- bins %>%
  mutate(street_name = case_when(
    street_name == "atholl cresent" ~ "atholl crescent", #spelling error in raw bin data
    TRUE ~ street_name)) %>%
  filter(str_detect(street_name, "square", negate = TRUE)) %>% #remove any 'squares' as does not visualise well for this
  group_by(street_name, date) %>%
  summarise(total_vol_l3 = sum(total_vol_l3), total_weight_kg = sum(total_weight_kg)) %>% #need to re-aggregate for 'atholl cresent' mispell
  ungroup()


# Calculate cumulative bin volumes/weight -----------------------------------------------
cumulative_bin_data <- bins_cleaned %>%
  arrange(street_name, date) %>%
  complete(street_name, nesting(date)) %>%
  mutate(total_vol_l3 = coalesce(total_vol_l3, 0), total_weight_kg = coalesce(total_weight_kg, 0)) %>%
  group_by(street_name) %>%
  mutate(cumul_total_vol_l3 = cumsum(total_vol_l3), cumul_total_weight_kg = cumsum(total_weight_kg)) %>%
  ungroup()

#write aggregated clean cumulative data
write_csv(cumulative_bin_data, "cleaned_data/bin_data/cumulative_bin_data.csv")

# Joining of bin & osm data -----------------------------------------------

# first check to join by 'street_name' column
full_bin_data_first_join <- cumulative_bin_data %>%
  inner_join(streets, by = c("street_name" = "street_name")) %>%
  mutate(joining_street_name = street_name, .before = everything())

# for any ones which don't match on 'street_name' try on 'sub_street_name' as this has info on smaller sub streets
full_bin_data_second_join <- cumulative_bin_data %>%
  anti_join(streets, by = c("street_name" = "street_name")) %>%
  inner_join(streets, by = c("street_name" = "substreet_name"))  %>%
  mutate(joining_street_name = street_name, .before = everything()) %>%
  select(-street_name.y)

# combine data from first and second join checks 
full_bin_data_sf <- bind_rows(full_bin_data_first_join, full_bin_data_second_join) %>%
  st_as_sf() %>% #convert to sf object 
  select(-street_name, -substreet_name) %>%
  rename("street_name" = "joining_street_name")

st_write(full_bin_data_sf, "cleaned_data/combined_bin_osm_data/combined_bin_osm.shp")