plotraster <- function(specnr,netcdf_fil){
  if(!file.exists(netcdf_fil)){
    stop("first make the netcdf output file")
  }
  # define a raster covering the grid. Set resolution of the raster here
  r<-raster(ext=extent(-36,61,26,82),ncol=480,nrow=380,crs=proWG,vals=0)
  # read input from netcdf file
  ncfil<-nc_open(netcdf_fil)
  lats<-ncvar_get(ncfil,"lat")
  lons<-ncvar_get(ncfil,"lon")
  spec_names <- ncvar_get(ncfil,"Taxon_Name")
  aphiaids <- ncvar_get(ncfil,"AphiaID")
  presabs<-ncvar_get(ncfil,"Pres_abs",start=c(1,specnr),count=c(-1,1))
  nc_close(ncfil)
  
  aphiaids <- sub("urn:lsid:marinespecies.org:taxname:","",aphiaids)
  spe<-data.frame(lat=lats,lon=lons,pres_abs=NA)
  coordinates(spe)<- ~lon+lat
  projection(spe)<-proWG
  
  spe_sp<-spe
  spe_sp$pres_abs<-presabs
  spe_spe<-spe_sp[!is.na(spe_sp$pres_abs),]
  r1<-rasterize(spe_sp,r,field="pres_abs",fun=mean)
  
  legend="P(pres)"
  specname <- spec_names[specnr]
  spAphId <- aphiaids[specnr]
  ec<-emodnet_colors()
  plot_grid <- emodnet_map_plot_2(data=r1,title=specname,
                                  subtitle=paste0('AphiaID ', spAphId),
                                  zoom=TRUE,seaColor=ec$darkgrey,
                                  landColor=ec$lightgrey,legend=legend)
  print(plot_grid)
  filnam<-file.path(plotsDir, 
                    paste0(sprintf("%04d",specnr), "_",spAphId, "_",
                           gsub(" ", "-", specname),".png"))
  
  emodnet_map_logo(plot_grid,path=filnam,width=120,height=160,dpi=300,
                   units="mm",offset="+0+0")
}

