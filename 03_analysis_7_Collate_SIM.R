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

FlowAttributes<-read_xlsx(file.path(dataOutDir,paste('FlowAttributes.xlsx',sep='')))
BVWFattributes<-read_xlsx(file.path(dataOutDir,paste('BVWFattributes.xlsx',sep=''))) %>%
  dplyr::select(-c(Nation, pct_private_ovlp,dist_to_road))

#Assemble wetland data with each of the strata as a single field
# bec_pts - wet_id, BECgroup
bec_pts<-read_xlsx(file.path(dataOutDir,paste('bec_pts.xlsx',sep='')))
# WetFlow - wet_id, FlowCode
WetFlow <- read_xlsx(file.path(dataOutDir,paste('WetFlow.xlsx',sep='')))
#WetFlow - wet_id, FlowCode
LandT <- read_xlsx(file.path(dataOutDir,paste('ltls.xlsx',sep='')))
# WetFlow - wet_id, FlowCode
Disturb <- read_xlsx(file.path(dataOutDir,paste('disturb.ls.xlsx',sep='')))
table(Disturb$DisturbType)
#Roads
Roads <- read_xlsx(file.path(dataOutDir,paste('road.ls.xlsx',sep='')))
RdDisturb <- read_xlsx(file.path(dataOutDir,paste('RdDisturb.ls.xlsx',sep='')))
private <- read_xlsx(file.path(dataOutDir,paste('Private.xlsx',sep='')))
#BedRock<-read_xlsx(file.path(dataOutDir,paste('BedRock.xlsx',sep='')))

# Simpcw_pts
Simpcw_pts<-read_xlsx(file.path(dataOutDir,paste('Simpcw_pts.xlsx',sep='')))

#Join strata and select criteria attributes data back to wetlands
SampleStrata  <- Wetlands %>%
  left_join(WetFlow, by='WTLND_ID') %>%
  left_join(bec_pts, by='WTLND_ID') %>%
  left_join(LandT, by='WTLND_ID') %>%
  left_join(Disturb, by='WTLND_ID') %>%
  left_join(Roads, by='WTLND_ID') %>%
  left_join(RdDisturb, by='WTLND_ID') %>%
  left_join(private, by='WTLND_ID') %>%
  left_join(FlowAttributes, by='WTLND_ID') %>%
  left_join(BVWFattributes, by='WTLND_ID') %>%
 # left_join(BedRock, by='WTLND_ID') %>%
  left_join(Simpcw_pts, by='WTLND_ID') %>%
  #  mutate(StrataGroup=as.character(group_indices(.,BEC,FlowCode))) %>% #53108
  #group_by(BEC,FlowCode) %>%
  #mutate(StrataGroup = as.character(cur_group_id())) %>%
  #ungroup() %>%
  #Drop any wetlands that are NA for BEC - 6 cases for some reason
 # dplyr::filter(!is.na(BEC)) %>%
  #Drop Landcover NAs - 64 cases? all wetlands should be assigned properly? need to check
#  dplyr::filter(!is.na(LanCoverLabel)) %>%
  mutate(Nation=if_else(is.na(Nation), 'other', Nation)) %>%
 # mutate(Sampled=0) %>%
  mutate(SampleType=0) %>%
  #mutate(Sampled=if_else(WTLND_ID %in% c('SIM_242','SIM_18'), 1, Sampled)) %>%
  #mutate(YearSampled=if_else(WTLND_ID %in% c('SIM_242','SIM_18'), 2021, YearSampled)) %>%
  # mutate(YearSampled=0) %>%
  dplyr::select(WTLND_ID, Sampled, SampleType, YearSampled,
                pcentIn500Buf, win500,#dist_to_road,
                stream_intersect,river_intersect,mmwb_intersect,lake_intersect,
                split_by_stream,stream_start,stream_end,max_stream_order, granitic_bedrock,
                BEC, #BEC_BCWF
                Nation,
                Verticalflow, Bidirectional,Throughflow, Outflow, Inflow,
                FlowCode, Water, nRiver, nLake, LakeSize, LargeWetland,
                DisturbCode, DisturbType, RdDisturbCode, RdDisturbType,
                LandCoverType, LandCCode,granitic_bedrock,
                #Land_Disturbance, fire_history, Land_Cover, #fire_year,
                parcelmap_private, pct_private_ovlp) %>%
  #Filter out wetlands on Alberta boundary
  dplyr::filter(!(is.na(BEC))) #%>% #26003
  #filter out redundent BCWF wetlands
  #dplyr::filter(!(is.na(BEC_BCWF))) #25973

SampleCheck <- SampleStrata %>%
  #dplyr::filter(WTLND_ID %in% c('SIM_242','SIM_1432','SIM_18'))
 dplyr::filter(Sampled==1)
table(SampleStrata$YearSampled)

#Check for missing hydro values
hydroCheck<-SampleStrata %>%
  dplyr::filter(is.na(stream_intersect))


#SampleStrata[is.na(SampleStrata)] <- 0
write_sf(SampleStrata, file.path(spatialOutDir,"SampleStrata.gpkg"))
st_write(SampleStrata, file.path(spatialOutDir,"SampleStrata_SIM.shp"),delete_dsn=TRUE)

SampleStrata_Final<-SampleStrata %>%
  st_drop_geometry()

#BECcheck<-SampleStrata %>% filter(is.na(BEC))
#write_sf(BECcheck, file.path(spatialOutDir,"BECcheck.gpkg"))

NAcheck<-SampleStrata %>% dplyr::filter(is.na(FlowCode))
write_sf(NAcheck, file.path(spatialOutDir,"NAcheck.gpkg"))

