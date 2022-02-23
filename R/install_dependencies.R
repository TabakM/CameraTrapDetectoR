#' Function to install packages
#' 
#' This function will install packages that are needed in CameraTrapDetectoR
#' 
#' @param packages packages to be installed, as a vector. If you are planning to use 
#'  the Shiny App, leave this value as default. If you want to avoid installing the
#'  Shiny-specificy dependencies, use \code{packages=c('torchvision', 'torch', 'magick')}
#' 
#' @return 
#' 
#' @export

install_dependencies <-function(packages=c('torchvision', 'torch', 'magick', 
                                           'shiny', 'shinyFiles', 'shinyBS', 
                                           'shinyjs', 'rappdirs', 'fs', 'operators')) {
  cat(paste0("checking package installation on this computer"))
  libs<-unlist(list(packages))
  req<-unlist(lapply(libs,require,character.only=TRUE))
  need<-libs[req==FALSE]
  
  if(length(need)>0){ 
    cat(paste0("The packages: ", need, "\n Need to be installed. Installing them now.\n"))
    utils::install.packages(need)
    lapply(need,require,character.only=TRUE)
  } else{
    cat("All necessary packages are installed on this computer. Proceed.\n")
  }
}