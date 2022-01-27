#' A wrapper function to run Shiny Apps from \code{CameraTrapDetectoR}.
#' 
#' Running this function will launch a shiny application to deploy object detection models
#'  on camera trap images
#' @param app The name of the app you want to run. The options are currently 
#' `deploy`.
#' @return
#' 
#' @import shiny
#' @import shinyFiles
#' @import shinyBS
#' @rawNamespace import(shinyjs, except = runExample)
#' 
#' @export

runShiny <- function(app="deploy"){
  
  # find and launch the app
  appDir <- system.file("shiny-apps", app, package = "CameraTrapDetectoR")
  
  shiny::runApp(appDir, display.mode = "normal")
}
