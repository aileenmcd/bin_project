README
================

## Overview

Photo by
<a href="https://unsplash.com/@peter_cordes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Peter
Cordes</a> on
<a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

<img src="images/bin_pic.jpeg" width="60%" /><img src="images/peter-cordes-H-Qx6KAyuJQ-unsplash.jpg" width="60%" />

This is a project using data from a bin sensor project in Edinburgh when
public rubbish bins had sensors fitted so that bin lorry crews know when
they are full. A total of 323 litter bins in the city centre, Leith
Walk, Leith Links and Portobello Promenade were fitted with the sensors.
More can be found about the project
[here](https://www.heraldscotland.com/news/14745124.edinburgh-litter-bins-fitted-sensors-bin-lorry-crews-know-need-emptied/).
The data covers the period 3rd June 2016 to 9th August 2016.

Data is from Edinburgh Council Open Data Portal:
<https://data.edinburghopendata.info/dataset/litter-bin-sensor-data>
(available under the Open Government License v3.0).

Project aims:

  - Learning about OpenStreetMap data via the use of `osmdata` package
    [page](https://github.com/ropensci/osmdata)
  - Explore how the volume/weight of rubbish changes over the time
    period.
  - Explore how the volume/weight of rubbish compares between bin
    locations.
  - Create small interactive plots for users to explore data.

Attribution: The learning/code using the OpenStreetMap data come from
this [blog](https://taraskaduk.com/posts/2021-01-18-print-street-maps/)
(Reference: Kaduk (2021, Jan. 18). Taras Kaduk: Print Personalized
Street Maps Using R).

Notes on some of the locations:

  - Decided to concentrate on Edinburgh City Centre so did not include
    locations in Portobello.
  - Gayfield Square Park, Leith Links, Princes Street Gardens East,
    Princes Street Gardens West are all parks so decide to remove from
    analysis as found visualising volume via thickness of line of street
    did not work well for parks (since these are filled polygons).
  - Restalrig railway path is a cycleway on OSM so choose to also
    remove.
