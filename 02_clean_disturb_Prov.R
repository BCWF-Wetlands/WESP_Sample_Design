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

#Provincial Human Disturbance Layers - compiled for CE
#Needs refinement to differentiate rural/urban and old vs young cutblocks, rangeland, etc.
dist_file<-file.path(spatialOutDirP,'disturbance_sfR.tif')
if (!file.exists(dist_file)) {
  disturbance_gdb <- list.files(file.path(DataDir,"PROVdata/Disturbance/CEF_Disturbance/Disturbance_2021"), pattern = ".gdb", full.names = TRUE)[1]
  disturbance_list <- st_layers(disturbance_gdb)

  disturbance_sf1 <- read_sf(disturbance_gdb, layer = "BC_CEF_Human_Disturb_BTM_2021_merge")
  disturbance_sf1<-readRDS('tmp/disturbance_sf')

  disturbance_sf <- disturbance_sf1 #%>%
   # st_intersection(AOI)

  #Fasterize disturbance subgroup
  disturbance_Tbl <- st_set_geometry(disturbance_sf, NULL) %>%
    dplyr::count(.,CEF_DISTURB_SUB_GROUP, CEF_DISTURB_GROUP)

  #Fix non-unique sub group codes
  disturbance_sf <- disturbance_sf %>%
    mutate(disturb = case_when(!(CEF_DISTURB_SUB_GROUP %in% c('Baseline Thematic Mapping', 'Historic BTM', 'Historic FAIB', 'Current FAIB')) ~ CEF_DISTURB_GROUP,
                               (CEF_DISTURB_GROUP == 'Agriculture_and_Clearing' & CEF_DISTURB_SUB_GROUP == 'Baseline Thematic Mapping') ~ 'Agriculture_and_Clearing',
                               (CEF_DISTURB_GROUP == 'Mining_and_Extraction' & CEF_DISTURB_SUB_GROUP == 'Baseline Thematic Mapping') ~ 'Mining_and_Extraction',
                               (CEF_DISTURB_GROUP == 'Urban' & CEF_DISTURB_SUB_GROUP == 'Baseline Thematic Mapping') ~ 'Urban',
                               (CEF_DISTURB_GROUP == 'Cutblocks' & CEF_DISTURB_SUB_GROUP == 'Current FAIB') ~ 'Cutblocks_Current',
                               (CEF_DISTURB_GROUP == 'Cutblocks' & CEF_DISTURB_SUB_GROUP == 'Historic FAIB') ~ 'Cutblocks_Historic',
                               (CEF_DISTURB_GROUP == 'Cutblocks' & CEF_DISTURB_SUB_GROUP == 'Historic BTM') ~ 'Cutblocks_Historic',
                               TRUE ~ 'Unkown'))

  disturbance_Tbl <- st_set_geometry(disturbance_sf, NULL) %>%
    dplyr::count(.,CEF_DISTURB_SUB_GROUP, CEF_DISTURB_GROUP, disturb)
  WriteXLS(disturbance_Tbl,file.path(DataDir,'disturbance_Tbl.xlsx'))

  Unique_disturb<-unique(disturbance_sf$disturb)
  AreaDisturbance_LUT<-data.frame(disturb_Code=1:length(Unique_disturb),disturb=Unique_disturb)

  #Write out LUT
  WriteXLS(AreaDisturbance_LUT,file.path(DataDir,'AreaDisturbance_LUT.xlsx'))

  AreaDisturbance_LUT<-data.frame(read_excel(file.path(DataDir,'AreaDisturbance_LUT.xlsx'))) %>%
    dplyr::select(disturb,disturb_code=disturb_Code,ID=disturbRank)

  disturbance_sfR1 <- disturbance_sf %>%
    left_join(AreaDisturbance_LUT) %>%
    st_cast("MULTIPOLYGON")
  write_sf(disturbance_sfR1, file.path(spatialOutDir,"disturbance_sfR1.gpkg"))

  disturbance_sfR<- fasterize(disturbance_sfR1, BCr, field="ID")
  disturbance_sfR[is.na(disturbance_sfR)]<-0

  #write_sf(disturbance_sf, file.path(spatialOutDirP,"disturbance_sf.gpkg"))
  writeRaster(disturbance_sfR, filename=file.path(spatialOutDirP,'disturbance_sfR'), format="GTiff", overwrite=TRUE)

} else {
  disturbance_sfR<-raster(file.path(spatialOutDirP,'disturbance_sfR.tif'))
  }
