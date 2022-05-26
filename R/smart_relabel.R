#' Relables predictions using location of photo
#' 
#' This function compares the labels provided by the model with a list of possible
#' species based on species ranges.  In some cases it relabels mis-classifications
#' resulting from assumption that all species could be present in photo.  
#' 
#' @param pred_df dataframe containing predictions for image
#' @param possible.labels dataframe containing possible labels based on species occurrence
#' @return
#' 
#' @export


smart.relabel <- function(pred_df, possible.labels){
  
  #----Wild_Pig
  
  #--Assign Collared_Peccary to Wild_Pig
  if(all(possible.labels$label %in% "Collared_Peccary")==FALSE){
    pred_df[pred_df$label.y=="Collared_Peccary","label.y"] <- "Wild_Pig"
    pred_df[pred_df$label.y=="Wild_Pig","label"] <- label_encoder[label_encoder$label=="Wild_Pig","encoder"]
  }
  
  if(all(possible.labels$label %in% "Tayassuidae")==FALSE){
    pred_df[pred_df$label.y=="Tayassuidae","label.y"] <- "Suidae"
    pred_df[pred_df$label.y=="Suidae","label"] <- label_encoder[label_encoder$label=="Suidae","encoder"]
  }
  
  
  #--Other 
  potential.conflicts <- c("Moose","American_Black_Bear","Grizzly_Bear")
  
  for(j in 1:length(potential.conflicts)){
    if(nrow(possible.labels[possible.labels$label %in% potential.conflicts[j],])==0){
      pred_df[pred_df$label.y %in% potential.conflicts[j],"label.y"] <- "Wild_Pig"
      pred_df[pred_df$label.y=="Wild_Pig","label"] <- label_encoder[label_encoder$label=="Wild_Pig","encoder"]
    }#END Logical
  }#END Loop
  
  
  #----White-Tailed_Deer
  potential.conflicts <- c("Caribou","Mule_Deer","Pronghorn","White-Tailed_Deer","Bighorn_Sheep","Nilgai")
  
  if(length(possible.labels[possible.labels$label %in% potential.conflicts,"label"])==1){
    if(possible.labels[possible.labels$label %in% potential.conflicts,"label"]=="White-Tailed_Deer"){
      pred_df[pred_df$label.y %in% potential.conflicts,"label.y"] <- "White-Tailed_Deer"
    }
  }
  
  
  #----Bobcat
  potential.conflicts <- c("Bobcat","Canada_Lynx","Jaguarundi","Margay","Ocelot")
  
  if(length(possible.labels[possible.labels$label %in% potential.conflicts,"label"])==1){
    if(possible.labels[possible.labels$label %in% potential.conflicts,"label"]=="Bobcat"){
      pred_df[pred_df$label.y %in% potential.conflicts,"label.y"] <- "Bobcat"
    }
  }
  
  
  #----Ocelot
  potential.conflicts <- c("Bobcat","Jaguarundi","Margay","Ocelot")
  
  if(length(possible.labels[possible.labels$label %in% potential.conflicts,"label"])==1){
    if(possible.labels[possible.labels$label %in% potential.conflicts,"label"]=="Ocelot"){
      pred_df[pred_df$label.y %in% potential.conflicts,"label.y"] <- "Ocelot"
    }
  }
  
  if(nrow(pred_df[pred_df$label.y %in% possible.labels$label,])==0){
    pred_df[(pred_df$label.y %in% possible.labels$label)==FALSE,"label.y"] <- "Animal"
    pred_df[pred_df$label.y %in% "Animal","label"] <- max(label_encoder$encoder)+1
  }

  return(pred_df)
}#END Function
  
  
