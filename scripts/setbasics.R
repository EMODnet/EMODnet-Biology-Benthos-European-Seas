require(raster)
require(sp)
require(rgdal)
require(svMisc)
require(tidyverse)
require(sf)
require(worrms)
library(ggplot2)
library('rnaturalearth')
library(magick)
library(rgeos)
library(EMODnetBiologyMaps)
require(imis)
require(progress)
require(ncdf4)

#############
downloadDir <- "data/raw_data"
dataDir     <- "data/derived_data"
mapsDir     <- "product/maps"
rasterDir   <- "product/species_rasters"
plotsDir    <- "product/species_plots"
#############
proWG<-CRS("+proj=longlat +datum=WGS84")
source("./scripts/auxiliary_functions.R")
