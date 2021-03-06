
# STEP 1: be sure to pull ohiprep
# main difference will be that this will load the old version of ohicore (prior to the changes made to resilience)

library(devtools)
# This uses the old archived version of ohicore. Eventually, we will want to make updates and move to the new version, but not yet.
devtools::install_github("ohi-science/ohicore@master_a2015") 
library(ohicore)
library(zoo)

setwd("~/ohi-global")

source('../ohiprep/src/R/common.R')

# new paths based on host machine
dirs = list(
  neptune_data  = dir_M, 
  neptune_local = dir_M,
  ohiprep       = '../ohiprep',
  ohicore       = '../ohicore')


do.layercopy  = T
do.layercheck = T
do.calculate  = T
do.other      = F

# scenario list (need to add new scenarios here)
scenarios = list(
  antarctica2015_seaice_explore = list(
    layer   = 'layers_antarctica',
    fld_dir      = 'dir_2015a',
    fld_fn       = 'fn_2015a',
    f_spatial    = c('../ohiprep/Global/NCEAS-Regions_v2014/data/regions_gcs.js'),
    do           = T)
  )


for (i in 1:length(scenarios)){  #i=1
  
  # vars
  scenario   = names(scenarios)[[i]]
  fld_dir    = scenarios[[i]][['fld_dir']]
  fld_fn     = scenarios[[i]][['fld_fn']]
  layer = scenarios[[i]][['layer']]
  do         = scenarios[[i]][['do']]
  
    print(scenario)
    print(fld_dir)
    print(fld_fn)
    print(do)
  
  
  if (!do) next()
  
  cat(sprintf('\nScenario: %s\n', scenario))
  
  # create dirs
  dirs_scenario = c(scenario, sprintf('%s/%s', scenario, c('temp','layers','conf','spatial')))
  for (dir in dirs_scenario) {
    if (!file.exists(dir)) dir.create(dir, showWarnings=F)
  }
  
#   if (do.layercopy){
# #     # load Google spreadsheet for copying layers
# #     cat(sprintf('\n  Google spreadsheet editable URL:\n    https://docs.google.com/spreadsheet/ccc?key=%s\n', google_key) )
# #     g.url = sprintf('https://docs.google.com/spreadsheets/d/%s/export?gid=0&format=csv', scenarios[[i]][['google_key']])
# #     g = read.csv(textConnection(RCurl::getURL(g.url, ssl.verifypeer = FALSE)), skip=1, na.strings='', stringsAsFactors=F)
# #     write.csv(g, sprintf('%s/temp/layers_0-google.csv', scenario), na='', row.names=F)
# 
# ## Read in the layers.csv file with paths to the data files
#  g <- read.csv(sprintf("%s.csv", layer), stringsAsFactors = FALSE, na.strings='')    
#  
#  # carry forward file paths and names when no data for 2014 and/or 2015
#     if (as.numeric(gsub("[a-z]", "", scenario)) > 2013){
#       g = g %>%
#         dplyr::mutate(
#           dir_2014a = ifelse(is.na(dir_2014a), dir_2013a, dir_2014a),
#           fn_2014a = ifelse(is.na(fn_2014a), fn_2013a, fn_2014a)) %>%
#         dplyr::mutate(
#           dir_2015a = ifelse(is.na(dir_2015a), dir_2014a, dir_2015a),
#           fn_2015a = ifelse(is.na(fn_2015a), fn_2014a, fn_2015a))
#       }
#     
#     # replaces 'ohiprep' and 'neptune_data' parts of the filepath with the full file paths
#     # 'ohiprep' files are located here: https://github.com/OHI-Science/ohiprep
#     # 'neptune_data' files are located on the NCEAS Neptune server
#     g$dir_in = sapply(
#       str_split(g[[fld_dir]], ':'),   
#       function(x){ sprintf('%s/%s', dirs[x[1]], x[2])})
#     
#     g$fn_in = g[[fld_fn]]
#     
#     # filters the data and determines whether the file is available, saves a copy to tmp folder
#     lyrs = g %>%
#       filter(ingest==T) %>%
#       mutate(
#         path_in        = file.path(dir_in, fn_in),
#         path_in_exists = file.exists(path_in),
#         filename = sprintf('%s.csv', layer),
#         path_out = sprintf('%s/layers/%s', scenario, filename)) %>%
#       select(
#         targets, layer, name, description, 
#         fld_value, units,
#         path_in, path_in_exists, filename, path_out) %>%
#       arrange(targets, layer)
#     write.csv(lyrs, sprintf('%s/temp/layers_1-ingest.csv', scenario), na='', row.names=F)
#     
#     # checks that all data layers are available based on file paths 
#     if (nrow(filter(lyrs, !path_in_exists)) != 0){
#       message('The following layers paths do not exist:\n')
#       print(filter(lyrs, !path_in_exists) %>% select(layer, path_in), row.names=F)
#       stop('Data cannot be found - check file paths/names in layers.csv' )
#     }
#     
#     # copy layers into specific scenario / layers file 
#     for (j in 1:nrow(lyrs)){ # j=4
#       stopifnot(file.copy(lyrs$path_in[j], lyrs$path_out[j], overwrite=T))
#     }
#     
#     # delete extraneous files
#     files_extra = setdiff(list.files(sprintf('%s/layers',scenario)), as.character(lyrs$filename))
#     unlink(sprintf('%s/layers/%s', scenario, files_extra))
#     
#     # layers registry
#     write.csv(select(lyrs, -path_in, -path_in_exists, -path_out), sprintf('%s/layers.csv', scenario), row.names=F, na='')
#   }
  
  if (do.layercheck){
    # load conf
    conf   = Conf(sprintf('%s/conf', scenario))
    
    # run checks on layers
    CheckLayers(layers.csv = sprintf('%s/layers.csv', scenario), 
                layers.dir = sprintf('%s/layers', scenario), 
                flds_id    = conf$config$layers_id_fields)
    # system(sprintf('open %s/layers.csv', scenario))
  }
  
  if (do.calculate){
    # calculate scores from directory of scenario
    setwd(sprintf('%s', scenario)) # load_all(dirs$ohicore)
   
    # load configuration and layers
    conf   = Conf('conf')
    layers = Layers('layers.csv','layers')
  
    
    # calculate scores
    #try({    })
    scores = CalculateAll(conf, layers, debug=T)
    write.csv(scores, 'scores.csv', na='', row.names=F)
    
    # restore working directory
    setwd('..') 
    
    # archive scores on disk (out of github, for easy retrieval later)
    csv = sprintf('%s/git-annex/Global/NCEAS-OHI-Scores-Archive/scores/scores_%s_%s.csv', 
                  dirs$neptune_data, scenario, format(Sys.Date(), '%Y-%m-%d'))
    write.csv(scores, csv, na='', row.names=F)    
  }
  
  if (do.other){
    # spatial  
    for (f in scenarios[[scenario]][['f_spatial']]){ # f = f_spatial[1]
      stopifnot(file.exists(f))
      file.copy(f, sprintf('%s/spatial/%s', scenario, basename(f)))
    }
    
    # delete old shortcut files
    for (f in c('launchApp.bat','launchApp.command','launchApp_code.R','scenario.R')){
      path = sprintf('%s/%s',scenario,f)
      if (file.exists(path)) unlink(path)
    }
    
    # save shortcut files not specific to operating system
    write_shortcuts(scenario, os_files=0)
    
    # launch on Mac # setwd('~/github/ohi-global/eez2013'); launch_app()
    #system(sprintf('open %s/launch_app.command', scenario))
  }
}

##### Compare scores with adjusted seaice reference point and original scores

scores_si <- read.csv('antarctica2015_seaice_explore/scores.csv') %>%
  rename(scores_si_ref=score)

scores <- read.csv('antarctica2015/scores.csv') %>%
  left_join(scores_si) %>%
  mutate(change_in_score = scores_si_ref - score)

write.csv(scores, "antarctica2015_seaice_explore/change_in_score.csv", row.names=FALSE)
