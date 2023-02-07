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

system('echo "$SHELL"')

source('header.R')
#"/Applications/GRASS-7.8.app/Contents/Resources"
#"/usr/local/grass-7.8.6"

initGRASS(gisBase = "/Applications/GRASS-7.8.app/Contents/Resources/",
          home = tempdir(),
          gisDbase = "/Users/darkbabine/ProjectLibrary/GrassData/",
          location = "WESP",
          mapset = "ESI",
          SG = "elevation")

GISDBASE=/Users/darkbabine/ProjectLibrary/GrassData
LOCATION_NAME=WESP
MAPSET=ESI
GUI=wxpython
PID=3831
GUI_PID=3833
"/Users/darkbabine/Library/GRASS/8.0/Modules/"
"/Applications/GRASS-8.0.app/Contents/Resources/"
"/Applications/GRASS-8.0.app/Contents/MacOS/"
G <- initGRASS(gisBase = "/Applications/GRASS-7.8.app/Contents/Resources/",
          home = tempdir(),
          gisDbase = "/Users/darkbabine/ProjectLibrary/GrassData/",
          #location = "WESP",
          #mapset = "ESI",
          #pid=3831,
          override = TRUE,
          #use_g.dirseps.exe = TRUE,
          #remove_GISRC =  FALSE
          )

loc <- initGRASS("C:/Program Files (x86)/GRASS 6.4.2",
                 home=getwd(), gisDbase="GRASS_TEMP", override=TRUE )

initGRASS(gisBase="/Applications/GRASS-7.4.4.app/Contents/Resources/")

          ,
          gisDbase="grassdata",
          location="nc_spm_08_grass7", mapset="PERMANENT",override=TRUE)

