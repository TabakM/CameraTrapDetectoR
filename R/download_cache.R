#' download files needed to run the mdoel
#' 
#' This function will download necessary files and store them in the package space
#' 
#' @param url location of file to download
#' @param redownload boolean. Re-download the file?
#' 
#' @import rappdirs
#' @import fs
#' 
#' @export
#' 
download_cache <- function(url = "https://www.dropbox.com/s/m4ojnotd2pev46u/weights_family_cpu.pth?raw=1",
                           redownload = FALSE){
  # set destination
  #destination <- system.file(path2store, package="CameraTrapDetectoR")
  cache_path <- rappdirs::user_cache_dir("CameraTrapDetector")
  
  fs::dir_create(cache_path)
  # create a file path to save. Need to remove the raw part
  path <- file.path(cache_path, gsub("\\?raw=1", "", fs::path_file(url)))
  
  if (!file.exists(path) || redownload){
    cat(paste0("downloading ", gsub("\\?raw=1", "", fs::path_file(url)), " file\n"))
    utils::download.file(url, path, mode = "wb")
  }
  return(path)
}