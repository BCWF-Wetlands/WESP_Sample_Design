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
F_OWN_PR<-raster(file.path(spatialOutDir,"F_OWN_PR.tif"))
#Number of 1ha road buffer cells in polygon
Wetlands_Epriv <- data.frame(priv_areaHa=exact_extract(F_OWN_PR, Wetlands, 'sum'))
Wetlands_Epriv$wet_id <-seq.int(nrow(Wetlands_Epriv))

tt<- Wetlands_Epriv %>%
  dplyr::filter(priv_areaHa>0)

private <- Wetlands %>%
  left_join(Wetlands_Epriv) %>%
  #st_drop_geometry() %>%
  #mutate(pcentInPriv=round(priv_areaHa/area_Ha*100)) %>%
  dplyr::select(wet_id, WTLND_ID, priv_areaHa, area_Ha) %>%
  #mutate(pcentInPriv=round(priv_areaHa/area_Ha*100)) %>%
  #mutate(win500=if_else((pcentIn500Buf>75.00),1,0))
  mutate(pct_private_ovlp=if_else(is.na(priv_areaHa), 0, round(as.numeric(priv_areaHa/area_Ha)*100))) %>%
  dplyr::select(WTLND_ID,pct_private_ovlp)

write_sf(private, file.path(spatialOutDir,"private.gpkg"))

WetlandsP<- private %>%
  st_drop_geometry() %>%
  dplyr::select(WTLND_ID, pct_private_ovlp)

WriteXLS(WetlandsP,file.path(dataOutDir,paste('Private.xlsx',sep='')))


