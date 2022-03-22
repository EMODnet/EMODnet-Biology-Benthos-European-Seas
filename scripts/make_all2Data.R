## input
# file regions.csv
# file invent.csv
#
### output
# downoadfiles (many!)
# file all2Data.csv with the 'final' downloads joined
#

roi <- read_delim(file.path(dataDir,"regions.csv"), delim = ",")
invent<-read_delim(file.path(dataDir,"invent.csv"),delim=',')


for(ii in 1:nrow(invent)){
  di <- invent$datasetid[ii]
  mg <- invent$mrgid[ii]
  region <- roi$marregion[roi$mrgid==mg]
  print(paste("downloading data for ", region, "and dataset nr: ", di))
  downloadURL <- 
    paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0",
           "&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&",
           "resultType=results&viewParams=where%3A%28%28up.geoobjectsids+",
           "%26%26+ARRAY%5B", mg,"%5D%29%29+AND+datasetid+IN+(",di,");",
           "context%3A0100&propertyName=datasetid%2C",
           "datecollected%2Cdecimallatitude%2Cdecimallongitude%2C",
           "coordinateuncertaintyinmeters%2C",
           "scientificname%2Caphiaid%2Cscientificnameaccepted%2C",
           "institutioncode%2Ccollectioncode%2C",
           "occurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2C",
           "kingdom%2Cphylum%2Cclass",
           "%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Caphiaidaccepted%2C",
           "basisofrecord%2Ceventid&",
           "outputFormat=csv")
  data <- read_csv(downloadURL, col_types = "ccccccTnnnccccccccccccccc") 
  filename = paste0("region", mg, "_datasetid", di,  ".csv")
  write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ",")
}

## Combine all downloaded datasets into one big dataset

filelist <- list.files(file.path(downloadDir,"byDataset"))
for(i in 1:length(filelist)){
  ininf <- read_delim(file.path(downloadDir,"byDataset", filelist[i]), 
                      delim = ",", 
                      col_types = "ccccccTnnnccccccccccccccc")%>%
    mutate(fileID=filelist[i])  %>%
    separate(fileID,c("mrgid","datasetID","_"))%>%
    mutate(mrgid = sub("[[:alpha:]]+", "", mrgid)) %>%
    mutate(datasetID = sub("[[:alpha:]]+", "", datasetID))%>%
    mutate(AphiaID=as.numeric(substr(aphiaidaccepted,52,65)))%>%
    filter(!is.na(AphiaID)) %>%
    filter(!is.na(decimallongitude)) %>%
    filter(!is.na(decimallatitude)) %>%
    filter(!is.na(datecollected)) %>%
    select(-aphiaid) %>%
    select(-aphiaidaccepted)%>%
    select(-`_`)%>%
    select(-datasetid) %>%
    select(-FID)%>%
    select(-scientificnameid)
  
  if(i==1)app<-FALSE else app<-TRUE
  write_delim(ininf,file.path(dataDir,"all2Data.csv"),append=app,delim=',')
  rm(roi,invent,all2Data,filelist,ininf,filename,data,downloadURL,di,mg,region,i)
  gc()
}
