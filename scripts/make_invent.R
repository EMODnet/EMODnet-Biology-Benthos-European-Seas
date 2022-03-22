### input
# allDataExtra
#
### output
# 
# file allDatasets.csv : a list of all potentially interesting datasets
# file allDatasets_selection.csv: a manual edit of the previous file, where two
#                 fields are added: include (TRUE/FALSE): use the data
#                                    complete (TRUE/FALSE): dataset looks for all species
# file invent.csv: a list of regions and datasets to be used
#
allDataExtra <- read_delim(file.path(dataDir, "allDataExtra.csv"), delim = ",",
                           col_types = "ncnccTnccccnnnncccccc")

allDataExtra <- allDataExtra %>% 
  mutate(datasetid = as.numeric(
    sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', 
                                    "", datasetid, fixed = T)))
datasetidsoi <- allDataExtra %>% distinct(datasetid)

#==== retrieve data by dataset =use function fdr from auxiliary functions=========

  all_info <- data.frame()
  for (i in datasetidsoi$datasetid){
    dataset_info <- fdr2(i)
    all_info <- rbind(all_info, dataset_info)
  }
  names(all_info)[1]<-"datasetid"
  write.csv(all_info,file=file.path(dataDir,"allDatasets.csv"),row.names = F)
  # Note
  # this step is followed by manual inspection of data sets, and selection
  # results in file "./data/derived_data/allDatasets_selection.csv"

if(!file.exists(file.path(dataDir,"allDatasets_selection.csv"))){
  stop("perform manual selection of datasets in allDatasets_selection.csv")
}else{
  getDatasets <- read_csv(file.path(dataDir,"allDatasets_selection.csv"))
  getDatasets <- getDatasets %>% filter(include)
  
  allDataExtra <- allDataExtra %>%
    filter(datasetid %in% getDatasets$datasetid)
  invent <- allDataExtra %>% count(mrgid,datasetid)
  write_delim(invent,file.path(dataDir,"invent.csv"),delim=",")
  rm(allDataExtra,datasetidsoi,all_info,getDatasets,invent)
  gc()
}
