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
  if(model_type == 'mammalBirdVehicle'){
    #output_path <- "./"
    #path2weights <- file.path(output_path, "weights.pth")
    #path2weights <- system.file("lib/weights.pth", package="CameraTrapDetectoR")
    path2weights <- download_cache(url="https://www.dropbox.com/s/ms8zh3oj62113in/weights_mammalBirdHumanVehicle_20220124_cpu.pth?raw=1")
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)
    # load architecture
    #model <- torch::jit_load("fasterrcnn_4classes.pt")
    # model <- torch::jit_load(system.file("lib/fasterrcnn_4classes.pt", 
    #                                      package="CameraTrapDetectoR"))
    arch_path <- download_cache(url="https://www.dropbox.com/s/2lbd9t85knhhic2/fasterrcnn_5classes.pt?raw=1")
    model <- torch::jit_load(arch_path)
    #model <- torch::jit_load("mammalBirdVehicle.pt")
    model$load_state_dict(state_dict)
  }
  if(model_type == "general"){
    path2weights <- download_cache(url="https://www.dropbox.com/s/ms8zh3oj62113in/weights_mammalBirdHumanVehicle_20220124_cpu.pth?raw=1")
    #path2weights <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/output/20211228_fasterRCNN_mammalBirdHumanVehicle_16bs_15epochs_9momentum_0005weight_decay_005lr/weights_mammalBirdHumanVehicle_cpu.pth"
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)

    arch_path <- download_cache(url="https://www.dropbox.com/s/2lbd9t85knhhic2/fasterrcnn_5classes.pt?raw=1")
    #arch_path <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/fasterrcnn_5classes.pt"
    model <- torch::jit_load(arch_path)

    model$load_state_dict(state_dict)
  }
  if(model_type == "species"){
    path2weights <- download_cache(url="https://www.dropbox.com/s/f6i0520ichlk6d7/weights_species_20220126_cpu.pth?raw=1")
    #path2weights <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/output/20211228_fasterRCNN_mammalBirdHumanVehicle_16bs_15epochs_9momentum_0005weight_decay_005lr/weights_mammalBirdHumanVehicle_cpu.pth"
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)
    
    arch_path <- download_cache(url="https://www.dropbox.com/s/jdfjnbfagvn4hfq/fasterrcnnArch_77classes.pt?raw=1")
    #arch_path <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/fasterrcnn_5classes.pt"
    model <- torch::jit_load(arch_path)
    
    model$load_state_dict(state_dict)
  }
  if(model_type == "family"){
    path2weights <- download_cache(url="https://www.dropbox.com/s/lrm91l3gzadr118/weights_family_20220126_cpu.pth?raw=1")
    #path2weights <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/output/20211228_fasterRCNN_mammalBirdHumanVehicle_16bs_15epochs_9momentum_0005weight_decay_005lr/weights_mammalBirdHumanVehicle_cpu.pth"
    
    # load weights
    state_dict <- torch::load_state_dict(path2weights)
    # load the torchvision ops
    #dll_path <- download_cache(dll_url)
    #dyn.load(dll_path)
    
    arch_path <- download_cache(url="https://www.dropbox.com/s/7chzc8boc5ruxab/fasterrcnnArch_33classes.pt?raw=1")
    #arch_path <- "C:/Users/mtabak/projects/aphis_cftep_2021_2022/fasterrcnnArch_25classes.pt"
    model <- torch::jit_load(arch_path)
    
    model$load_state_dict(state_dict)
  }
  
  return(model)
}
                         
