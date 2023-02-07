# Copyright 2018 Province of British Columbia
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

source("header.R")

#Select an EcoProvince(s)
#one of: 1-SIM, 2-TBP, 3-SB, 4-GD, 5-GD_Est, 6-SB_PEM, 7-SI
EcoP<-7
WetlandArea<-WetlandAreaL[EcoP]
WetlandAreaDir<-WetlandAreaDirL[EcoP]
WetlandAreaShort<-WetlandAreaShortL[EcoP]
EcoPN<-as.character(EcoPNL[EcoP])
#For Plains use:
# EcoPN<-c("BOREAL PLAINS","TAIGA PLAINS")

#Run Provincial scale scripts only once
#source('01_load.R')
#source('02_cleanRoads_Prov.R')
#source('02_clean_disturb_Prov.R')

#Set up unique directories for EcoProvince output
spatialOutDir <- file.path('out','spatial',WetlandAreaDir)
dataOutDir <- file.path(OutDir,'data',WetlandAreaDir)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(spatialOutDir), showWarnings = FALSE)
tempAOIDir<-paste0("tmp/",WetlandAreaDir)
dir.create(tempAOIDir, showWarnings = FALSE)
WetlandDir<-file.path('../WESP_data_prep/out/spatial',WetlandAreaDir)

AOIin <- bcmaps::ecoprovinces() %>%
  dplyr::filter(ECOPROVINCE_NAME %in% EcoPN) %>%
  st_union() %>%
  st_buffer(dist=1000)#modified AOI to capture wetlands on boundaries of AOI
AOI<-st_as_sf(AOIin)
mapview(AOIin)

source('01_base_load.R')

# run if needed
#source('02_cleanRoads_Prov.R')
#source('02_cleanRoads_AOI.R')
#source('02_clean_disturb_Prov.R')
#source('02_clean_disturb_AOI.R')

#source('03_analysis_1_Roads.R')
#source('03_analysis_1_Roads_PEM.R')
#source('03_analysis_2_BEC.R')

#Flow needs updating
#source('03_analysis_3_Flow.R') # for already existing hydro indicators
#source('03_analysis_3_Flow_byWshd.R') #if needed
#source('03_analysis_3_New_Flow.R') # for new base wetlands
#  includes source('03_analysis_3_Flow_StreamStartEnd.R')

#source('03_analysis_4_Disturbance.R')
#source('03_analysis_5_LandCover.R')

#check for BVWF attributes<-c("dist_to_road","parcelmap_private","partner_site")

#source('03_analysis_6_FOWN.R')
#source('03_analysis_6_FOWN_PEM.R')
#source('03_analysis_6_NationBoundary.R')
#source('03_analysis_6_FNationBoundary_PEM.R')
#source('03_analys_7_Collate.R')

#source('04_output.R')


