# A basic similarity search workflow

## Preparing the computational environment

library(magrittr)
library(ggplot2)

## Preparing the input data

### Generating the the spatial prediction grid

#### Defining the research area

research_area_4326 <- sf::st_polygon(
  list(
    cbind(
      c(35.91,11.73,-11.74,-15.47,65.06,65.26,65.56,35.91), # longitudes
      c(25.61,28.94, 31.77, 62.73,65.67,44.56,28.55,25.61)  # latitudes

    )
  )
) %>% sf::st_sfc(crs = 4326)

# mapview::mapview(research_area_4326)

worldwide_land_outline_4326 <- rnaturalearth::ne_download(
  scale = 50, type = 'land', category = 'physical',
  returnclass = "sf"
)

research_land_outline_4326 <- sf::st_intersection(
  worldwide_land_outline_4326,
  research_area_4326
)


#### Projecting the spatial data

research_land_outline_3035 <- research_land_outline_4326 %>% sf::st_transform(crs = 3035)



### Reading the input samples

samples_basic <- readr::read_csv("/home/xiaowen/KNC_mobest/021225_defaultpara/mobestinput_WE.csv")

samples_projected <- samples_basic %>%
  sf::st_as_sf(
    coords = c("Longitude", "Latitude"),
    crs = 4326
  ) %>%
  sf::st_transform(crs = 3035) %>%
  dplyr::mutate(
    x = sf::st_coordinates(.)[,1],
    y = sf::st_coordinates(.)[,2]
  ) %>%
  sf::st_drop_geometry()

## Specifying the search sample

search_samples <- samples_projected %>%
  dplyr::filter(
    Sample_ID %in% c("KNC031_ss_RM", "KNC213_ss","KNC269_ss","KNC232_ss","KNC032_ss_RM","KNC203_ss_RM")
  )

#search_samples


## Running mobest's interpolation and search function

### Building the input data for the interpolation

#### Independent and dependent positions

ind <- mobest::create_spatpos(
  id = samples_projected$Sample_ID,
  x  = samples_projected$x,
  y  = samples_projected$y,
  z  = samples_projected$Date_BC_AD_Median
)
dep <- mobest::create_obs(
  C1 = samples_projected$MDS_C1,
  C2 = samples_projected$MDS_C2
)
#ind

search_ind <- mobest::create_spatpos(
  id = search_samples$Sample_ID,
  x  = search_samples$x,
  y  = search_samples$y,
  z  = search_samples$Date_BC_AD_Median
)
search_dep <- mobest::create_obs(
  C1 = search_samples$MDS_C1,
  C2 = search_samples$MDS_C2
)

#search_ind
#search_dep




#### Kernel parameter settings

kernset <- mobest::create_kernset(
  C1 = mobest::create_kernel(
    dsx = 300 * 1000, dsy = 300 * 1000, dt = 1300,
    g = 0.067
  ),
  C2 = mobest::create_kernel(
    dsx = 100 * 1000, dsy = 100 * 1000, dt = 600,
    g = 0.283
  )
)


# Improving the similarity search map plot

spatial_pred_grid <- mobest::create_prediction_grid(
  research_land_outline_3035,
  spatial_cell_size = 20000
)

search_result <- mobest::locate(
  independent        = ind,
  dependent          = dep,
  kernel             = kernset,
  search_independent = search_ind,
  search_dependent   = search_dep,
  search_space_grid  = spatial_pred_grid,
  search_time        = 0,
  search_time_mode   = "relative"
)

#search_result
#stop()
search_product <- mobest::multiply_dependent_probabilities(search_result)

research_area_3035 <- research_area_4326 %>% sf::st_transform(3035)
research_area_3035 <- research_area_3035 %>% sf::st_segmentize(dfMaxLength = 10000)
saveRDS(search_product,"search_product_xiaowen_1.rds")
saveRDS(research_area_3035,"research_area_xiaowen_1.rds")

p <- ggplot() +
  geom_raster(
    data = search_product,
    mapping = aes(x = field_x, y = field_y, fill = probability)
  ) +
  scale_fill_viridis_c() +
  geom_sf(
    data = research_area_3035,
    fill = NA, colour = "red",
    linetype = "solid", linewidth = 1
  ) +
  #geom_point(
  #  data = search_samples %>% dplyr::rename(search_id = Sample_ID),
  #  mapping = aes(x, y),
  #  colour = "red"
  #) +
  theme_bw() +
  theme(
    axis.title = element_blank()
  ) +
  guides(
    fill = guide_colourbar(title = "Similarity\nsearch\nprobability")
  ) +
  facet_wrap(
    ~search_id,
    ncol = 2,
    labeller = labeller(
      search_id = c(
        "KNC031_ss_RM" = paste(
          "<KNC031> ~1600BC",
          "Kamenice, Middle-Late Bronze Age",
          "Search time: ~1600BC",
          sep = "\n"
        ),
        "KNC213_ss" = paste(
          "<KNC213> ~900BC",
          "Kamenice, Early Iron Age",
          "Search time: ~900BC",
          sep = "\n"
        ),
        "KNC269_ss" = paste(
          "<KNC269> ~900BC",
          "Kamenice, Early Iron Age",
          "Search time: ~900BC",
          sep = "\n"
        ),
        "KNC232_ss" = paste(
          "<KNC232> ~900BC",
          "Kamenice, Early Iron Age",
          "Search time: ~900BC",
          sep = "\n"
        ),
        "KNC032_ss_RM" = paste(
          "<KNC032> ~650BC",
          "Kamenice, Developed Iron Age",
          "Search time: ~650BC",
          sep = "\n"
        ),
        "KNC203_ss_RM" = paste(
          "<KNC203> ~650BC",
          "Kamenice, Developed Iron Age",
          "Search time: ~650BC",
          sep = "\n"
        )
      )
    )
  )

ggsave(
 filename = "KNC_search_map_neat_combined_WE_120226.png",
  plot = p,
  scale = 2.5, width = 2000, height = 2500, units = "px", dpi=600
)

# save(
#   dep, kernset, spatial_pred_grid, search_dep, research_area_3035,
#   file = "docs/data/simple_objects_snapshot.RData"
# )


