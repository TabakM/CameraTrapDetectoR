#' Convenience function that loads operators
#' 
#' @description This function loads operators used by other functions.
#' 
#' @export



load_operators<-function(){

#--Define operator not in
'%!in%' <- function(x,y) !('%in%'(x,y))

}

#--END

