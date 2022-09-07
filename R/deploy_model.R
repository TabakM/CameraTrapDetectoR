#' Deploy model on camera trap images
#' 
#' @description This function deploys a model trained to identify and count the objects
#' in camera trap images. 
#' 
#' @details 
#' This function deploys a model to detect and classify objects in camera 
#'  trap images. The function will find all files matching the `file_extension`s 
#'  specified within the `data_dir` specified and deploy the `model_type` on these
#'  images. If you specify \code{recusive=TRUE}, the function will find relevant image
#'  files within all subdirectories of your `data_dir`. `deploy_model` returns a
#'  dataframe of predicted number of individuals within each category in each
#'  image. This dataframe is also written as a csv file within your `output_dir`.
#'  If you specify \code{make_plots=TRUE}, the function will plot predicted bounding
#'  boxes for each image in your `output_dir`. If you are working with many images, 
#'  you may wish to specify \code{sample50=TRUE} the first time you use this function,
#'  which will only deploy the model on 50 of your images. There are three options for
#'  \code{model_type}: 'general' recognizes mammals, birds, humans, and vehicles. 
#'  'species' recognizes 77 species. 'family' recognizes 33 families. If you want
#'  to see all of the information for each bounding box (including coordinates, 
#'  labels, and confidence), specify \code{write_bbox_csv=TRUE} and it will be
#'  produced in your `output_dir`. Additionally,
#'  A file called "arguments" will be produced in your `output_dir` this is a list
#'  of all of the arguments you passed to this function for reference. 
#'  
#' 
#' @param data_dir Absolute path to the folder containing your images
#' @param recursive boolean. Do you have images in subfolders within your
#'  data_dir that you want to analyze, if so, set to TRUE. If you only want to 
#'  analyze images within your data_dir and not within sub-folders, set to FALSE.
#' @param model_type Options are c('general', 'species', 'family', 'pig_only'). 
#'  The `general` model predicts to the level of mammal, bird, humans, vehicles. 
#'  The `species` model recognizes 77 species. The `family` model recognizes 33 families.
#'  The `pig_only` model recognizes only pigs.
#' @param file_extensions The types of extensions on your image files. Default 
#'  is c(".jpg", ".JPG")
#' @param make_plots boolean. Do you want to make plots of the images with
#'  their predicted bounding boxes?
#' @param plot_label boolean. Do you want the plots to contain the predicted
#'  class of object
#' @param output_dir You can specify absolute path to output. Default is `NULL`,
#'  and creates a folder within your data_dir. Only specify a path if you want the
#'  results stored somewhere else on your computer. 
#' @param sample50 boolean. Do you want to run the model only on a subset of 
#'  50 images from your dataset? This is a good idea if you are experimenting 
#'  with settings. 
#' @param write_bbox_csv boolean. Do you want to create a csv with all of the 
#'  information on predicted bounding boxes? This csv will include all bounding boxes,
#'  even those with low probability. 
#' @param score_threshold Confidence threshold for using a bounding box, accepts 
#'  values from 0-1. A lower number will produce more bboxes (it will be less
#'  stringent in deciding to make a bbox). A higher number will produce fewer
#'  bboxes (it will be more stringent).
#' @param overlap_correction boolean. Should overlapping detections be
#' evaluated for overlap and highest confidence detection be returned
#' @param overlap_threshold Overlap threshold used when determining if bounding box
#' detections are to be considered a single detection. Accepts values from 0-1
#' representing the proportion of bounding box overlap.
#' @param prediction_format The format to be used for the prediction file.  Accepts
#' values of 'wide' or 'long'.
#' @param location the location of the photos provided as longitude, latitude
#' @param h The image height (in pixels) for the annotated plot. Only used if
#'  \code{make_plots=TRUE}. 
#' @param w The image width (in pixels) for the annotated plot.
#' @param lty line type for bbox plot. See \code{?plot} for details
#' @param lwd line width for bbox plot. See \code{?plot} for details
#' @param col line color for bbox plot. See \code{?plot} for details
#' @param labeled This is not functional
#' @param return_data_frame boolean. Do you want a dataframe returned
#' @return Returns a dataframe of predictions for each file. The rows in this 
#'  dataframe are the file names in your `data_dir`; the columns are the categories
#'  in the model. If any of your images were not loaded properly, there will be a 
#'  column in the dataframe called `image_error`. Images with a 1 in this column 
#'  had issues and the model was not deployed on them. 
#'  
#' @import torch
#' @import torchvision
#' @import magick
#' 
#' @export
deploy_model <- function(
    data_dir = NULL,
    model_type = 'general',
    recursive = TRUE,
    file_extensions = c(".jpg", ".JPG"),
    make_plots = TRUE,
    plot_label = TRUE,
    output_dir = NULL,
    sample50 = FALSE, 
    write_bbox_csv = FALSE, 
    overlap_correction = TRUE,
    overlap_threshold = 0.9,
    score_threshold = 0.6,
    return_data_frame = TRUE,
    prediction_format = "wide",
    h=307,
    w=408,
    lty=1,
    lwd=2, 
    col='red',
    labeled = FALSE
){
  
  #-- Load operators
  load_operators()
  
  #-- Check arguments provided 
  
  # check model_type
  models_available <- c('general', 'species', 'family', 'mammalBirdVehicle', 'pig_only')
  if(!model_type %in% models_available) {
    stop(paste0("model_type must be one of the available options: ",
                list(models_available)))
  }
  
  # check ext types
  acceptable_exts <- c(".jpg", ".png", ".tif", ".pdf",
                       ".JPG", ".PNG", ".TIF", ".PDF")
  extension_test <- file_extensions %in% acceptable_exts
  if(!all(extension_test)){
    stop(paste0(c("One or more of the `file_extensions` specified is not an accepted format. Please choose one of the accepted formats: \n",
                  acceptable_exts), collapse = " "))
  }
  
  # test overlap_threshold
  if (overlap_threshold < 0 | overlap_threshold > 1){
    stop("overlap_threshold must be between 0 and 1")
  }
  
  # test score_threshold
  if (score_threshold < 0 | score_threshold > 1){
    stop("score_threshold must be between 0 and 1")
  }
  
  # check prediction_format
  formats <- c('wide', 'long')
  if(!prediction_format %in% formats) {
    stop(paste0("prediction_format must be one of the available options: ",
                list(formats)))
  }
  
  # test lty 
  lty_options <- 1:6
  if(!lty %in% lty_options){
    stop("invalid lty option selected. Please select an integer from 1-6")
  }
  
  # test color
  tryCatch({grDevices::col2rgb(col)}, error=function(e) {
    print('col value entered is not a valid value')})
  
  # test lwd
  if (lwd <= 0){
    stop("lwd value must be greater than 0")
  }
  
  
  #-- Load model
  
  # load encoder. build these dataframes in the script to avoid attaching tables
  if(model_type == "mammalBirdVehicle"){
    #label_encoder = utils::read.csv("./label_encoders/mammalBirdVehicle.csv")
    label_encoder = data.frame('label' = c('background', 'mammal', 'bird', 'vehicle'),
                               'encoder' = 0:3)
  }
  if(model_type == "pig_only"){
    label_encoder = data.frame('label' = c('empty', 'pig'),
                               'encoder' = 0:1)
  }
  if(model_type == "general"){
    categories <- c('empty', 'mammal', 'bird', 'human', 'vehicle')
    label_encoder = data.frame('label' = categories,
                               'encoder' = 0:(length(categories)-1))
  }
  if(model_type == "species"){
    # run target2label.values() in python to get this list, but empty will be at the end
    categories <- c('empty','American_Badger', 'American_Black_Bear', 'American_Crow', 'American_Marten', 'American_Mink', 'squirrel_spp', 'American_Robin', 'Arctic_Fox', 'Wolf', 'Owl', 'Bighorn_Sheep', 'Jackrabbit', 'Prairie_Dog', 'Vulture', 'Grackle', 'Bobcat', 'Quail', 'Canada_Lynx', 'Caribou', 'Red_Fox', 'Egret', 'Chipmunk', "Clark's_Nutcracker", 'Collared_Peccary', 'Common_Raccoon', 'Common_Raven', 'Cottontail_Rabbit', 'Coyote', 'Domestic_Cat', 'Domestic_Chicken', 'Domestic_Cow', 'Domestic_Dog', 'Domestic_Donkey', 'Domestic_Goat', 'Domestic_Sheep', 'Dove', 'Dusky_Grouse', 'Spotted_Skunk', 'Golden_Eagle', 'Gray_Fox', 'Gray_Jay', 'Heron', 'Grizzly_Bear', 'Horse', 'Human', 'Iguana', 'Jaguar', 'Jaguarundi', 'Margay', 'Moose', 'Mountain_Lion', 'Mouse_Rat', 'Mule_Deer', 'Nilgai', 'Nine-Banded_Armadillo', 'North American Beaver', 'North_American_Porcupine', 'Ocelot', 'Polar_Bear', 'Prairie_Chicken', 'Pronghorn', 'River_Otter', 'Rocky_Mountain_Elk', 'Ruffed_Grouse', 'Snowshoe_Hare', "Steller's_Jay", 'Striped_Skunk', 'Vehicle', 'Virginia_Opossum', 'White-nosed_Coati', 'White-Tailed_Deer', 'Wild_Pig', 'Wild_Turkey', 'Wolverine', 'Woodchuck', 'Yellow-Bellied_Marmot')
    # remove special characters
    categories <- gsub("'", "", categories)
    categories <- gsub(" ", "_", categories)
    categories <- gsub("-", "_", categories)
    label_encoder = data.frame('label' = categories,
                               'encoder' = 0:(length(categories)-1))
  }
  if(model_type == "family"){
    categories <- c('empty','Sciuridae', 'Mustelidae', 'Ursidae', 'Corvidae', 'Turdidae', 'Canidae', 'Columbidae', 'Strigidae', 'Bovidae', 'Ardeidae', 'Leporidae', 'Cathartidae', 'Icteridae', 'Felidae', 'Odontophoridae', 'Cervidae', 'Tayassuidae', 'Procyonidae', 'Phasianidae', 'Equidae', 'Accipitridae', 'Hominidae', 'Iguanidae', 'Aramidae', 'Dasypodidae', 'Castoridae', 'Erethizontidae', 'Antilocapridae', 'Mephitidae', 'vehicle', 'Didelphidae', 'Suidae')
    label_encoder = data.frame('label' = categories,
                               'encoder' = 0:(length(categories)-1))
  }
  
  
  # install dependencies
  #package_vector <- c('torchvision', 'torch', 'magick', 'shiny', 'shinyFiles', 'shinyBS', 'shinyjs')
  #install_dependencies(package_vector)
  #utils::install.packages(c("shiny", "shinyjs"))
  
  # load model 
  cat("\nLoading model architecture and weights. If this is your first time deploying a model on this computer, this step can take a few minutes. \n")
  model <- weightLoader(model_type, num_classes = nrow(label_encoder))
  model$eval()
  
  # load data
  file_list <- dataset(data_dir, recursive,
                       file_extensions,
                       labeled)
  
  # subset data, if we want to
  if(sample50 & length(file_list) >50){
    file_list <- sample(file_list, 50)
  }
  
  # make output directory
  if(is.null(output_dir)){
    datenow <- format(Sys.Date(), "%Y%m%d")
    now <- unclass(as.POSIXlt(Sys.time()))
    current_time <- paste0("_", datenow, "_", sprintf("%02d", now$hour), 
                           sprintf("%02d", now$min), 
                           sprintf("%02d", round(now$sec)))
    output_dir <- file.path(data_dir, paste0("predictions_", model_type, current_time))
  } 
  if (!dir.exists(output_dir)){
    dir.create(output_dir)
  }
  
  
  #-- Make dataframe of possible labels using species range data
  #if(is.null(location)==FALSE){
  
  #  cat(paste0("\nDetermining possible taxa based on location using longitude ",location[1]," latitude ",location[2]))
  
  #Load species extent data
  #  extent.data <- species_extent_loader()
  
  #Get possible species
  #  location <- data.frame(longitude=location[1], latitude=location[2])
  #  possible.labels <- get_possible_species(location)
  #  possible.labels <- possible.labels[possible.labels$model_type == model_type,]
  
  #  cat(paste0("\nIdentified ", nrow(possible.labels), " taxa out of ", nrow(label_encoder), " possible taxa."))
}#END



# #-- Make predictions for each image
# 
# # empty list to hold predictions from loop
# predictions_list <- list()
# 
# # add progress bar
# cat(paste0("\nDeploying model on ", length(file_list), " images. Two warnings will appear; ignore these. \n"))
# if(make_plots){
#   cat(paste0("During deployment, you can optionally view predicted bounding boxes as they are produced in: ",
#              normalizePath(output_dir), "\n"))
# }
# pb = utils::txtProgressBar(min = 0, max = length(file_list), initial = 0,
#                            style=3, char="*")  
# 
# # loop over each image
# toc <- Sys.time()
# torch::with_no_grad({
#   for(i in 1:length(file_list)){
#     #input <- dataLoader(file_list, index = i, w=408, h=307)
#     # if any problems loading the file, catch these errors
#     input <- tryCatch(dataLoader(file_list, index = i, w=408, h=307),
#                       error = function(e) 'error')
#     if("error" %in% input){
#       # set up output so that I can put into the data frame
#       # get file name
#       filename <- file_list[i]
#       pred_df <- data.frame(label = 'image_error', XMin = NA, YMin = NA, XMax=NA, YMax=NA,
#                             scores = 1.0, label.y = 'image_error', number_bboxes = 0,
#                             'filename' = normalizePath(filename))
#       predictions_list[[i]] <- pred_df
#     } else {
#       # deploy the model. suppressing warnings here, because it is not important
#       defaultW <- getOption("warn")
#       output <- suppressMessages({model(input)})
#       options(warn = defaultW)
#       
#       pred_df <- decode_output(output, label_encoder, 307, score_threshold)
#       
#       # evaluate predictions using possible species
#       #if(is.null(location)==FALSE){
#       #  pred_df<-smart_relabel(pred_df, possible.labels)
#       #  pred_df<-pred_df[pred_df$label.y %in% possible.labels$label,]
#       #}
#       
#       if(nrow(pred_df)==1){
#         pred_df$number_bboxes<-1
#       }
#       
#       if(nrow(pred_df) > 1) {
#         pred_df$number_bboxes<-0
#         
#         # address overlapping bboxes
#         if(overlap_correction){
#           pred_df <- reduce_overlapping_bboxes(pred_df, overlap_threshold)
#         }
#       }
#       # subset by score threshold for plotting
#       pred_df_plot <- pred_df[pred_df$scores >= score_threshold, ]
#       # make plots
#       filename <- file_list[i]
#       if(make_plots){
#         plot_img_bbox(filename, pred_df_plot, output_dir, data_dir, plot_label, col,
#                       lty, lwd, FALSE, w, h)
#       }
#       
#       # when there is no predicted bounding box, create a relevant pred_df
#       # first get the encoder value for the background class. This should always be zero
#       if(nrow(pred_df) < 1) {
#         background_encoder <- label_encoder[which("empty"%in%label_encoder$label),]$encoder
#         pred_df[1,] <- c(0, # using 0 instead of background_encoder, because empty will always be 0
#                          rep(NA, (ncol(pred_df)-2)),
#                          "empty")
#         
#         # add column for number of bboxes
#         pred_df$number_bboxes<-0
#         
#         # add value for scores to address NA logical issues later
#         pred_df$scores<-1.0
#         
#       }
#       
#       # add prediction df to list
#       pred_df$filename <- rep(normalizePath(filename), nrow(pred_df))
#       predictions_list[[i]] <- pred_df
#     }
#     
#     # update progress bar
#     utils::setTxtProgressBar(pb,i) 
#   }# end for loop
#   
# })
# tic <- Sys.time()
# runtime <- difftime(tic, toc, units="secs")
# timeper <- runtime/length(file_list)
# cat(paste0("\nInference time of: ", round(timeper, 3), " seconds per image."))
# 
# 
# #-- Make Output Files
# 
# # convert list into dataframe
# predictions_df <- do.call(rbind, predictions_list)
# 
# # output dataframe with all predictions for each file
# full_df <- data.frame("filename" = predictions_df$filename
#                       , "prediction" = predictions_df$label.y
#                       , "confidence_in_pred" = predictions_df$scores
#                       , "number_predictions" = predictions_df$number_bboxes)
# 
# # subset by confidence score threshold
# full_df <- apply_score_threshold(full_df, file_list, score_threshold)
# 
# 
# #-- Make Predictions Dataframe
# 
# # make wide format prediction file
# if(prediction_format=="wide"){
#   
#   # get just the cross table
#   tbl1 <- as.data.frame.matrix(table(full_df[,c("filename", "prediction")]))
#   df_out <- data.frame('filename' = rownames((tbl1)),
#                        tbl1)
#   
#   # rownames are filenames; replace with numbers (only if there are actually some images)
#   if(nrow(df_out) > 0){
#     rownames(df_out) <- 1:nrow(df_out)
#   }
#   
#   # add column names for species not found in any images in the dataset
#   cols_df <- colnames(df_out)
#   all_categories <- c(label_encoder$label, 'image_error')
#   not_pred_in_any <- setdiff(all_categories, cols_df) # categories not predicted to be in any image
#   # remove background, I don't need a column for this because I have "empty"
#   not_pred_in_any <- not_pred_in_any[!(not_pred_in_any %in% "background")]
#   # make these into a dataframe that I can add to df_out
#   not_pred_df <- data.frame(matrix(0, ncol=length(not_pred_in_any), nrow=nrow(df_out)))
#   colnames(not_pred_df) <- not_pred_in_any
#   # add these columns to df_out
#   df_out <- data.frame(df_out, not_pred_df)
#   
#   # re-arrange columns of df_out
#   cols_wanted0 <- label_encoder$label[!(label_encoder$label %in% "background")]
#   # if there are images with errors, include a column for this
#   if("image_error" %in% colnames(tbl1)){
#     cols_wanted <- c("filename", cols_wanted0, 'image_error')
#   }else{
#     cols_wanted <- c("filename", cols_wanted0)
#   }
#   
#   df_out <- df_out[cols_wanted]
#   
#   # find values of file_list that are not in df_out. These are empty files, add them to df_out
#   file_names_to_add <- setdiff(normalizePath(file_list), df_out$filename)
#   if(length(file_names_to_add) > 0){
#     df_add <- data.frame('filename' = file_names_to_add, 
#                          # matrrix of 0s to match df_out
#                          matrix(0, length(file_names_to_add), (ncol(df_out) -1))
#     )
#     colnames(df_add) <- colnames(df_out)
#     # assign these rows as empty
#     df_add$empty <- rep(1, length(file_names_to_add))
#     # add this df to df_out
#     df_out <- rbind(df_out, df_add)
#     
#     # sort the dataframe, so that it matches the order of images (and of plots made by this package)
#     df_out <- df_out[order(df_out$filename), ]
#   }
# }
# 
# # make long format prediction file
# if(prediction_format=="long"){
#   
#   # add certainty measures
#   full_df$certainty <- "single_prediction"
#   
#   # if number of predictions is > 1 indicate that there are multiple predictions
#   full_df[full_df$number_predictions>1,"certainty"] <-"multiple_predictions"
#   
#   # if model did not detect object
#   full_df[full_df$prediction=="empty","certainty"] <-"no_detection"
#   
#   full_df[full_df$prediction=="empty" & full_df$confidence_in_pred<1,"certainty"] <-"detections_below_score_threshold"
#   
#   min.vals<-aggregate(confidence_in_pred~filename+prediction+certainty,
#                       data=full_df[full_df$certainty!="detections_below_score_threshold",],
#                       FUN=min)
#   
#   cnt.val<-aggregate(number_predictions~filename+prediction+certainty,
#                      data=full_df[full_df$certainty!="detections_below_score_threshold",],
#                      FUN=length)  
#   
#   det_df<-cbind.data.frame(min.vals,number_predictions=cnt.val[,"number_predictions"])
#   det_df<-det_df[,colnames(full_df)]
#   
#   full_df_cnt<-rbind.data.frame(det_df, full_df[full_df$certainty=="detections_below_score_threshold",])
#   colnames(full_df_cnt) <- c("filename","prediction","confidence_in_pred","count","certainty")
#   
#   # assign zero to counts if empty
#   full_df_cnt[full_df_cnt$prediction=="empty","count"]<-0
#   
#   full_df_cnt<-full_df_cnt[order(full_df_cnt$filename,full_df_cnt$prediction),]
# }
# 
# 
# #---- Write Files ----
# 
# # Write Model Predictions
# if(prediction_format=="wide"){
#   utils::write.csv(df_out, file.path(output_dir, 'model_predictions.csv'), row.names=FALSE)
# }
# if(prediction_format=="long"){
#   utils::write.csv(full_df_cnt, file.path(output_dir, 'model_predictions.csv'), row.names=FALSE)
# }
# 
# cat(paste0("\nOutput can be found at: \n", normalizePath(output_dir), "\n",
#            "The number of animals predicted in each category in each image is in the file model_predictions.csv\n"))
# 
# # Write Bounding Box File
# if(write_bbox_csv){
#   # rearrange predictions_df, convert coordinates to 0-1 scale
#   bbox_df <- data.frame("filename" = predictions_df$filename,
#                         "prediction" = predictions_df$label.y,
#                         "confidence" = predictions_df$scores,
#                         "number_predictions" = predictions_df$number_bboxes,
#                         "XMin" = as.numeric(predictions_df$XMin)/w,
#                         "XMax" = as.numeric(predictions_df$XMax)/w,
#                         "YMin" = as.numeric(predictions_df$YMin)/h,
#                         "YMax" = as.numeric(predictions_df$YMax)/h)
#   utils::write.csv(bbox_df, file.path(output_dir, "predicted_bboxes.csv"), row.names=FALSE)
#   cat(paste0("The coordinates of predicted bounding boxes are in the file predicted_bboxes.csv"))
# }
# 
# # Write Arguments to File
# arguments <- list (
#   data_dir = normalizePath(data_dir),
#   model_type = model_type,
#   recursive = recursive,
#   file_extensions = file_extensions,
#   make_plots = make_plots,
#   plot_label = plot_label,
#   output_dir = normalizePath(output_dir),
#   sample50 = sample50, 
#   write_bbox_csv = write_bbox_csv, 
#   overlap_correction = overlap_correction,
#   overlap_threshold = overlap_threshold,
#   score_threshold = score_threshold,
#   prediction_format = prediction_format,
#   h=h,
#   w=w,
#   lty=lty,
#   lwd=lwd, 
#   col=col
# )
# # write file
# #lapply(arguments, cat, "\n", file=file.path(output_dir, "arguments.txt"), append=TRUE)
# sink(file.path(output_dir, "arguments.txt"))
# print(arguments)
# sink()
# 
# # return data frame
# if(return_data_frame){
#   if(prediction_format=="long"){return(full_df_cnt)}
#   if(prediction_format=="wide"){return(df_out)}
# }
# }
