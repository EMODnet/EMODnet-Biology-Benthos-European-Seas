# read geographic layers for plotting
layerurl <- paste0("http://geo.vliz.be/geoserver/MarineRegions/ows?",
                   "service=WFS&version=1.0.0&",
                   "request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&",
                   "outputFormat=application/json")
regions <- sf::st_read(layerurl)

# read selected geographic layers for downloading
roi <- read_delim(file.path(dataDir,"regions.csv"), delim = ",")

# check by plotting
regions %>% filter(mrgid %in% roi$mrgid) %>%
  ggplot() +
  geom_sf(fill = "blue", color = "white") +
  geom_sf_text(aes(label = mrgid), size = 2, color = "white") +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())
ggsave(file.path(dataDir,"regionsOfInterest.png"), width = 3, height =  4, )

#== download data by geographic location and trait ===================
beginDate<- "1900-01-01"
endDate <- "2022-03-01"
attributeID1 <- "Benthos"
# Full occurrence (selected columns)
for(ii in 1:length(roi$mrgid)){
  mrgid <- roi$mrgid[ii]
  print(paste("downloading data for", roi$marregion[ii]))
  downloadURL <- paste0(
    "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&",
    "request=GetFeature&",
    "typeName=Dataportal%3Aeurobis-obisenv_full&",
    "resultType=results&",
    "viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B",mrgid,
    "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27",beginDate,
    "%27+AND+%27",endDate,
    "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+",
    "eurobis.taxa_attributes+WHERE+selectid+IN+%28%27",
    attributeID1,
    "%27%29%29%3Bcontext%3A0100&",
    "propertyName=datasetid%2C",
    "datecollected%2C",
    "decimallatitude%2C",
    "decimallongitude%2C",
    "scientificname%2C",
    "aphiaid%2C",
    "scientificnameaccepted%2C",
    "yearcollected%2C",
    "waterbody%2C",
    "country%2C",
    "recordnumber%2C",
    "fieldnumber%2C",
    "minimumdepthinmeters%2C",
    "maximumdepthinmeters%2C",
    "aphiaidaccepted%2C",
    "catalognumber%2C",
    "qc%2C",
    "eventid&",
    "outputFormat=csv")
  
  
  filename = paste0("region", roi$mrgid[ii], ".csv")
  data <- read_csv(downloadURL,col_types = "cnccTnccccnnnncccccn")
  write_delim(data, file.path(downloadDir, "byTrait", filename), delim = ",")
}
filelist <- list.files(file.path(downloadDir,"byTrait"))
allDataExtra <- lapply(filelist, function(x) 
  read_delim(file.path(downloadDir, "byTrait", x), 
             delim = ",", 
             col_types = "cnccTnccccnnnncccccn")) %>%
  set_names(sub(".csv", "", filelist)) %>%
  bind_rows(.id = "mrgid") %>%
  mutate(mrgid = sub("region", "", mrgid))
write_delim(allDataExtra, file.path(dataDir, "allDataExtra.csv"), delim = ",")
rm(layerurl,regions,roi,beginDate,endDate,attributeID1,mrgid,downloadURL,
   filename,data,allDataExtra)
gc()

