#' Find unique sets of polygons that overlap
#' 
#' Evaluates overlapping bounding boxes using user specified threshold that determines overlap and returns
#' sets of polygons that overlap
#' 
#' @param df The data frame containing bounding box values and predictions
#' @param overlap_threshold The threshold (proportion) used in determining which bounding boxes are considered unique detections
#' @return
#' 
#' @export
#' 


find_unique_sets <- function(df, overlap_threshold){  
  require(sf)
  
  #--Suppress SF warnings
  oldw <- getOption("warn")
  options(warn = -1)
  
  #--Add ID
  df$id <- rownames(df)
  
  #--Helper function - Make Polygons  
  lst <- lapply(1:nrow(df), function(x){
    res <- matrix(c(df[x, 'YMax'], df[x, 'XMin'],
                    df[x, 'YMax'], df[x, 'XMax'],
                    df[x, 'YMin'], df[x, 'XMax'],
                    df[x, 'YMin'], df[x, 'XMin'],
                    df[x, 'YMax'], df[x, 'XMin'])
                  , ncol =2, byrow = T
    )
    st_polygon(list(res))
  })
  
  #--Make polygons
  sfdf <- st_sf(geohash = df[, 'id'], st_sfc(lst))
  
  #--Intersect polygons
  #inter.val <- st_intersects(sfdf,sfdf)
  inter.val <- find_sets_with_threshold(x=sfdf, y=sfdf, overlap_threshold)
  
  #--Find unique sets
  unique.sets<-unique(inter.val)
  
  #--Turn warnings back on
  options(warn = oldw)
  
  return(unique.sets)
}#END Function