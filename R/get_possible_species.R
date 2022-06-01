#' Get List of Possible Species
#' 
#' This function will evaluate the user provided latitude / longitude values with range
#' extent data for species included in the trained models and will return a list of possible species.
#' 
#' @param location dataframe containing a single longitude and latitude value
#' @return
#' 
#' @export


get_possible_species <- function(location){

  #--Test which species to consider
  location.test <- vector()
  
  for(i in 1:nrow(extent.data)){
    location.test[i]<-location_contained_in_extent(location, extent.data[i,])
  }#END Loop
  
  possible.species <- extent.data[location.test==TRUE,]

  #--Generate unique set of species 
  possible.species <- unique(possible.species[,c("taxa","label","model_type")])
  
  possible.species <- possible.species[order(possible.species$taxa, possible.species$label),]
  
return(possible.species)
}#END Function






