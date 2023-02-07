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

if (!file.exists(file.path(spatialOutDir,"WetPrivate.gpkg"))) {
start.time <- Sys.time()
WetPrivate <-st_intersection(Wetlands, F_OWN_P)
write_sf(WetPrivate, file.path(spatialOutDir,"WetPrivate.gpkg"))
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
} else {
  WetPrivate<-st_read(file.path(spatialOutDir,"WetPrivate.gpkg"))
}

Priv.ls1 <- WetPrivate %>%
  mutate(pareaHa=as.numeric(st_area(WetPrivate)*0.0001)) %>% #st_area generates m2 converted to ha
  st_drop_geometry() %>%
  mutate(privArea=if_else(private==1, pareaHa, 0))

Priv.ls %>% Priv.ls1
  group_by(WTLND_ID) %>%
  dplyr::summarize(prvArea=sum(privArea), area_Ha=first(area_Ha)) %>%
  mutate(pc_Private=if_else(prvArea>0, prvArea/area_Ha*100, 0)) %>%
  dplyr::select(WTLND_ID, pc_Private, prvArea, area_Ha)

WriteXLS(Priv.ls,file.path(dataOutDir,paste('Priv.ls.xlsx',sep='')))
