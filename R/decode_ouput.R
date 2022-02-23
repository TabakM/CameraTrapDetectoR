#' Decode the output from neural network
#' 
#' This function will convert the output from NN into a format that can be used
#' to make plots and provide a csv with information
#' 
#' @param output this is a subset of the list output from the neural net
#' @param score_threshold threshold score for keeping bounding boxes
#' @param label_encoder passed from deploy model function
#' @param h image height after resizing. Recommend not changing this
#' @return
#' 
#' @export
decode_output <- function(
  output, # this is the list output from the neural net
  label_encoder,
  h, 
  score_threshold = 0.7
){
  # subset the output for the part we want
  preds <- output[[2]][[1]]
  boxes <- as.matrix(preds$boxes)
  img_labels <- as.matrix(preds$labels)
  scores <- as.matrix(preds$scores)

  pred_df <- data.frame('boxes' = boxes,
             'scores' = scores,
             'label' = img_labels)
  
  # assign column names
  colnames(pred_df)[1:4] <- c('XMin', 'YMin', 'XMax', 'YMax')
  
  # check to ensure YMax and YMin are returned as expected - if not then reorder columns
  if(all((h-pred_df$YMax - h-pred_df$YMin)<0)){
    # rename switching ymax and ymin
    colnames(pred_df)[1:4] <- c('XMin', 'YMax', 'XMax', 'YMin')
    # reorder columns
    pred_df <- pred_df[,c('XMin', 'YMin', 'XMax', 'YMax', 'scores', 'label')]
  }
  
  # remove boxes below threshold
  #pred_df <- pred_df[pred_df$scores >= score_threshold, ]
  
  # the predicted y coordinates from the model assume that the y axis 
  # starts in the upper left hand corner of the image, but this is not how
  # plots are made in R, so I need to inverse this value
  pred_df$YMin <- h-pred_df$YMin
  pred_df$YMax <- h-pred_df$YMax

  # get name of label
  pred_df <- merge(pred_df, label_encoder, by.x="label", by.y="encoder")
  
  return(pred_df)
}




