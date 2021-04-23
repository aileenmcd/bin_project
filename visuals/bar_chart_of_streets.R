street1 <- "atholl crescent"
street2 <- "broughton street"
streets_chosen <- c(street1, street2)
date_chosen <- "2016-06-07"

cumulative_bin_data %>%
  filter(date == date_chosen, street_name %in% streets_chosen) %>%
  ggplot(aes(x = street_name, y = cum_total_vol_l3)) +
  geom_col()