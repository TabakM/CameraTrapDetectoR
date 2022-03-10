#' Create the dataset
#' 
#' This function sets up the dataset 
#' 
#' @param data_dir data directory
#' @param recursive boolean
#' @param file_extensions file extensions
#' @param labeled boolean. not functional yet
#' @return
#' 
#' @export
dataset <- function(data_dir,
                       recursive = TRUE,
                       file_extensions = c(".jpg", ".JPG"),
                       labeled = FALSE){
  
  # check that datadir exists
  if(!dir.exists(data_dir)){
    stop(paste0("data_dir: ", data_dir, " does not exist! Please specify
                an path that exists on your computer. "))
  }
  
  # list all files in data_dir
  file_list <- list.files(data_dir,full.names = TRUE,recursive = recursive,
                          pattern = paste0(file_extensions, collapse="|"))
 
  if(length(file_list) < 1){
    stop(paste0("There are no files in your data_dir with the specified file extensions."))
  }
  
  return(file_list)
   
}