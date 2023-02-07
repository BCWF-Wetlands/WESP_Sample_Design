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

table(SampleStrata_Final$YearSampled)
table(SampleStrata_Final$stream_intersect)
#checK<-SampleStrata_Final %>%
#  dplyr::filter(WTLND_ID=='SIM_25987')

outFileN<-paste0('SampleStrata_2022_',WetlandAreaShort,'.csv')
write.csv(SampleStrata_Final, file=file.path(DrawDir,outFileN), row.names = FALSE)

#checK<-SampleStrata %>%
 #   dplyr::filter(is.na(stream_intersect))


