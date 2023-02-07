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

Wetlands<-read_sf(file.path(spatialOutDir,"Wetlands.gpkg"))

#Modify to use exactextract - way faster than st_intersection
Bedrockr<-raster(file.path(spatialOutDir,"Bedrockr.tif"))
#Number of 1ha road buffer cells in polygon
Wetlands_EbedR <- data.frame(bedR_areaHa=exact_extract(Bedrockr, Wetlands, 'sum'))
Wetlands_EbedR$wet_id <-seq.int(nrow(Wetlands_EbedR))

tt<- Wetlands_EbedR %>%
  dplyr::filter(bedR_areaHa>0)

granitic_bedrock <- Wetlands %>%
  left_join(Wetlands_EbedR) %>%
  #st_drop_geometry() %>%
  #mutate(pcentInPriv=round(priv_areaHa/area_Ha*100)) %>%
  dplyr::select(wet_id, WTLND_ID, bedR_areaHa, area_Ha) %>%
  #mutate(pcentInPriv=round(priv_areaHa/area_Ha*100)) %>%
  #mutate(win500=if_else((pcentIn500Buf>75.00),1,0))
  #mutate(granitic_bedrock=if_else(is.na(bedR_areaHa), 0, round(as.numeric(bedR_areaHa/area_Ha)*100))) %>%
  mutate(granitic_bedrock=if_else(is.na(bedR_areaHa) | bedR_areaHa==0, 'No', 'Yes')) %>%
  dplyr::select(WTLND_ID,granitic_bedrock)

write_sf(granitic_bedrock, file.path(spatialOutDir,"granitic_bedrock.gpkg"))

WetlandsBedRock<- granitic_bedrock %>%
  st_drop_geometry() %>%
  dplyr::select(WTLND_ID, granitic_bedrock)

WriteXLS(WetlandsBedRock,file.path(dataOutDir,paste('BedRock.xlsx',sep='')))


