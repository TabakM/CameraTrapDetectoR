#' Determine polygons that overlap
#' 
#' Evaluates overlapping bounding boxes.  Applies a proportional threshold and
#' only evaluates bounding boxes that have an overlap greater than that proportion. 
#' 
#' @param x sf object containing polygons
#' @param y sf object containing polygons to compare with x
#' @param overlap_threshold The threshold (proportion) used in determining which
#' bounding boxes are considered unique detections
#' @return
#' 
#' @export
#' 


find_sets_with_threshold <- function(x, y, overlap_threshold) {
  require(sf)
  
  int = st_intersects(x, y)
  lapply(seq_along(int), function(ix)
    if (length(int[[ix]]))
      int[[ix]][which(st_area(st_intersection(x[ix,], y[int[[ix]],]))/st_area(x[ix,]) > overlap_threshold)]
    else
      integer(0)
  )
}#END Function 


