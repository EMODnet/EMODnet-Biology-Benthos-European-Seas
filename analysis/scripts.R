scriptsDir <- "scripts"

source(file.path(scriptsDir,"setbasics.R"))
source(file.path(scriptsDir,"auxiliary_functions.R"))
# first round of downloading data
if(!file.exists(file.path(dataDir,"allDataExtra.csv"))){
  source(file.path(scriptsDir,"make_allDataExtra.R"))
}
# summarizing what data files need download
if(!file.exists(file.path(dataDir,"invent.csv"))){
  source(file.path(scriptsDir,"make_invent.R"))
}
# second round of downloading data
if(!file.exists(file.path(dataDir,"all2Data.csv"))){
  source(file.path(scriptsDir,"make_all2Data.R"))
}
# downloading taxa attributes
if(!file.exists(file.path(dataDir,"nsp_attr.csv"))){
  source(file.path(scriptsDir,"make_nsp_attr.R"))
}
# selecting taxa to use
if(!file.exists(file.path(dataDir,"sp2use.csv"))){
  source(file.path(scriptsDir,"make_sp2use.R"))
}
# building presence/absence data base
if(!file.exists(file.path(mapsDir,"spe.Rdata"))){
  source(file.path(scriptsDir,"make_pres_abs_file.R"))
}
