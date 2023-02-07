library(sf)
library(dplyr)
library(readr)
library(raster)
library(bcmaps)
library(rgdal)
library(fasterize)
library(readxl)
library(mapview)
library(WriteXLS)
library(foreign)
library(ggplot2)
library(ggnewscale)
library(viridis)
library(stars)
library(rgrass7)
library(exactextractr)
library(expss)
library(openxlsx)
library(cleangeo)
library(geos)
library(tidyr)
library(plyr)
library(bcdata)
library(tmap)
library(smoothr)
library(terra)

setwd("/Users/darkbabine/Dropbox (BVRC)/_dev/Water/WESP_Sample_Design")


OutDir <- 'out'
dataOutDir <- file.path(OutDir,'data')
#tileOutDir <- file.path(dataOutDir,'tile')
figsOutDir <- file.path(OutDir,'figures')
spatialOutDirP <- file.path(OutDir,'spatial')
SpatialDir <- file.path('data','spatial')
DataDir <- 'data'
GISLibrary<- file.path('/Users/darkbabine/ProjectLibrary/Library/GISFiles/BC')
DrawDir <- file.path('../WESP_Sample_Draw/data')

dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
#dir.create(file.path(tileOutDir), showWarnings = FALSE)
dir.create(file.path(figsOutDir), showWarnings = FALSE)
dir.create(DataDir, showWarnings = FALSE)
dir.create("tmp", showWarnings = FALSE)
dir.create(file.path(spatialOutDirP), showWarnings = FALSE)


##########
options(timeout=180)

#source("header.R")
#Run Provincial scale scripts only once
#source('01_load.R')
#source('02_cleanRoads_Prov.R')
#source('02_clean_disturb_Prov.R')

#Name of Wetland Area -"Taiga_Planes_Base" "Boreal_Plains_Base" "SIM_Base" "SIM_Less30_Base"
#"GD_Base" "Sub_Boreal"
#WetlandArea<-'GD_Base_Est'
#WetlandAreaDir<-'GD_Base_Est'
#WetlandArea<-'GD_Base'
#WetlandAreaDir<-'GD_Base'
#WetlandArea<-'SIM_Base'
#WetlandAreaDir<-'SIM_Base'
#WetlandArea<-c('Taiga_Planes_Base','Boreal_Plains_Base')
#WetlandAreaDir<-'Taiga_Boreal_Plains'
WetlandArea<-'Sub_Boreal'
WetlandAreaDir<-'Sub_Boreal'

#Set up unique directories for EcoProvince output
spatialOutDir <- file.path('out','spatial',WetlandAreaDir)
dataOutDir <- file.path(OutDir,'data',WetlandAreaDir)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(spatialOutDir), showWarnings = FALSE)
tempAOIDir<-paste0("tmp/",WetlandAreaDir)
dir.create(tempAOIDir, showWarnings = FALSE)

#Name of EcoProvince - "SOUTHERN ALASKA MOUNTAINS" "NORTHERN BOREAL MOUNTAINS" "TAIGA PLAINS"
#"BOREAL PLAINS" "SUB-BOREAL INTERIOR" "SOUTHERN INTERIOR MOUNTAINS" "SOUTHERN INTERIOR"           "COAST AND MOUNTAINS"         "GEORGIA DEPRESSION"
#"NORTHEAST PACIFIC" "CENTRAL INTERIOR"
#EcoPN<-c("BOREAL PLAINS","TAIGA PLAINS")
EcoPN<-c("SUB-BOREAL INTERIOR")
#EcoPN<-c("SOUTHERN INTERIOR MOUNTAINS")
#EcoPN<-c("GEORGIA DEPRESSION")
AOIin <- bcmaps::ecoprovinces() %>%
  dplyr::filter(ECOPROVINCE_NAME %in% EcoPN) %>%
  st_union() %>%
  st_buffer(dist=1000)#modified AOI to capture wetlands on boundaries of AOI
AOI<-st_as_sf(AOIin)

############
FWCP.r<-rast(file.path(spatialOutDir,"FWCP.r.tif"))

FWCP_Patch<-rast(file.path(spatialOutDir,"FWCP_Patch.tif"))
#NakazdliCabins_50km<-st_read(file.path(spatialOutDirP,"NakazdliCabins_50km.gpkg"))

#FWCP_Patchsm<-FWCP_Patch %>%
#  terra::crop(NakazdliCabins_50km) %>%
#  terra::mask(vect(NakazdliCabins_50km))

#zonalIn<-terra::cellSize(FWCP_Patchsm, mask=TRUE, unit="ha")
#FWCP_Zonal<-terra::zonal(cellSize(FWCP_Patch, unit="ha"), FWCP_Patch, sum, as.raster=TRUE)
#FWCP_large<-ifel(FWCP_Zonal<0.26, NA, FWCP_Patch)
#writeRaster(FWCP_large, file.path(spatialOutDir,"FWCP_large.tif"), overwrite=TRUE)

FWCP.tp<-as.polygons(FWCP_Patch, dissolve=TRUE, values=TRUE, na.rm=TRUE)
#FWCP.tp<-as.polygons(FWCP_large, dissolve=TRUE, values=TRUE, na.rm=TRUE)
writeVector(FWCP.tp, file.path(spatialOutDir,"FWCP.tp.gpkg"), overwrite=TRUE)
FWCP.tp<-vect(file.path(spatialOutDir,"FWCP.tp.gpkg"))

#convert to sf and add attributes
FWCP.p<- FWCP.tp %>%
  sf::st_as_sf() %>%
  mutate(area_Ha=as.numeric(st_area(.)*0.0001)) %>%
  mutate(wet_idn=seq.int(nrow(.))) %>%
  mutate(wet_id=patches) %>%
  mutate(WTLND_ID=paste0("FWCP_",wet_id)) #%>%
write_sf(FWCP.p, file.path(spatialOutDir,"FWCP.p.gpkg"))

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken #


# mapview(FWCP.p)
FWCP.p<-st_read(file.path(spatialOutDir,"FWCP.p.gpkg"))
start.time <- Sys.time()
#Smooth the raster conversion output using the 'spline' method
# other options are the  kernel and chaikin methods, but spline is the
# most conservative approach maintains most area of raster
FWCP_spline<-smooth(FWCP.p, method='spline')
#add a 1 metre buffer around the result to ensure kitty corner units are joined
# these units have same id due to 'direction=8' above
FWCP_splineB<-st_buffer(FWCP_spline, dist=1)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

#Combine PEM Wetlands with inventory Wetlands
Wets.i<-WetlandsAll %>%
  st_intersection(NakazdliCabins_50km) %>%
  mutate(wet_id=seq.int(nrow(.)))

#mapview(FWCP.p) + mapview(Wets.i)
FWCP_large<-rast(file.path(spatialOutDir,"FWCP_large.tif"))

Extract_combined <- dplyr::bind_rows(exact_extract(FWCP_large, Wets.i), .id = "wet_id") %>%
  as_tibble()

ExtractFull<-Extract_combined %>%
  mutate(wet_id = as.numeric(wet_id)) %>%
  mutate(FWCP_id=value) %>%
  dplyr::group_by(wet_id, FWCP_id) %>%
  dplyr::summarise(overlap = round(sum(coverage_fraction))*0.0625) %>%
  right_join(Wets.i) %>%
  mutate(pcOverlap=round(overlap/area_Ha*100)) %>%
  dplyr::select(wet_id,FWCP_id,overlap,area_Ha, pcOverlap)

Extract_wet <- ExtractFull %>% group_by(wet_id) %>%
  dplyr::summarize(PEM_wets = paste(sort(unique(FWCP_id)),collapse=", "), nPems=n()-1)

PEMs_in_wet<-as.numeric(unlist(list(strsplit(Extract_wet$PEM_wets, ","))))

FWCP_alone<-FWCP_splineB %>%
  dplyr::filter(!wet_id %in% PEMs_in_wet)

write_sf(FWCP_alone, file.path(spatialOutDir,"FWCP_alone.gpkg"))









