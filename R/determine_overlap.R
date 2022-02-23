#' Finds overlap of two bounding boxes
#' 
#' Helper function that returns the proportion of overlap among two bounding boxes
#' 
#' @param a Bounding box that will be compared with b
#' @param b Bounding box 
#' @return
#' 
#' @export
#' 

determine_overlap <- function(a,b){
  
  dx = min(a$XMax, b$XMax) - max(a$XMin, b$XMin)
  dy = min(a$YMax, b$YMax) - max(a$YMin, b$YMin)

  if(dx>=0 & dy>=0){
    r.overlap<-dx*dy
    
    area.a <- (a$XMax - a$XMin) * (a$YMax - a$YMin)
    area.b <- (b$XMax - b$XMin) * (b$YMax - b$YMin)
    per.overlap <- r.overlap / (area.a+area.b-r.overlap)
  } else{per.overlap<-0}
  
  return(per.overlap)
}#END Function





