#' Find overlapping bounding boxes and return classification with maximum confidence
#' 
#' Evaluates overlapping bounding boxes using user specified threshold that determines overlap and returns
#' bounding boxes and classification with maximum confidence
#' 
#' @param df The data frame containing bounding box values and predictions
#' @param overlap_threshold The threshold (proportion) used in determining which bounding boxes are considered unique detections
#' @return
#' 
#' @export
#' 


reduce_overlapping_bboxes <- function(df, overlap_threshold=0.8){
  
  #--Find unique polygon sets
  unique.sets <- find_unique_sets(df, overlap_threshold=overlap_threshold)
  
  #--Initialize Storage
  out<-df[0,]
  
  #--Find maximum confidence for each polygon set
  for(j in 1:length(unique.sets)){
    tmp<-df[unique.sets[[j]],]
    out[j,]<-tmp[which.max(df[unique.sets[[j]],"scores"]),]
    out[j,"number_bboxes"] <- length(unique.sets[[j]])
  }
  
  #--When highest Ensure no duplicates
  out<-unique(out)
  
  #--When sets overlap and the same box is found in each set aggregate
  #(this is a short term solution but results in inflated number of bboxes)
  out<-aggregate(number_bboxes~label+XMin+YMin+XMax+YMax+scores+label.y, data=out, FUN=sum)
  
  return(out)
}