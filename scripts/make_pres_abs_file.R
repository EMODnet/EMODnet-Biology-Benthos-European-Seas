# needed files #
# all2Data.csv
# sp2use.csv
# allDatasets_selection.csv

#########################
# output file: netcdf file with samples, species and presence/absence information
#
#### read input #############
trec<-read_delim(file.path(dataDir, "all2Data.csv"), delim = ",",
                     col_types = "ncccTnnnccccccccccccnnn")
sp2use<-read_delim(file.path(dataDir,"sp2use.csv"),delim=",",
                   col_types = "dccccccclllllllllllllllll")
trdi<-read_delim(file.path(dataDir,"allDatasets_selection.csv"),delim=',',
                 col_types="nccccccccllcc")

##########################################################
##### select few columns to work with
##### and filter to true benthic species only
##########################################################
trec<- trec %>% 
  dplyr::select(eventDate=datecollected,
                decimalLongitude=decimallongitude,
                decimalLatitude=decimallatitude,
                scientificName=scientificnameaccepted,
                aphiaID=AphiaID,
                datasetid=datasetID) %>%  
  filter(aphiaID %in% sp2use$AphiaID)
##############################################################
# Define 'sampling events' as all records that share time and place, give
# ID numbers to all events (eventNummer), and store the eventNummer in each
# record of trec
##############################################################
events<- trec %>% dplyr::select(eventDate,decimalLongitude,
                                decimalLatitude,datasetid) %>% 
  distinct() %>%
  mutate(eventNummer=row_number())

trec <- trec %>% 
  left_join(events,by=c('eventDate','decimalLongitude',
                        'decimalLatitude','datasetid')) %>%
  distinct(eventDate,decimalLongitude,decimalLatitude,
           scientificName,aphiaID,datasetid,eventNummer)


########### work on datasets
#
#### check on completeness
#
# nsp<-trec %>% group_by(datasetid) %>% 
#   distinct(aphiaID)    %>%
#   mutate(nspec=n())    %>%
#   dplyr::select(datasetid,nspec) %>%
#   distinct()
# nev<-trec %>% group_by(datasetid)     %>% 
#   distinct(eventNummer)    %>%
#   mutate(nev=n())          %>%
#   dplyr::select(datasetid,nev) %>%
#   distinct()                    %>%
#   left_join(nsp,by='datasetid')%>%
#   left_join(trdi,by='datasetid')
# #
#plot(nev$nev,nev$nspec,log="xy",col=ifelse(nev$complete,"blue","red"),pch=19,
#     xlab="number of events in dataset",ylab="number of species in dataset")
#text(nev$nev*1.2,nev$nspec*(1+(runif(nrow(nev))-0.5)*0.4),nev$datasetid,cex=0.5)
##############################################################
# find occurrence frequency of all species, and rank the species accordingly
#
spfr<- trec %>% 
  group_by(aphiaID,scientificName) %>%
  summarize(n_events=n()) %>%
  arrange(desc(n_events))
nsptoplot<-length(which(spfr$n_events>0))
############ 
# 
# manage the incomplete datasets
#
trdi_ct<-trdi %>% filter (complete)
trdi_ic<-trdi %>% filter (!complete)
# make a species list for each incomplete dataset
ic_sp<-data.frame(datasetid=NULL,aphiaID=NULL)
for(i in 1:nrow(trdi_ic)){
  ds<-trdi_ic$datasetid[i]
  specs<-unique(trec$aphiaID[trec$datasetid==ds])
  ic_sp<-rbind(ic_sp,data.frame(datasetid=rep(ds,length(specs)),aphiaID=specs))
}
# and add the complete datasets
for(i in 1:nrow(trdi_ct)){
  ds<-trdi_ct$datasetid[i]
  specs<-spfr$aphiaID
  ic_sp<-rbind(ic_sp,data.frame(datasetid=rep(ds,length(specs)),aphiaID=specs))
}

# write events and species list
write_delim(events,file=file.path(mapsDir,"events.csv"),delim=",")
write_delim(spfr,file=file.path(mapsDir,"spfr.csv"),delim=",")

#create output netcdf file if it does not yet exist
# This is a precaution against overwriting a file that takes hours to build
netcdf_fil <- file.path(mapsDir,"Macrobenthos_Eur_Seas_Pres_Abs_v0-3.nc")
if(file.exists(netcdf_fil)){
  stop("netcdf file already exists. Delete it if you want to create new one")
}else{
  source("./scripts/create_netcdf_output.R")
  create_netcdf_output(events,spfr,netcdf_fil)
}

# now produce the output and write it into the netcdf file
ncout<-nc_open(netcdf_fil,write=TRUE)

spmin<-1
spmax<-nsptoplot
#nams <- as.vector(spfr$scientificName)
pb <- progress_bar$new(total=nsptoplot)

for(ss in spmin:spmax){
    spAphId<-spfr$aphiaID[ss]
    pb$tick()
    # from the list of datasets, check if they have our species. 
    # Only keep these, drop the others
    tt_ds<- ic_sp                      %>% 
      filter(aphiaID==spAphId) %>%
      distinct(datasetid)      #      %>% 
    # The datasets to be used consist of all complete datasets, and all 
    # incomplete datasets that targeted our species
    spe<- trec                                                      %>% 
      filter(datasetid %in% tt_ds$datasetid)                  %>%
      group_by(eventNummer)                                   %>%
      summarize(pres_abs= any(aphiaID==spAphId),.groups = 'drop')  %>%
      full_join(events,by='eventNummer') %>%
      arrange(eventNummer)
    ncvar_put(ncout,"Pres_abs",as.numeric(spe$pres_abs),
              start=c(1,ss),count=c(-1,1))
}
nc_close(ncout)

