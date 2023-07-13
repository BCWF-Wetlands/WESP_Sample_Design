#Test catchment methods
#subcatch(DEM(as a matrix), outpoint (as a vector))
#Tried converting to stack of each then extract DEM and single point but preserve it
#matrix location....

library('topmodel')
ws<-get_layer("wsc_drainages", class = "sf")
TestAOI<-ws %>%
  dplyr::filter(SUB_DRAINAGE_AREA_NAME=='Thompson'&
                  SUB_SUB_DRAINAGE_AREA_NAME=='Nicola')

DEM_AOI<-DEM.tp %>%
  mask(TestAOI) %>%
  crop(TestAOI)
writeRaster(DEM_AOI, filename=file.path(spatialOutDir,'DEM_AOI.tif'), overwrite=TRUE)

DEM_AOI<-raster(file.path(spatialOutDir,'DEM_AOI.tif'))
DEM_AOIt<-rast(DEM_AOI)
DEMtM<-as.matrix(DEM_AOIt, wide=TRUE)
#1363285,505111
#SI_2718
TDEM<-raster::as.matrix(DEM_AOI)

Twet2<-wetland.pt %>%
  filter(WTLND_ID=='SI_3235') %>%
  st_coordinates()

wetM<-wetland.pt %>%
  select(wet_id) %>%
  as("Spatial") %>%
  rasterize(DEM_AOI)

wetS<-stack(DEM_AOI,wetM)
names(wetS)

MwetS<-raster::as.matrix(wetS,rownames.force=TRUE)

m[m[, "three"] == 11,]
Cwet<-as.data.frame(MwetS)
result <- filter(as.data.frame(MwetS), wet_id == 3235)


Cwet<-as.data.frame(MwetS[MwetS[,'wet_id',drop=TRUE]== 3235,])
Cwet<-as.data.frame(MwetS) %>%
  dplyr::select(wet_id=4754)


Tcatch<-subcatch(MwetS,Cwet)



example_points <- as(example_points, "Spatial")


point_location <- raster::xyFromCell(DEM_AOI, which.max(raster::extract(DEM_AOI, Twet)))
#point_location <- raster::xyFromCell(TDEM, which.max(raster::extract(TDEM, Twet)))


mapview(TestAOI)+mapview(Twet)+mapview(point_location)


tt<-raster::extract(TDEM, Twet)



raster_data <- raster("path/to/raster.tif")
point_data <- st_read("path/to/file.shp")
# Get matrix location of point in raster
point_location <- raster::xyFromCell(raster_data, which.max(raster::extract(raster_data, point_data)))
point_row_col <- as.integer(raster::rowFromY(raster_data, point_location$y))
point_col_row <- as.integer(raster::colFromX(raster_data, point_location$x))
# Print row and column index of point in raster
cat("Row: ", point_row_col, "\n")
cat("Column: ", point_col_row, "\n")


# Load DEM and point data as sf object
dem <- raster(file.path(spatialOutDir,'DEM_AOI.tif'))
#point <- st_as_sf(data.frame(ID = 1, x = -100, y = 50), coords = c("x", "y"), crs = st_crs(dem))
point<-Twet
  # Extract elevation value from DEM at point location
elev <- extract(dem, point)
# Create catchment area around point location using D8 flow direction algorithm
flow_dir <- terrain(dem, opt = "flowdir")
catchment <- catchment(flow_dir, point)
# Plot DEM with catchment area
plot(dem)
plot(catchment, add = TRUE)
# Write catchment area to a new shapefile
write_sf(catchment, "path/to/catchment.shp") This code loads a DEM and a point location as an sf object, extracts the elevation value at the point location from the DEM, and then creates a catchment area using the D8 flow direction algorithm. The resulting catchment area is then plotted on top of the DEM and written to a new shapefile.

whitebox::install_whitebox()
library('whitebox')

wbt_watershed(d8_pntr = ptr,
              pour_pts = pps,
              output = out)

