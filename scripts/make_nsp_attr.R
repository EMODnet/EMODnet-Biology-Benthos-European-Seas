# Download attributes of all taxa in the file all2Data.csv
# input: all2Data.csv
#
all2Data<-read_delim(file.path(dataDir, "all2Data.csv"), delim = ",",
                     col_types = "ncccTnnnccccccccccccnnn")

nsp_attr<-tibble()
splst <- all2Data %>% 
  select(AphiaID,scientificnameaccepted,phylum,class,order,family,genus,
         subgenus) %>% 
  distinct() %>%
  mutate(benthos=FALSE,endobenthos=FALSE,macrobenthos=FALSE,epibenthos=FALSE,
         meiobenthos=FALSE,phytobenthos=FALSE,
         plankton=FALSE,nekton=FALSE,Pisces=FALSE,Algae=FALSE,
         Aves_tax=FALSE,Pisces_tax=FALSE,Algae_tax=FALSE,Plants_tax=FALSE,
         meio_tax=FALSE,micro_tax=FALSE,misc_tax=FALSE)

for(i in 1:nrow(splst)){
  print(paste(i,"out of",nrow(splst),"downloading attributes of species",
              splst$scientificnameaccepted[i],"AphiaID",splst$AphiaID[i]))
  ttt<-NULL
  try(ttt<-wm_attr_data(id=splst$AphiaID[i],include_inherited = T),silent = T)
  if(! is.null(ttt)) nsp_attr<-rbind(nsp_attr,ttt[,1:9])
}
nsp_attr <- nsp_attr %>%
  mutate(AphiaID=as.numeric(AphiaID)) %>%
  left_join(splst,by="AphiaID")
write_delim(nsp_attr,file.path(dataDir,"nsp_attr.csv"),delim=",")

# clean up
rm(all2Data,nsp_attr,ttt,splst)
gc()
