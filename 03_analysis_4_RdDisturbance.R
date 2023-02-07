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

#Read in wetlands buffer and LandDisturb files
WetlandsB<-read_sf(file.path(spatialOutDir,"WetlandsB.gpkg"))
RdDisturb<-raster(file.path(spatialOutDir,'RdDisturb.tif'))
Wetlands<-read_sf(file.path(spatialOutDir,"Wetlands.gpkg"))
RdDisturb_LUT<-readRDS(file='tmp/RdDisturb_LUT')

#Take max disturbance and assign to wetland, such if any urban then urban disturbance, etc
#alternative is to take most common - but likley larger effect if more severe disturbance
#WetlandsE1 <- raster::extract(RdDisturb, WetlandsB, sp=TRUE)
#WetlandsE3 <- exact_extract(RdDisturb, WetlandsB2) - returns propotion of each
Wetlands_E <- data.frame(RdDisturbCode=exact_extract(RdDisturb, WetlandsB, 'max'))
#Wetlands_E <- data.frame(DisturbCode=exact_extract(RdDisturb, WetlandsB, 'mode'))
Wetlands_E$wet_id <-as.numeric(rownames(Wetlands_E))
Wetlands_rdD1 <- Wetlands %>%
  mutate(wet_id=as.numeric(rownames(WetlandsB))) %>%
  left_join(Wetlands_E) %>%
  left_join(RdDisturb_LUT)

Wetlands_rdD1$RdDisturbCode[is.na(Wetlands_rdD1$RdDisturbCode)] <- 0
table(Wetlands_rdD1$RdDisturbType)

#Now can check if a site has an observed landcover type
#drop the LandCCode - since it will be wrong for observed sites and rejoin the LUT to populate it correctly
Wetlands_rdD <- Wetlands_rdD1 %>%
  left_join(RdDisturb_LUT)

table(Wetlands_rdD$RdDisturbType)

write_sf(Wetlands_rdD, file.path(spatialOutDir,"Wetlands_rdD.gpkg"))

# make a list of unique land types
RdDisturb.ls <- Wetlands_rdD %>%
  st_drop_geometry() %>%
  dplyr::select(WTLND_ID, RdDisturbCode, RdDisturbType)
#unique(disturb.ls$DisturbType)
WriteXLS(RdDisturb.ls,file.path(dataOutDir,paste('RdDisturb.ls.xlsx',sep='')))

#Originally did modal of neighbourhood - most common
#changed to any disturbance adjacent to wetland
#fill.na <- function(x, i=13) {
#  if( is.na(x)[i] ) {
#    #return( modal(x, ties='highest',na.rm=TRUE))
#    return( sum(x, na.rm=TRUE))
#  } else {
#    return( round(x[i],0) )
#  }
#}
#Pass the fill.na function to raster::focal and check results.
#The pad argument creates virtual rows/columns of NA values to keep the
#vector length constant along the edges of the raster.
#This is why we can always expect the fifth value of the vector to be
#the focal value in a 3x3 window thus, the index i=5 in the fill.na function.
#Do the fill twice to nibble into large lakes sufficient to assign areas
#where wetlands may occur to their largest neighbour

#LandDisturbFilled2 <- focal(LandDisturbToFill, w = matrix(1,5,5), fun = fill.na,
#                           pad = TRUE, na.rm = FALSE )
#writeRaster(LandDisturbFilled2, filename=file.path(spatialOutDir,"LandDisturbFilled2.tif"), format="GTiff", overwrite=TRUE)
#LandDisturbFilled<-raster(file.path(spatialOutDir,"LandDisturbFilled2.tif"))
####
#Read in the point coverage of wetland centroids
#waterpt<-st_read(file.path(spatialOutDir,"waterptRoad.gpkg"))
#waterpt<-st_read(file.path(spatialOutDir,"waterpt.gpkg"))

#extract the raster value from the Land cover map
#disturb_pts <- raster::extract(LandDisturbFilled, waterpt, sp=TRUE) %>%
# st_as_sf() %>%
#  dplyr::rename(DisturbCode=LandDisturbFilled)

# If we want to sample 10 sites first we need to calculate the proportion of sites
# to sample within each variant

#prop.site <- disturb.ls %>%
#  group_by(DisturbType)%>%
#  dplyr::summarise(no.pts = n()) %>%
  #st_drop_geometry() %>%
#  mutate(perc = ceiling(no.pts / sum(no.pts)*100))

#WriteXLS(prop.site,file.path(dataOutDir,paste('ESILandDisturbxWetland.xlsx',sep='')))
#WriteXLS(prop.site,file.path(dataOutDir,paste('ESI_Wetland_Strata_Disturb.xlsx',sep='')),SheetNames='Disturbance')

gc()

