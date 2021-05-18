library(tidyverse)
library(readxl)
library(data.table)

raw_data <- read_excel("raw_data/raw_bin_data.xlsx", skip = 2) %>%
  janitor::clean_names()

cleaned_data <- raw_data %>%
  select(id,site, site_name,address,   date_time_of_bin_collection_europe_london, 
         fill_level_before_collection_percent_nb_100_percent_is_actually_a_bin_thats_80_percent_full, 
         volume_litres3, weight_kg) %>%
  rename(date_time = date_time_of_bin_collection_europe_london) %>%
  rename(fill_level = fill_level_before_collection_percent_nb_100_percent_is_actually_a_bin_thats_80_percent_full) %>%
  rename(bin_id = site) %>%
  mutate(date = as.IDate(date_time)) %>%
  mutate(time = as.ITime(date_time)) %>%
  mutate(street_name = str_remove(address, "[0-9]+ ")) %>%
  mutate(street_name = str_to_lower(street_name)) #cases of Leith links vs Leith Links etc. 

address_level_bin_data <- cleaned_data %>%
  group_by(address, date) %>%
  summarise(total_vol = sum(volume_litres3)) %>%
  arrange(address, date) %>%
  mutate(cumul_total = cumsum(total_vol))

#some of the bins are at specific address level (e.g. 1 Leith Walk) but not all so aggregate up to street level for the analysis
street_level_bin_data <- cleaned_data %>%
  group_by(street_name, date) %>%
  summarise(total_vol_l3 = sum(volume_litres3), total_weight_kg = sum(weight_kg)) %>%
  arrange(street_name, date) 

write_csv(street_level_bin_data, "cleaned_data/bin_data/aggregated_bin_data.csv")