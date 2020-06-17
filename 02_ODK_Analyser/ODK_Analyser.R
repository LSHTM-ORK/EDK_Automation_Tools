con<-file("analysis.log")
sink(con, append=TRUE)
sink(con, append=TRUE, type="message")


  #set pandoc - in Rscript calls run by cron, you may need to define the correct location of pandoc. 
  Sys.setenv(RSTUDIO_PANDOC="/usr/bin/")


  ################################################################################################################
  #PULL FROM ARCHIVER
  ################################################################################################################
  {
  rm(list=ls())
  unlink("Output/",recursive = T)
  system("cp -rf ~/Documents/Hilary/Documents/Archiver_project_01/Data/Output  ./Output")
  unlink("report/",recursive = T)
  unlink("*.zip")

  }


  ################################################################################################################
  #DEFINE THE DIRECTORIES FOR ANALYSIS
  ################################################################################################################


  {
    #directories
    export.dir.name <- paste(getwd(),"Output",sep="/")
    report.dir.name <- paste(getwd(),"report",sep="/")
  }



  ################################################################################################################
  #create directories if needed
  ################################################################################################################
  {
    if(!file.exists(export.dir.name)){dir.create(export.dir.name)}
    if(!file.exists(report.dir.name)){dir.create(report.dir.name)}
  }


  ################################################################################################################
  # Run other scripts to perform main analyses
  ################################################################################################################
  source("Analysis_Script_01.R")
  source("Analysis_Script_02.Rmd")
  ################################################################################################################


  ################################################################################################################
  # Write an R object
  ################################################################################################################

  message("writing workspace")
  save.image(compress = "gzip",safe = TRUE,file = "WORKSPACE.Rdata")


  message("All analysis finished")
