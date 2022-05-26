#' Evaluates if location falls within bounding box of extent
#' 
#' This function will evaluate if a location (latitude / longitude) is within
#' a bounding box representing a geographic extent. values with range.
#' 
#' @param location dataframe containing a single longitude and latitude value
#' @param extent.values dataframe containing xmin, xmax, ymin, ymax representing an extent (bounding box)
#' @return
#' 
#' @export


location.contained.in.extent<-function(location, extent.values){
  return((location$longitude > extent.values$xmin &
          location$longitude < extent.values$xmax &
          location$latitude > extent.values$ymin &
          location$latitude < extent.values$ymax))
}



