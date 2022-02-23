#' Applies Score Threshold to Predictions and Calculates confidence that the image is empty
#' 
#' This function removes detections that fall below the score_threshold.  When an image
#' has all detections removed it is assigned a value of 'empty'. The confidence in the
#' prediction that the image is empty is calculated as 1 - max(x) where x is a vector of
#' confidence values for the detections that fall below score threshold. So the confidence
#' that the image is empty is assumed to be directly related to the largest confidence in
#' the detections that will be removed.
#' 
#' @param df Dataframe of predictions from model
#' @param file_list Vector of file names processed by model
#' @param score_threshold Threshold score for keeping bounding boxes
#' @return
#' 
#' @export


apply_score_threshold <- function(df, file_list, score_threshold){
  
  #--Save those that are >= score_threshold
  limted_df <- df[df$confidence_in_pred >= score_threshold,]
  
  #--Generate list of images that have been removed
  empty.images<-normalizePath(file_list[normalizePath(file_list) %!in% limted_df$filename])
  
  #--If applying threshold results in empty images
  if(length(empty.images)>0){
  
  #--Set up storage
  pr.empty <- vector()
  cnt.detections <- vector()
  
  #--Make confidence of being empty
  for(i in 1:length(empty.images)){
    pr.empty[i] <- 1-max(df[df$filename %in% empty.images[i],"confidence_in_pred"])
    cnt.detections[i] <- nrow(df[df$filename %in% empty.images[i],])
  }
  
  #--Make Empty images data frame
  empty_df <- cbind.data.frame(filename=empty.images,
                               prediction=rep("empty",length(empty.images)),
                               confidence_in_pred = pr.empty,
                               number_predictions = cnt.detections
                               )
  
  #--Merge
  out_df <- rbind.data.frame(limted_df, empty_df)
  }
  
  #--If applying threshold does not results in empty images
  if(length(empty.images)==0){
    out_df <- limted_df
  }
  
  return(out_df)
}#END Function

