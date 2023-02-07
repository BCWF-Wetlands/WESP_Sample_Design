# Copyright 2022 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

roads_file <- file.path(spatialOutDirP,"roadsSR.tif")
if (!file.exists(roads_file)) {
  roads_sf_in<-read_sf(file.path(spatialOutDirP,"roads_clean.gpkg"))

  #Check the types
  unique(roads_sf_in$DRA_ROAD_CLASS)
  unique(roads_sf_in$DRA_ROAD_SURFACE)
  unique(roads_sf_in$OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE)

  ### Check Petro roads
  #Appears petro roads are typed with SURFACE and CLASSS
  table(roads_sf_in$DRA_ROAD_SURFACE,roads_sf_in$OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE)
  table(roads_sf_in$DRA_ROAD_CLASS,roads_sf_in$OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE)

  #Additional petro road checks
  #Check if all petro roads have a OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE
  tt<-roads_sf_in %>%
    st_drop_geometry() %>%
    dplyr::filter(is.na(DRA_ROAD_CLASS))

  Petro_Tbl <- st_set_geometry(roads_sf_in, NULL) %>%
    dplyr::count(OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE, LENGTH_METRES)

  roads_sf_petro <- roads_sf_in %>%
    mutate(DRA_ROAD_SURFACE=if_else(is.na(OG_DEV_PRE06_OG_PETRLM_DEV_RD_PRE06_PUB_ID),DRA_ROAD_SURFACE,'OGC')) %>%
    mutate(DRA_ROAD_CLASS=if_else(is.na(OG_DEV_PRE06_OG_PETRLM_DEV_RD_PRE06_PUB_ID),DRA_ROAD_CLASS,OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE))

  Petro_Tbl <- st_set_geometry(roads_sf_petro, NULL) %>%
    dplyr::count(DRA_ROAD_SURFACE, DRA_ROAD_CLASS)
  #### End Petro road check

  #Eliminate non-summer roads
  notRoadsCls <- c("ferry", "water", "Road Proposed","WINT")
  notRoadsSurf<-c("boat")
  notWinter<-c("WINT")

  roads_sf_1<-roads_sf_in %>%
    filter(!DRA_ROAD_CLASS %in% notRoadsCls,
           !DRA_ROAD_SURFACE %in% notRoadsSurf,
           !OG_DEV_PRE06_PETRLM_DEVELOPMENT_ROAD_TYPE %in% notWinter)

  HighUseCls<-c("Road arterial major","Road highway major", "Road arterial minor","Road highway minor",
                "Road collector major","Road collector minor","Road ramp","Road freeway",
                "Road yield lane")

  ModUseCls<-c("Road local","Road recreation","Road alleyway","Road restricted",
               "Road service","Road resource","Road driveway","Road strata",
               "Road resource demographic", "Road strata","Road recreation demographic", "Trail Recreation",
               "Road runway", "Road runway non-demographic", "Road resource non-status","Road unclassified or unknown")

  LowUseCls<-c("Road lane","Road skid","Road trail","Road pedestrian","Road passenger",
               "Trail", "Trail demographic","Trail skid", "Road pedestrian mall")

  HighUseSurf<-c("paved")
  ModUseSurf<-c("loose","rough","unknown")
  LowUseSurf<-c("overgrown","decommissioned","seasonal")

  #Add new attribute that holds the use classificationr
  roads_sf <- roads_sf_1 %>%
    mutate(RoadUse = case_when((DRA_ROAD_CLASS %in% HighUseCls & DRA_ROAD_SURFACE %in% HighUseSurf) ~ 1, #high use
                               (DRA_ROAD_CLASS %in% LowUseCls | DRA_ROAD_SURFACE %in% LowUseSurf |
                                  #(DRA_ROAD_SURFACE %in% ModUseSurf & is.na(DRA_ROAD_NAME_FULL)) |
                                  (is.na(DRA_ROAD_CLASS) & is.na(DRA_ROAD_SURFACE))) ~ 3,#low use
                               TRUE ~ 2)) # all the rest are medium use

  #Check the assignment
  Rd_Tbl <- st_set_geometry(roads_sf, NULL) %>%
    dplyr::count(DRA_ROAD_SURFACE, DRA_ROAD_CLASS, is.na(DRA_ROAD_NAME_FULL), RoadUse)

  #Data check
  nrow(roads_sf)-nrow(roads_sf_1)
  table(roads_sf$RoadUse)

  # save as geopackage format for use in GIS and for buffer anlaysis below
  write_sf(roads_sf, file.path(spatialOutDirP,"roads_clean.gpkg"))

  #Use Stars to rasterize according to RoadUse and save as a tif
  #first st_rasterize needs a template to 'burn' the lines onto
  BCr_S <- read_stars(file.path(spatialOutDirP,'BCr_S.tif'), proxy=FALSE)
  template = BCr_S
  template[[1]][] = NA
  roadsSR<-stars::st_rasterize(roads_sf[,"RoadUse"], template)
  write_stars(roadsSR,dsn=file.path(spatialOutDirP,'roadsSR.tif'))
} else {
  #Read in raster roads with values 0-none, 1-high use, 2-moderate use, 3-low use)
  roadsSR<-raster(file.path(spatialOutDirP,'roadsSR.tif'))
  roads_sf<-st_read(file.path(spatialOutDirP,"roads_clean.gpkg"))
}


