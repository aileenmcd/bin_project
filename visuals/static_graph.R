unique(combined_bin_osm$street_name)

combined_bin_osm %>%
  filter(cumul_date == 40, street_name %in% c("george street", "leith street")) %>%
  ggplot(aes(x = street_name, y = cumul_total_weight_kg)) +
  geom_col() +
  scale_y_continuous(breaks = c(120, 983) , labels = c('baby elephant (120)', 'vauxhall corsa (983)')) +
  labs(y = "Cumulative rubbish weight (kg)", x = "Street names") + 
  theme_classic() +
  geom_text(aes(label = scales::comma(cumul_total_weight_kg)), vjust = -0.3)

#same colour in map and bar chart to correlate