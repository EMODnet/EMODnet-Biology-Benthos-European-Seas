create_netcdf_output <- function(events,spfr,netcdf_fil){
  nobs <- nrow(events)
  nsp <- nrow(spfr)
  
  # transform the dates to days since 1970-1-1
  events$eventDate<-as.numeric(as.Date(events$eventDate))
  
  # make vectors with AphiaIds and Specnames
  AphiaIDs <- paste0("urn:lsid:marinespecies.org:taxname:",spfr$aphiaID)
  spnams <- as.vector(spfr$scientificName)[1:nsp]
  
  
  ## ADD DIMENSIONS
  points_dim <- ncdim_def("points", "", 1:nobs, unlim=FALSE, create_dimvar=FALSE)
  tax_dim <- ncdim_def("taxon","",1:nsp,unlim=FALSE,create_dimvar=FALSE)
  nchar_dim <- ncdim_def("string45", "", 1:45, create_dimvar=FALSE )
  
  ## ADD VARIABLES
  time_var <- ncvar_def(name="Date", 
                        units="days since 1970-01-01 00:00:00", 
                        dim=list(points_dim),
                        missval = as.integer(-99999),
                        longname="time",
                        prec='integer')
  lat_var <- ncvar_def(name="lat",
                       units="degree_north", 
                       dim=list(points_dim),
                       missval=NA,
                       longname="latitude",
                       prec='float')
  lon_var <- ncvar_def(name="lon", 
                       units="degree_east", 
                       dim=list(points_dim),
                       missval=NA,
                       longname="longitude",
                       prec='float')
  AphiaID_var <- ncvar_def(name = "AphiaID", 
                           units = "", 
                           dim = list(nchar_dim,tax_dim),
                           longname="biological_taxon_lsid", 
                           prec='char')
  TaxName_var <- ncvar_def(name="Taxon_Name",
                           units = "", 
                           dim=list(nchar_dim,tax_dim),
                           longname="biological_taxon_name",
                           prec='char')
  PresAbs_var <- ncvar_def (name="Pres_abs",units = "", dim=list(points_dim,tax_dim),
                            missval = 2,
                            longname="Presence(1)Absence(0)of species at sampling event",
                            prec='byte')
  CRS_var <- ncvar_def(name="crs",
                       dim=list(),
                       units="",
                       longname="coordinate reference system")
  
  ## CREATE A NEW FILE
  ncnew <- nc_create(netcdf_fil, list(time_var, lat_var, lon_var,CRS_var,
                                      AphiaID_var, TaxName_var),
                     force_v4=TRUE)
  
  ## ADD GLOBAL ATTRIBUTES
  # see http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/
  #           formats/DataDiscoveryAttConvention.html
  ncatt_put(ncnew, 0, "ncei_template_version", "NCEI_NetCDF_Point_Template_v2.0")
  ncatt_put(ncnew, 0, "featureType", "point")
  ncatt_put(ncnew, 0, "title", "Presence/absence of macrobenthos in European Seas")
  ncatt_put(ncnew, 0, "summary", 
            paste0("This dataset compiles all available macrozoobenthos data in Emodnet ",
                   "biology. Presence is recorded when a species is in the database. ",
                   "Absence is recorded when the species was",
                   " not found in a sample that was (in principle) looking for the species.",
                   " NA is given when the species was not looked for at the sampling event. ",
                   "The data are recorded in an event*species matrix.",
                   "  Every event is characterised by x,y,time. z is always the sea bottom. ",
                   "Taxa (i.e. species or higher taxa such as genus, family etc.) are",
                   "characterised by their AphiaID, a sequential number in the World ",
                   "Record of Marine Species ",
                   " (WoRMS - https://marinespecies.org) and by their taxon name"))
  ncatt_put(ncnew, 0, "keywords", "Waiting For Keywords")
  ncatt_put(ncnew, 0, "Conventions", "CF-1.8, ACDD-1.3")
  ncatt_put(ncnew, 0, "id", "Presence_absence_macrobenthos_European_Seas")
  ncatt_put(ncnew, 0, "naming_authority", "deltares.nl")
  ncatt_put(ncnew, 0, "history", 
            paste0("This product is an extension of a previously published product",
                   "doing this analysis on the Greater North Sea. See ",
                   "https://www.emodnet-biology.eu/blog/summary-presenceabsence-maps",
                   "-macro-endobenthos-greater-north-sea. The present product has",
                   "used the same methodology with some adjustments, and covers all",
                   "European Seas. It is also more recent, so has some additional",
                   "data for the North Sea")
  )
  ncatt_put(ncnew, 0, "source",
            paste0("See the Emodnet biology portal for all data sources available. ",
                   "The workflow of this data product is described on the Emodnet github ",
                   "site (subsite Benthos_European_Seas)",
                   "Still waiting for links to be updated"))
  ncatt_put(ncnew, 0, "processing_level", 
            "Interoperable data collation - minimally interpreted")
  ncatt_put(ncnew, 0, "comment", "")
  ncatt_put(ncnew, 0, "acknowledgment", 
            paste0("Data originators are acknowledged for the data. Full list of ",
                   "datasets used, including reference to responsible people, can",
                   "be found in the underlying files on github - see file",
                   "./data/derived_data/allDatasets_selection.csv.",
                   "European Marine Observation Data Network (EMODnet) Biology project",
                   "(EASME/EMFF/2017/1.3.1.2/02/SI2.789013), funded by the European Union",
                   "under Regulation (EU) No 508/2014 of the European Parliament and of",
                   "the Council of 15 May 2014 on the European Maritime and Fisheries Fund")
  )
  ncatt_put(ncnew, 0, "license", "CC-BY")
  ncatt_put(ncnew, 0, "standard_name_vocabulary", "CF Standard Name Table vNN")
  ncatt_put(ncnew, 0, "date_created", "2022-03-04 13:21:00")
  ncatt_put(ncnew, 0, "creator_name", "Peter Herman")
  ncatt_put(ncnew, 0, "creator_email", "peter.herman@deltares.nl")
  ncatt_put(ncnew, 0, "creator_url", "www.deltares.nl")
  ncatt_put(ncnew, 0, "institution", "Deltares")
  ncatt_put(ncnew, 0, "project", "Emodnet_Biology")
  ncatt_put(ncnew, 0, "publisher_name", "Emodnet Biology Project")
  ncatt_put(ncnew, 0, "publisher_email", "bio@emodnet.eu")
  ncatt_put(ncnew, 0, "publisher_url", "Wait for central portal URL")
  ncatt_put(ncnew, 0, "geospatial_lat_min", "26")
  ncatt_put(ncnew, 0, "geospatial_lat_max", "82")
  ncatt_put(ncnew, 0, "geospatial_lon_min", "-36")
  ncatt_put(ncnew, 0, "geospatial_lon_max", "61")
  ncatt_put(ncnew, 0, "time_coverage_start", "-70492")
  ncatt_put(ncnew, 0, "time_coverage_end", "18992")
  ncatt_put(ncnew, 0, "time_coverage_duration", "89484")
  ncatt_put(ncnew, 0, "time_coverage_resolution", "day")
  ncatt_put(ncnew, 0, "time_coverage_units", "days since 1970-01-01 00:00:00")
  ncatt_put(ncnew, 0, "sea_name", paste0("Arctic Sea, Baltic Sea, Black Sea, ",
                                         "Mediterranean, North Atlantic Ocean, North Sea")
  )
  ncatt_put(ncnew, 0, "publisher_institution", "VLIZ")
  ncatt_put(ncnew, 0, "geospatial_lat_units", "degrees_north")
  ncatt_put(ncnew, 0, "geospatial_lon_units", "degrees_east")
  ncatt_put(ncnew, 0, "date_modified", "2022-03-04 13:21:00")
  ncatt_put(ncnew, 0, "date_issued", "2022-03-04 13:21:00")
  ncatt_put(ncnew, 0, "date_metadata_modified", "2022-03-04 14:21:00")
  ncatt_put(ncnew, 0, "product_version", "0.3")
  ncatt_put(ncnew, 0, "cdm_data_type", "Point")
  ncatt_put(ncnew, 0, "metadata_link", "Wait for link")
  ncatt_put(ncnew, 0, "references", "Wait for link")
  #
  # add attributes of crs
  #
  ncatt_put(ncnew,CRS_var,'geographic_crs_name','WGS 84')
  ncatt_put(ncnew,CRS_var,'grid_mapping_name','latitude_longitude')
  ncatt_put(ncnew,CRS_var,'inverse_flattening', '298.257223563')
  ncatt_put(ncnew,CRS_var,'longitude_of_prime_meridian', '0.0')
  ncatt_put(ncnew,CRS_var,'prime_meridian_name','Greenwich')
  ncatt_put(ncnew,CRS_var,'reference_ellipsoid_name','WGS 84')
  ncatt_put(ncnew,CRS_var,'semi_major_axis','6378137.0')
  ncatt_put(ncnew,CRS_var,'semi_minor_axis','6356752.314245179')
  
  # write values to the file
  # list(time_var, lat_var, lon_var, z_var, AphiaID, TaxName, PresAbs, crs_var)
  ncvar_put(nc=ncnew,varid=time_var,vals=events$eventDate)
  ncvar_put(nc=ncnew,varid=lat_var,vals=events$decimalLatitude)
  ncvar_put(nc=ncnew,varid=lon_var,vals=events$decimalLongitude)
  ncvar_put(nc=ncnew,varid=AphiaID_var,vals=as.vector(AphiaIDs))
  ncvar_put(nc=ncnew,varid=TaxName_var,vals=spnams)
  
  ncvar_add(nc=ncnew,PresAbs_var,indefine=TRUE)
  
  nc_close(ncnew)
}
