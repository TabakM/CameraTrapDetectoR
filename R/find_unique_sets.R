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

find_unique_sets <- function(df, overlap_threshold=overlap_threshold){
  
  mat<-find_all_combinations(df)
  overlap.val<-vector()  
  
  for(j in 1:nrow(mat)){
    vec<-mat[j,]
    vec<-which(vec==1)
    
    a<-df[vec[1],c("XMin","XMax","YMin","YMax")]
    b<-df[vec[2],c("XMin","XMax","YMin","YMax")]
    
    #--FNC - Determine Overlap
    overlap.val[j] <-determine_overlap(a,b)
  }#END Loop
  
  #--Restrict using overlap_threshold
  mat<-cbind.data.frame(mat,overlap.val)
  
  #--Save columns
  col.vec<-seq(1,ncol(mat)-1,1)
  
  #--Remove overlaps = 0 (no overlap)
  mat<-mat[mat$overlap.val!=0,]
  
  #--Apply overlap threshold
  mat<-mat[mat$overlap.val>=overlap_threshold,]
  
  #--Remove overlap
  mat<-mat[,colnames(mat)!="overlap.val"]
  
  #--Assign values
  for(k in 1:ncol(mat)){
    v<-mat[,k]
    v[v!=0]<-k
    mat[,k]<-v
  }
  
  #-- If length of mat >0
  if(nrow(mat)>0){
    
    #--Remove columns with all zeros
    mat<-mat[, colSums(mat != 0) > 0]
    
    #--Order data
    mat<-mat[do.call(order, c(mat, list(decreasing=TRUE))),]
    
    #--Find Unique Sets
    for(k in 1:ncol(mat)){
      if(k==1){unique.sets<-list()}
      
      tmp <- mat[which(mat[,k]==k),]
      
      vec <- as.vector(as.matrix(tmp))
      unique.sets[[k]] <- unique(vec[vec!=0])
    }
    
    #--Keep unique sets and remove empty
    unique.sets <- unique(unique.sets)
    unique.sets<-unique.sets[lapply(unique.sets, length)>0]
    
    
    #--Add sets of 1
    set.vec<-unique(unlist(unique.sets))
    col.vec<-col.vec[!col.vec %in% set.vec]
    
    if(length(col.vec)>0){
      add.sets<-list()
      for(i in 1:length(col.vec)){
        add.sets[[i]]<-col.vec
      }
      
      #--Merge sets
      unique.sets<-c(unique.sets,add.sets)
      
      #--Keep unique sets and remove empty
      unique.sets <- unique(unique.sets)
      unique.sets<-unique.sets[lapply(unique.sets, length)>0]
    }
  }
  
  #-- If overlap threshold results in no overlapping bboxes
  # then return unique set for each box
  if(nrow(mat)==0){
    unique.sets <- list()
    for(j in 1:ncol(mat)){
      unique.sets[[j]]<-j
    }
  }
  
  return(unique.sets)
}#END Function






