
# library(shiny)
# library(shinyFiles)
# library(shinyjs)
# library(shinyBS)
# library(CameraTrapDetectoR)

# made a function for showing console output in UI
withConsoleRedirect <- function(containerId, expr) {
  
  txt <- utils::capture.output(results <- expr, type = "output")
  
  if (length(txt) > 0) {
    
    # remove the loading bars
    txt <- lapply(txt, function(x){
      if(substr(x, nchar(x)-3, nchar(x)) != "100%"){
        return(x)
      } else {
        return("")
      }
      
    })
    
    shiny::insertUI(paste0("#", containerId), where = "beforeEnd", 
                    ui = paste0(txt, "\n", collapse = "")
    )
  }
  results
}
