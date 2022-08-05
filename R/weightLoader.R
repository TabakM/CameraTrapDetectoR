#' Load the trained model
#' 
#' Loads the weights for the pretrained model. 
#' 
#' @param model_type The type of model you want to deploy:
#'  c('mammalBirdVehicle', '')
#' @param num_classes The number of classes in the model
#' @return
#' 
#' @export
#' 
weightLoader <- function(
  model_type = 'general',
  num_classes = 5
  ){
  
  # determine if windows or mac so I can load the dll file 
  windows <- ifelse(Sys.info()["sysname"] == "Windows", TRUE, FALSE)

  # set the url for the dll file
  #dll_url <- ifelse(windows, 
  #                  "https://www.dropbox.com/s/c11047y65mczbw5/torchvision.dll?raw=1",
  #                  "https://www.dropbox.com/s/bpsggm6o54czqus/libtorchvision.dylib?raw=1")
  
  # based on model type, get path 2 weights and number of classes
  if(model_type == 'pig_only'){
    #path2weights <- download_cache(url="https://www.dropbox.com/s/pv76miytqc7lp00/weights_pig_only_20220309_cpu.pth?raw=1")
    
    # AB : use relabeled family weights until we can retrain pig-only model
    path2weights <- download_cache(url="https://www.dropbox.com/s/9u4isbz0fv4gwda/weights_family_20220308_cpu.pth?raw=1")
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)
    # load architecture
    #model <- torch::jit_load("fasterrcnn_4classes.pt")
    # model <- torch::jit_load(system.file("lib/fasterrcnn_4classes.pt", 
    #                                      package="CameraTrapDetectoR"))
    
    # AB : use family classifications until pig model can be retrained
    #arch_path <- download_cache(url="https://www.dropbox.com/s/68xvf4mgwpij2tv/fasterrcnnArch_2classes.pt?raw=1")
    arch_path <- download_cache(url="https://www.dropbox.com/s/obqc1ffmnq1hprq/fasterrcnnArch_33classes.pt?raw=1")
    
    model <- torch::jit_load(arch_path)
    #model <- torch::jit_load("mammalBirdVehicle.pt")
    model$load_state_dict(state_dict)
  }
  if(model_type == "general"){
    path2weights <- download_cache(url="https://www.dropbox.com/s/mrlwow1935v97yd/weights_mammalBirdHumanVehicle_20220124_cpu.pth?raw=1")
    #path2weights <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/output/20211228_fasterRCNN_mammalBirdHumanVehicle_16bs_15epochs_9momentum_0005weight_decay_005lr/weights_mammalBirdHumanVehicle_cpu.pth"
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)

    arch_path <- download_cache(url="https://www.dropbox.com/s/40ms1ly823uw44j/fasterrcnnArch_5classes.pt?raw=1")
    #arch_path <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/fasterrcnn_5classes.pt"
    model <- torch::jit_load(arch_path)

    model$load_state_dict(state_dict)
  }
  if(model_type == "species"){
    path2weights <- download_cache(url="https://www.dropbox.com/s/f6i0520ichlk6d7/weights_species_20220126_cpu.pth?raw=1")
    #path2weights <- download_cache(url="https://www.dropbox.com/s/20sd2ikmda2omnd/weights_species_20220308_cpu.pth?raw=1")
    #path2weights <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/output/20211228_fasterRCNN_mammalBirdHumanVehicle_16bs_15epochs_9momentum_0005weight_decay_005lr/weights_mammalBirdHumanVehicle_cpu.pth"
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)
    
    arch_path <- download_cache(url="https://www.dropbox.com/s/jdfjnbfagvn4hfq/fasterrcnnArch_77classes.pt?raw=1")
    #arch_path <- download_cache(url="https://www.dropbox.com/s/fyamyq463u003ve/fasterrcnnArch_77classes.pt?raw=1")
    #arch_path <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/fasterrcnn_5classes.pt"
    model <- torch::jit_load(arch_path)
    
    model$load_state_dict(state_dict)
  }
  if(model_type == "family"){
    path2weights <- download_cache(url="https://www.dropbox.com/s/9u4isbz0fv4gwda/weights_family_20220308_cpu.pth?raw=1")
    #path2weights <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/output/20220308_fasterRCNN_family_smallerAnchorBoxes_16bs_25epochs_9momentum_0005weight_decay_005lr/weights_family_20220308_cpu.pth"
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)
    
    arch_path <- download_cache(url="https://www.dropbox.com/s/obqc1ffmnq1hprq/fasterrcnnArch_33classes.pt?raw=1")
    #arch_path <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/arch/fasterrcnnArch_33classes.pt"
    model <- torch::jit_load(arch_path)
    
    model$load_state_dict(state_dict)
  }
  
  return(model)
}
                         
