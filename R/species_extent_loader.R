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
  extent.data<-read.csv(data.path, stringsAsFactors=TRUE)

  #extent.data<-readr::read_csv(data.path, show_col_types=FALSE, progress=FALSE)
  #extent.data<-as.data.frame(extent.data)
  
  return(extent.data)
}#END Function
                         








