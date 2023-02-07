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

#Rasterize the Province for subsequent masking
# bring in BC boundary
bc <- bcmaps::bc_bound()
Prov_crs<-crs(bc)
#Prov_crs<-"+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

BCr_file <- file.path(spatialOutDirP,"BCr.tif")
if (!file.exists(BCr_file)) {
  BC<-bcmaps::bc_bound_hres(class='sf')
  saveRDS(BC,file='tmp/BC')
  ProvRast<-raster(nrows=15744, ncols=17216, xmn=159587.5, xmx=1881187.5,
                   ymn=173787.5, ymx=1748187.5,
                   crs=Prov_crs,
                   res = c(100,100), vals = 1)
  ProvRast25<-raster(nrows=62976, ncols=68864, xmn=159587.5, xmx=1881187.5,
                     ymn=173787.5, ymx=1748187.5,
                     crs=Prov_crs,
                     res = c(25,25), vals = 1)
  ProvRast_S<-st_as_stars(ProvRast)
  write_stars(ProvRast_S,dsn=file.path(spatialOutDirP,'ProvRast_S.tif'))
  BCr <- fasterize(BC,ProvRast)
  BCr25 <- fasterize(BC,ProvRast25)
  #Linear rasterization of roads works better using the stars package
  BCr_S <-st_as_stars(BCr)
  write_stars(BCr_S,dsn=file.path(spatialOutDirP,'BCr_S.tif'))
  writeRaster(BCr, filename=BCr_file, format="GTiff", overwrite=TRUE)
  writeRaster(BCr25, filename=file.path(spatialOutDirP,"BCr25.tif"), format="GTiff", overwrite=TRUE)
  writeRaster(ProvRast, filename=file.path(spatialOutDirP,'ProvRast'), format="GTiff", overwrite=TRUE)
  writeRaster(ProvRast25, filename=file.path(spatialOutDirP,'ProvRast25'), format="GTiff", overwrite=TRUE)
} else {
  BCr <- raster(BCr_file)
  BCr25 <- raster(file.path(spatialOutDirP,"BCr25.tif"))
  ProvRast<-raster(file.path(spatialOutDirP,'ProvRast.tif'))
  ProvRast25<-raster(file.path(spatialOutDirP,'ProvRast25.tif'))
  BCr_S <- read_stars(file.path(spatialOutDirP,'BCr_S.tif'))
  BC <-readRDS('tmp/BC')
}

crs(ProvRast)<-crs(bcmaps::bc_bound())
saveRDS(ProvRast,file='tmp/ProvRast')

ws <- get_layer("wsc_drainages", class = "sf") #%>%

wetland.pt<-st_read(file.path(spatialOutDir,"wetland.pt.gpkg"))
Wetlands<-st_read(file.path(spatialOutDir,"Wetlands.gpkg"))
WetlandsB<-st_read(file.path(spatialOutDir,"WetlandsB.gpkg"))

#Watersheds in EcoProvince
#merge smalle slivers from intersection with AOI to their larger neighbour
AOI_ws_in<-ws %>%
  st_intersection(AOIin) %>%
  #Bust up the geometry into its constituent parts
  st_cast("MULTIPOLYGON") %>%
  st_cast("POLYGON") %>%
  mutate(areaHa=as.numeric(st_area(.)/10000))
#pull out the large watersheds, then the small watershed pieces
AOI_ws_large<-AOI_ws_in %>%
  dplyr::filter(areaHa>200000)%>%
  mutate(Large_id=as.numeric(rownames(.)))
AOI_ws_small<-AOI_ws_in %>%
  dplyr::filter(areaHa<200000) %>%
  mutate(Small_id=as.numeric(rownames(.)))
#For each small find its largest neighbout
neigb_int<-as.data.frame(st_intersects(AOI_ws_small,AOI_ws_large)) %>%
  dplyr::rename(Small_id=row.id) %>%
  dplyr::rename(Large_id=col.id) %>%
  left_join(st_drop_geometry(AOI_ws_large)) %>%
  group_by(Small_id) %>%
  mutate(new_value = Large_id[which.max(areaHa)]) %>%
  dplyr::summarise(n=n(),Large_id=first(new_value)) %>%
  ungroup()
#Join the neighbour list to the small so they can be combined with thier large neighbour
AOI_ws_small<-AOI_ws_small %>%
  left_join(neigb_int) %>%
  dplyr::select(-c(n,Small_id))
#bind the small and large together then group by the Large_id to absorbe the smaller units
AOI_ws<-rbind(AOI_ws_large,AOI_ws_small) %>%
  group_by(Large_id) %>%
  dplyr::summarise(n=n())
mapview(AOI_ws) #+mapview(Wetlands)

message('Breaking')
break

#Read DEM - use BC maps to build

DEM_file <- file.path(spatialOutDir,paste0('DEMtp_',WetlandAreaShort,'tif'))
if (!file.exists(DEM_file)) {
  DEM<-bcmaps::cded_raster(aoi=AOI) #crs=4269
  writeRaster(DEM, filename=file.path(spatialOutDir,paste0('DEM_',WetlandAreaShort)), format="GTiff", overwrite=TRUE)
  DEM.t<-terra::rast(file.path(spatialOutDir,paste0('DEM_',WetlandAreaShort,'.tif')))
  crs(DEM.t, proj=TRUE)
  DEM.tp<-terra::project(DEM.t,crs(ProvRast))
  writeRaster(DEM.tp, filename=file.path(spatialOutDir,paste0('DEMtp_',WetlandAreaShort,'.tif')), overwrite=TRUE)

  } else
DEM.tp<-raster(file.path(spatialOutDir,paste0('DEMtp_',WetlandAreaShort,'.tif')))

#cells are odd - need new Provincial DEM
#DEM_BC <- raster(file.path(ProvData,'BC_DEM/Full_Province_DEM.tif'))
#saveRDS(DEM_BC, file = 'tmp/DEM_BC')


#From bcmaps - read fails maybe a band width thing
#AOI_R <- cded_raster(ws_AOIR)
#DEM - use temporarily since 100m x 100m
#DEM<-raster(file.path(DataDir,'PROVdata/DEM/DEM.tif'))

####
TestAOI<-ws %>%
  dplyr::filter(SUB_DRAINAGE_AREA_NAME=='Williston Lake' &
                  SUB_SUB_DRAINAGE_AREA_NAME=='Nation')
#unique(AOIin$SUB_SUB_DRAINAGE_AREA_NAME)

