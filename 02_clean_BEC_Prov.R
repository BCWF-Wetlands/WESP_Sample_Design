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

#BEC
BEC_file<-file.path(spatialOutDirP,'BECin.gpkg')
if (!file.exists(BEC_file)) {
  BECin<-bcdc_get_data("WHSE_FOREST_VEGETATION.BEC_BIOGEOCLIMATIC_POLY")
  write_sf(BECin, file.path(spatialOutDirP,"BECin.gpkg"))
} else {
  BECin<-st_read(file.path(spatialOutDirP,"BECin.gpkg"))
}

BECgroupSheets<- excel_sheets(file.path(DataDir,'BECv11_SubzoneVariant_GroupsVESI_V5.xlsx'))
BECgroupSheetsIn<-read_excel(file.path(DataDir,'BECv11_SubzoneVariant_GroupsVESI_V5.xlsx'),
                             sheet = BECgroupSheets[2])

BECGroup_LUT<-data.frame(VARns=BECgroupSheetsIn$`BEC Unit`,
                         BECgroup=BECgroupSheetsIn$GROUP, stringsAsFactors = FALSE)

BECg<- BECin %>%
  mutate(VARns=MAP_LABEL) %>%
  left_join(BECGroup_LUT) %>%
  mutate(sumbec=1) %>%
  dplyr::group_by(BECgroup) %>%
  dplyr::summarise(nbecs = sum(sumbec)) %>%
  ungroup()

write_sf(BECg, file.path(spatialOutDirP,"BECg.gpkg"))

#########Data checking -
#plot(bec_g[1])
#ubecs<-unique(bec_g$BECgroup)

#Based on inspection, aggregate some of the rarer groups to make a LUT
#re-join and generate a second version of bec groups
#BECGroup_LUT2<-data.frame(BECgroup=ubecs,
##                   BECgroup2=c(ubecs[1:7],ubecs[7],ubecs[6],ubecs[3],ubecs[11:12],ubecs[12],ubecs[4]))

#bec_g2<-bec_g %>%
#  left_join(BECGroup_LUT2) %>%
#  mutate(sumbec2=1) %>%
#  dplyr::group_by(BECgroup2) %>%
#  dplyr::summarise(nbecs = sum(sumbec2))
#plot(bec_g2[1])
#bec_g<-bec_g2

#save the aggregated becs
#write_sf(bec_g2, file.path(spatialOutDir,"bec_g2.gpkg"))

