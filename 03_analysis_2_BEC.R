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

#exact extract to assign BEC to wetland
bec_g<-st_read(file.path(spatialOutDirP,"BECg.gpkg")) %>%
  st_buffer(0) %>%
  st_intersection(AOI) %>%
  st_collection_extract() %>%
  st_cast("POLYGON")

write_sf(bec_g, file.path(spatialOutDir,"bec_g.gpkg"))

#"High"    "Low-Dry" "Low-Wet"
bec_LUT<-data.frame(BECgroup=unique(bec_g$BECgroup), BECnum=c(1:length(unique(bec_g$BECgroup))))
#bec_LUT<-data.frame(BECgroup=c("High","Low-Wet","Low-Dry"), BECnum=c(1,length(unique(bec_g$BECgroup))))

bec_g<-bec_g %>%
  left_join(bec_LUT,by=c('BECgroup'))
table(bec_g$BECgroup,bec_g$BECnum)

bec_gr<-fasterize(bec_g,ProvRast,field='BECnum')

#Number of 1ha cells in polygon
Wetlands_EprivBEC <- data.frame(BECnum=exact_extract(bec_gr, Wetlands, 'mode'))
Wetlands_EprivBEC$wet_id <-seq.int(nrow(Wetlands_EprivBEC))

bec_ptsGeo <- Wetlands %>%
  left_join(Wetlands_EprivBEC) %>%
  left_join(bec_LUT)

write_sf(bec_ptsGeo, file.path(spatialOutDir,"bec_ptsGeo.gpkg"))

bec_pts <- bec_ptsGeo %>%
  st_drop_geometry() %>%
  dplyr::select(WTLND_ID, BEC=BECgroup)

WriteXLS(bec_pts,file.path(dataOutDir,paste('bec_pts.xlsx',sep='')))


message('Breaking')
break

###########3
#intersects takes 2 hours for an EcoProvince
if (!file.exists(file.path(dataOutDir,paste('bec_pts.xlsx',sep='')))) {
  bec_pts <- st_intersection(wetland.pt, bec_g) %>%
    #write_sf(bec_pts, file.path(spatialOutDir,"bec_pts.gpkg"))
    st_drop_geometry() %>%
    dplyr::select(WTLND_ID, BEC=BECgroup)

  WriteXLS(bec_pts,file.path(dataOutDir,paste('bec_pts.xlsx',sep='')))
} else {
  bec_pts<-read_excel(file.path(dataOutDir,paste('bec_pts.xlsx',sep=''))) #was 26003 - now 25973
}



###############
#becCheck<-wetland.pt %>%
#  dplyr::filter(!(WTLND_ID %in% bec_pts$WTLND_ID)) #8 wetlands whose centroids are in Alberta
#write_sf(becCheck, file.path(spatialOutDir,"becCheck.gpkg"))

# make a list of unique bec variants
bgc.ls <- as.list(unique(bec_pts$BEC))

# generate a list summarizing bec groups, and the number and % of wetlands, then save
prop.site <- bec_pts %>%
  group_by(BEC)%>%
  dplyr::summarise(no.pts = n()) %>%
  mutate(perc = ceiling(no.pts / sum(no.pts)*100))

WriteXLS(prop.site,file.path(dataOutDir,paste('ESI_Wetland_Strata_BEC.xlsx',sep='')),SheetNames='BEC')

gc()
