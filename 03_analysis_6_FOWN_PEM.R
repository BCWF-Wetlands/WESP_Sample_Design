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

PEM_wetlands<-read_sf(file.path(spatialOutDir,"PEM_wetlands.gpkg"))

#Modify to use exactextract - way faster than st_intersection
F_OWN_PR<-raster(file.path(spatialOutDirP,"F_OWN_PR.tif"))
#Number of 1ha road buffer cells in polygon
Wetlands_EprivP <- data.frame(priv_areaHa=exact_extract(F_OWN_PR, PEM_wetlands, 'sum'))
Wetlands_EprivP$wet_id_FWCP <-seq.int(nrow(Wetlands_EprivP))

privatePEM <- PEM_wetlands %>%
  left_join(Wetlands_EprivP) %>%
  #st_drop_geometry() %>%
  #mutate(pcentInPriv=round(priv_areaHa/area_Ha*100)) %>%
  dplyr::select(wet_id_FWCP, WTLND_ID, priv_areaHa, area_Ha) %>%
  #mutate(pcentInPriv=round(priv_areaHa/area_Ha*100)) %>%
  #mutate(win500=if_else((pcentIn500Buf>75.00),1,0))
  mutate(pct_private_ovlp=if_else(is.na(priv_areaHa), 0, round(as.numeric(priv_areaHa/area_Ha)*100))) %>%
  dplyr::select(WTLND_ID,pct_private_ovlp)

write_sf(privatePEM, file.path(spatialOutDir,"privatePEM.gpkg"))

WetlandsPpem<- privatePEM %>%
  st_drop_geometry() %>%
  dplyr::select(WTLND_ID, pct_private_ovlp)

WriteXLS(WetlandsPpem,file.path(dataOutDir,paste('PrivatePEM.xlsx',sep='')))

#####
private<-PEM_wetlands1 %>%
  st_intersection(F_OWN_P)

private<-PEM_wetlands <- private<-PEM_wetlands1 %>%
 mutate(priv_area = st_area(.))/10000 %>%
  dplyr::select(WTLND_ID, priv_area) %>%
  st_drop_geometry()

WetlandsPpem<- PEM_wetlands %>%
  merge(private, by = 'WTLND_ID', all.x=TRUE) %>%
  st_drop_geometry() %>%
  dplyr::select(WTLND_ID, area_Ha, priv_area) %>%
  group_by(WTLND_ID, area_Ha) %>%
  dplyr::summarise(privT=sum(priv_area)) %>%
  mutate(pct_private_ovlp=if_else(is.na(privT), 0, round(as.numeric(privT/area_Ha)*100))) %>%
  dplyr::select(WTLND_ID,pct_private_ovlp)

WriteXLS(WetlandsPpem,file.path(dataOutDir,paste('PrivatePEM.xlsx',sep='')))
