<!-- 
Add a project state badge

See <https://github.com/BCDevExchange/Our-Project-Docs/blob/master/discussion/projectstates.md> 
If you have bcgovr installed and you use RStudio, click the 'Insert BCDevex Badge' Addin.
-->

WESP_Sample_Design
============================
The B.C. Wildlife Federation’s Wetlands Workforce project is a collaboration with conservation organizations and First Nations working to maintain and monitor wetlands across British Columbia.   
https://bcwf.bc.ca/initiatives/wetlands-workforce/.  

WESP - Wetland Ecosystem Services Protocol   

There are three sets of WESP R scripts to identify wetlands for monitoring within a study area.  
1) WESP_data_prep - presents a set of scripts used to generate a new, or process existing, wetlands for a study area - https://github.com/BCWF-Wetlands/WESP_data_prep;  
2) WESP_Sample_Design - This repository, attributes wetlands with local human and natural landscape characteristics; and    
3) WESP_Sample_Draw - Generates a report card of how samples are meeting sampling criteria and performs a draw to select wetlands to meet criteria - https://github.com/BCWF-Wetlands/WESP_Sample_Design.

### Usage

There are a set of scripts that help attribute wetlands for the sample draw, there are four basic sets of scripts:    
Control scripts - set up the analysis environment;   
Load scripts - loads base data;    
Clean scripts - cleans spatial layers for attributing wetlands; and    
Analysis scripts - generate a look up table for each attribute, and collate and to wetlands.    

#Control Scripts:   
run_all.R	Sets local variables and directories used by scripts, presents script order.   
header.R	loads R packages, sets global directories, and attributes.  

#Load Scripts:	
01_base_load.R	Loads core spatial layers used by routines.  
01_load.R	load script sourcing all the various pre-processed layers required - typically only required for first run.  

#Clean Scripts:   
02_cleanRoads_Prov.R	Only required for preparing Provincial scale data.  
02_cleanRoads_AOI.R	Clean road data for study area.   
02_clean_disturb_Prov.R	Only required for preparing Provincial scale data.   
02_clean_disturb_AOI.R	Clean Provincial disturbance data for study area.  
02_clean_LandType_Prov.R	Only required for preparing Provincial scale data.   
02_clean_BEC_Prov.R	Only required for preparing Provincial scale data.  
02_clean_FOWN.R	Only required for preparing Provincial scale data.  
	
#Analysis Scripts:   
03_analysis_1_Roads.R	Assign road indicators by wetland - evaluates if wetland is within 500m of a road.    
03_analysis_1_Roads_PEM.R	for Sub-Boreal PEM wetlands.  
03_analysis_2_BEC.R	Assign BEC indicators by wetland.  
03_analysis_3_Flow.R	for already existing hydro indicators.  
03_analysis_3_Flow_byWshd.R	if needed to process large study areas.  
03_analysis_3_New_Flow.R	New base wetlands - generate flow attributes.  
03_analysis_3_Flow_StreamStartEnd.R	Determine stream start and ends for each wetland.   
03_analysis_4_Disturbance.R	Assign disturbance indicators by wetland.   
03_analysis_4_RdDisturbance.R	Assign Road Disturbance indicators by wetland.  
03_analysis_5_LandCover.R	Assign Land Cover indicators by wetland.  
03_analysis_6_Geology.R Assign bedrock geology indicators by wetland.    
03_analysis_6_PrivateLand.R	Assign ownership indicator for pre-made wetlands.  
03_analysis_6_FOWN.R	To determine private land associated with wetland.  
03_analysis_6_FOWN_PEM.R	For FWCP PEM wetlands.   
03_analysis_6_NationBoundary.R	Where required.   
03_analysis_6_FNationBoundary_PEM.R	Where required.   
	03_analys_7_Collate.R	For each study area collates the attributes for each wetland and prepares data for passing to draw routine.   

### Project Status

The set of R WESP scripts are continually being modified and improved, including adding new study areas as sampling is initiated.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/BCWF-Wetlands/WESP_data_prep/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

```
Copyright 2022 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```
---
