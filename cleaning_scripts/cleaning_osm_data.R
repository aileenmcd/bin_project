#code from https://taraskaduk.com/posts/2021-01-18-print-street-maps/
library(osmdata)
library(tidyverse)
library(sf)
library(lwgeom) #for the water area calculation 
library(gganimate)

#set place 
place <- "Edinburgh UK"

#set thickness depends on type of street (e.g. motorways to be drawn thinker than pedestrian streets
highway_sizes <- tibble::tribble(
  ~highway, ~highway_group, ~size,
  "motorway",        "large",   0.5,
  "motorway_link",        "large",   0.3,
  "primary",        "large",   0.5,
  "primary_link",        "large",   0.3,
  "secondary",       "medium",   0.3,
  "secondary_link",       "medium",   0.3,
  "tertiary",       "medium",   0.3,
  "tertiary_link",       "medium",   0.3,
  "residential",        "small",   0.2,
  "living_street",        "small",   0.2,
  "unclassified",        "small",   0.2,
  "service",        "small",   0.2,
  "footway",        "small",   0.2,
  "pedestrian", "small", 0.2
)



# get streets
streets_osm <- opq(place) %>% #Build an Overpass query
  add_osm_feature(key = "highway", 
                  value = highway_sizes$highway) %>%
  osmdata_sf()

#get names of Edinburgh streets
unique(streets_osm$osm_lines$name)

#added name.left as there was some small streets which are subparts of other streets (investigated these missing streets using https://www.openstreetmap.org/way/183699651 and it highlighted this 'name.left' variable)
streets <- streets_osm$osm_lines %>% 
  dplyr::select(osm_id, name, highway, maxspeed, oneway, surface, name.left) %>% 
  mutate(length = as.numeric(st_length(.))) %>% 
  left_join(highway_sizes, by="highway") 


# get railways
railways_osm <- opq(place) %>%
  add_osm_feature(key = "railway", value="rail") %>%
  osmdata_sf()

railways <- railways_osm$osm_lines %>% 
  dplyr::select()


# get rivers
river_osm <- opq(place) %>%
  add_osm_feature(key = "waterway", value = c("river", "riverbank")) %>%
  osmdata_sf() %>% 
  unname_osmdata_sf()

# get water - extra step compared to railways and streets since is a ploygon since polygon
water_osm <- opq(place) %>%
  add_osm_feature(key = "natural", value = "water") %>%
  osmdata_sf() %>% 
  unname_osmdata_sf()

water <- c(water_osm, river_osm) %>% 
  .$osm_multipolygons %>% 
  select(osm_id, name) %>% 
  mutate(area = st_area(.)) %>% #uses lwgeom library
  filter(area >= quantile(area, probs = 0.75))   # this filter gets rid of tiny isolated lakes

#got key/value pairs from https://wiki.openstreetmap.org/wiki/Map_features
green_osm <- opq(place) %>%
  add_osm_feature(key = "landuse", value = c("recreation_ground", "village_green", "grass", "greenfield", "meadow", "forest")) %>%
  osmdata_sf() %>% 
  unname_osmdata_sf()

green <- c(green_osm) %>% 
  .$osm_polygons %>% 
  select(osm_id, name) %>% 
  mutate(area = st_area(.))  #uses lwgeom library

park_osm <- opq(place) %>%
  add_osm_feature(key = "leisure", value = c("park")) %>%
  osmdata_sf() %>% 
  unname_osmdata_sf()

park_poly <- c(park_osm) %>% 
  .$osm_polygons %>% 
  select(osm_id, name) %>% 
  mutate(area = st_area(.))  #uses lwgeom library

park_multipoly <- c(park_osm) %>% 
  .$osm_multipolygons %>% 
  select(osm_id, name) %>% 
  mutate(area = st_area(.)) 


# Box ---------------------------------------------------------------------

# decide cut off for centre of Edinburgh (chosen via visual insepction on google maps) 
min_max_coords <- c(ymin= 55.928479867725436,
          xmin= -3.227624857214751,
          ymax= 55.98333902701634,
          xmax= -3.140735628435386)


#there are repeats of some roads because can be broken up/classified as different categories (seen in the'highway' variable)
#decided to take the longest length values of each
streets_simplified <- streets %>%
  group_by(name, name.left) %>%
  mutate(max_length = max(length)) %>%
  filter(length == max_length) %>%
  rename("substreet_name" = "name.left", "street_name" = "name") %>%
  mutate(substreet_name = str_to_lower(substreet_name)) %>%
  mutate(street_name = str_to_lower(street_name)) 



# Crop all the roads/water/rail to boundary set and write to a .shp file 
# Write a function as repeat this step 
crop_and_write <- function(sf_dataframe, cut_coords) {
  cropped_sf_dataframe <- st_crop(sf_dataframe, cut_coords) 
  st_write(cropped_sf_dataframe, paste0("cleaned_data/osm_data/",deparse(substitute(sf_dataframe)),".shp"))
}
  
crop_and_write(water, min_max_coords)
crop_and_write(streets_simplified, min_max_coords)
crop_and_write(railways, min_max_coords)
crop_and_write(green, min_max_coords)
crop_and_write(park_poly, min_max_coords)

#park is a multipoly so cropping wasn't working like others
st_write(park_multipoly, "cleaned_data/osm_data/park_multipoly.shp")


# Plotting theme ----------------------------------------------------------------

blankbg <-theme(axis.line=element_blank(),
                axis.text.x=element_blank(),
                axis.text.y=element_blank(),
                axis.ticks=element_blank(),
                axis.title.x=element_blank(), 
                axis.title.y=element_blank(),
               # legend.position = "none",
                plot.background=element_blank(),
                panel.grid.minor=element_blank(),
                panel.background=element_blank(),
                panel.grid.major=element_blank(),
                plot.margin = unit(c(t=2,r=2,b=2,l=2), "cm"),
                plot.caption = element_text(color = "grey20", size = 12, 
                                            hjust = .5, face = "plain", 
                                            family = "Didot"),
                panel.border = element_blank()
)

