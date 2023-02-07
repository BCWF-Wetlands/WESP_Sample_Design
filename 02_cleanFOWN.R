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

#Ownership
F_OWN<-read_sf(file.path(ProvData,'F_OWN/F_OWN_polygon.shp')) %>%
  st_buffer(0) %>%
  st_intersection(AOI)
write_sf(F_OWN, file.path(spatialOutDir,"F_OWN.gpkg"))

#pull out private land and summarize
F_OWN_P<-F_OWN %>%
  mutate(private=if_else(OWN %in% c(40,41,52,53), 1, 0)) %>%
  dplyr::group_by(private) %>%
  dplyr::summarize(AreaHa=sum(AREA_SQM)*0.0001)
write_sf(F_OWN_P, file.path(spatialOutDir,"F_OWN_P.gpkg"))

F_OWN_PR1<- fasterize(F_OWN_P,ProvRast,field='private')
F_OWN_PR1[is.na(F_OWN_PR1)]<-0

F_OWN_PR<- F_OWN_PR1 %>%
  mask(AOI) %>%
  crop(AOI)
writeRaster(F_OWN_PR,filename=file.path(spatialOutDir,"F_OWN_PR.tif"), format="GTiff", overwrite=TRUE)

