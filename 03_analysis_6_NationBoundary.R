# Copyright 2020 Province of British Columbia
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


Williston <-st_read(file.path(spatialOutDir,"Williston.gpkg")) %>%
  st_intersection(AOI)
McLeodLakeTT <-st_read(file.path(spatialOutDirP,"McLeodLakeTT.gpkg")) %>%
  st_intersection(AOI)

waterpt<-st_read(file.path(spatialOutDir,"wetland.pt.gpkg"))

Williston_pts <- st_intersection(waterpt, Williston) %>%
  st_drop_geometry() %>%
  mutate(Nation='Williston') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(Williston_pts,file.path(dataOutDir,paste('Williston_pts.xlsx',sep='')))

McLeodLakeTT_pts <- st_intersection(waterpt, McLeodLakeTT) %>%
  st_drop_geometry() %>%
  mutate(Nation='McLeodLakeTT') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(McLeodLakeTT_pts,file.path(dataOutDir,paste('McLeodLakeTT_pts.xlsx',sep='')))

Will_McLeod_pts <- st_intersection(waterpt, Will_McLeod) %>%
  st_drop_geometry() %>%
  mutate(Nation='McLeodLakeTT') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(Will_McLeod_pts,file.path(dataOutDir,paste('Will_McLeod_pts.xlsx',sep='')))

message('Breaking')
break

##############
TeaSpot <-st_read(file.path(spatialOutDirP,"TeaSpot.gpkg")) %>%
  st_intersection(AOI)
NakazdliCabins_50km <-st_read(file.path(spatialOutDirP,"NakazdliCabins_50km.gpkg")) %>%
  st_intersection(AOI)
McLeodLakeFN_50km <-st_read(file.path(spatialOutDirP,"McLeodLakeFN_50km.gpkg")) %>%
  st_intersection(AOI)
FtStJames_50K <-st_read(file.path(spatialOutDirP,"FtStJames_50K.gpkg")) %>%
  st_intersection(AOI)
MoberlyLake_50K <-st_read(file.path(spatialOutDirP,"MoberlyLake_50K.gpkg")) %>%
  st_intersection(AOI)

#Clean up the Nation priority areas and make single targets so number of samples can
# be set for each
#Prioritization order Nakazdli, McLeodLake, FtStJames
NakazdliCabins<-NakazdliCabins_50km
McLeodLakeFN<- McLeodLakeFN_50km %>%
  st_difference(st_union(NakazdliCabins)) %>%
  st_buffer(0)
FtStJames<- FtStJames_50K %>%
  st_difference(st_union(McLeodLakeFN)) %>%
  st_difference(st_union(NakazdliCabins)) %>%
  st_buffer(0)
Saulteau<-MoberlyLake_50K

mapview(McLeodLakeFN)+mapview(NakazdliCabins)+mapview(FtStJames)+mapview(Saulteau)

Nakadli_pts <- st_intersection(waterpt, NakazdliCabins) %>%
  st_drop_geometry() %>%
  mutate(Nation='NakazdliCabins') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(Nakadli_pts,file.path(dataOutDir,paste('Nakadli_pts.xlsx',sep='')))

McLeodLakeFN_pts <- st_intersection(waterpt, McLeodLakeFN) %>%
  st_drop_geometry() %>%
  mutate(Nation='McLeodLakeFN') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(McLeodLakeFN_pts,file.path(dataOutDir,paste('McLeodLakeFN_pts.xlsx',sep='')))

FtStJames_pts <- st_intersection(waterpt, FtStJames) %>%
  st_drop_geometry() %>%
  mutate(Nation='FtStJames') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(FtStJames_pts,file.path(dataOutDir,paste('FtStJames_pts.xlsx',sep='')))

Saulteau_pts <- st_intersection(waterpt, Saulteau) %>%
  st_drop_geometry() %>%
  mutate(Nation='Saulteau') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(Saulteau_pts,file.path(dataOutDir,paste('Saulteau_pts.xlsx',sep='')))

TeaSpot_pts <- st_intersection(waterpt, TeaSpot) %>%
  st_drop_geometry() %>%
  mutate(Nation='TeaSpot') %>%
  dplyr::select(WTLND_ID, Nation)
WriteXLS(TeaSpot_pts,file.path(dataOutDir,paste('TeaSpot_pts.xlsx',sep='')))

gc()
