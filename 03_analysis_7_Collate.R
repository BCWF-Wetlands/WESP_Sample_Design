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

#Generates SampleStrata file
Wetlands<-read_sf(file.path(spatialOutDir,"Wetlands.gpkg"))

library(data.table)
df<-Wetlands
setDT(df)
df[, as.list(sum(area_Ha)), by = LargeWetland]

#Assemble wetland data with each of the strata as a single field
# bec_pts - wet_id, BECgroup
bec_pts<-read_xlsx(file.path(dataOutDir,paste('bec_pts.xlsx',sep='')))
# WetFlow - wet_id, FlowCode
WetFlow <- read_xlsx(file.path(dataOutDir,paste('WetFlow.xlsx',sep='')))
#WetFlow - wet_id, FlowCode
#BCWF hydro
FlowAttributes<- read_xlsx(file.path(dataOutDir,paste('FlowAttributes.xlsx',sep='')))
#BCWF other
BVWFattributes<-read_xlsx(file.path(dataOutDir,paste('BVWFattributes.xlsx',sep='')))
#Land Type
LandT <- read_xlsx(file.path(dataOutDir,paste('ltls.xlsx',sep='')))
# WetFlow - wet_id, FlowCode
Disturb <- read_xlsx(file.path(dataOutDir,paste('disturb.ls.xlsx',sep='')))
#Ownership
Private<-read_xlsx(file.path(dataOutDir,paste('Private.xlsx',sep='')))

#Roads
#Roads <- read_xlsx(file.path(dataOutDir,paste('road.ls.xlsx',sep='')))
# Simpcw_pts
#Simpcw_pts<-read_xlsx(file.path(dataOutDir,paste('Simpcw_pts.xlsx',sep='')))

#Join strata and select criteria attributes data back to wetlands

AttTable<-WetFlow %>%
  dplyr::left_join(FlowAttributes, by='WTLND_ID') %>%
  dplyr::left_join(BVWFattributes, by='WTLND_ID') %>%
  dplyr::left_join(bec_pts, by='WTLND_ID') %>%
  dplyr::left_join(LandT, by='WTLND_ID') %>%
  dplyr::left_join(Disturb, by='WTLND_ID') %>%
  dplyr::left_join(Private, by='WTLND_ID')

SampleStrata <- Wetlands %>%
  dplyr::left_join(AttTable, by='WTLND_ID') %>%
  #left_join(Roads, by='WTLND_ID') %>%
  #left_join(Simpcw_pts, by='WTLND_ID') %>%
  #  mutate(StrataGroup=as.character(group_indices(.,BEC,FlowCode))) %>% #53108
  #group_by(BEC,FlowCode) %>%
  #mutate(StrataGroup = as.character(cur_group_id())) %>%
  #ungroup() %>%
  #Drop any wetlands that are NA for BEC - 6 cases for some reason
 # dplyr::filter(!is.na(BEC)) %>%
  #Drop Landcover NAs - 64 cases? all wetlands should be assigned properly? need to check
#  dplyr::filter(!is.na(LanCoverLabel)) %>%
  # mutate(Nation=if_else(is.na(Nation), 'other', Nation)) %>%
 # mutate(Sampled=0) %>%
  mutate(SampleType=0) %>%
  #mutate(Sampled=if_else(WTLND_ID %in% c('SIM_242','SIM_18'), 1, Sampled)) %>%
  #mutate(YearSampled=if_else(WTLND_ID %in% c('SIM_242','SIM_18'), 2021, YearSampled)) %>%
  # mutate(YearSampled=0) %>%
  dplyr::select(WTLND_ID, Sampled, SampleType, YearSampled,
                dist_to_road, #pcentIn500Buf, win500, win50,
                stream_intersect,river_intersect,mmwb_intersect,lake_intersect,
                split_by_stream,stream_start,stream_end, granitic_bedrock,
                BEC,
               # Nation,
                Verticalflow, Bidirectional,Throughflow, Outflow, Inflow,
                FlowCode, Water, nRiver, nLake, LakeSize,LargeWetland,
                DisturbType, DisturbCode,LandCoverType, LandCCode,
                #Fire_history, Land_Cover, fire_year,
                parcelmap_private, pct_private_ovlp) %>%
  #Filter out wetlands on Alberta boundary
  dplyr::filter(!(is.na(BEC)))# %>% #26003
  #filter out redundent BCWF wetlands
  #dplyr::filter(!(is.na(BEC_BCWF))) #25973

SampleCheck <- SampleStrata %>%
  #dplyr::filter(WTLND_ID %in% c('SIM_242','SIM_1432','SIM_18'))
 dplyr::filter(Sampled==1)

SampleFileName<-paste0('SampleStrata_2022_',WetlandAreaShort,'.csv')
write.csv(SampleStrata, file=file.path(DrawDir,SampleFileName), row.names = FALSE)

#SampleStrata[is.na(SampleStrata)] <- 0
write_sf(SampleStrata, file.path(spatialOutDir,"SampleStrata.gpkg"))

#BECcheck<-SampleStrata %>% filter(is.na(BEC))
#write_sf(BECcheck, file.path(spatialOutDir,"BECcheck.gpkg"))

NAcheck<-SampleStrata %>% dplyr::filter(is.na(FlowCode))
write_sf(NAcheck, file.path(spatialOutDir,"NAcheck.gpkg"))

