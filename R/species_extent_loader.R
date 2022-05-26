#' Load data describing geographic extent of species presence
#' 
#' @return
#' 
#' @export
#' 
#' 
species_extent_loader <- function(){
  
  #--Download Species Extent Data
  data.path <- download_cache(url="https://raw.githubusercontent.com/TabakM/CameraTrapDetectoR/main/Data/species.extent.data.csv")
  
  #--Read Species Extent Data
  
  extent.data<-readr::read_csv(data.path)
  
  return(extent.data)
}#END Function
                         








