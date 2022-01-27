#' Make plots of the image with bounnding box predictions
#' 
#' Plots original image with predicted bounding box and (optionally)
#' the predicted category
#' 
#' @param filename The file containing the image
#' @param pred_df Prediction dataframe that is output from deployment
#' @param output_dir Desired directory to make plots
#' @param data_dir absolute path to images
#' @param plot_label boolean. Do you want the predicted category on the plot?
#' @param prop_bbox boolean. Are the bbox coordinates in proportion instead of 
#'  exact coordinates? Only `TRUE` if you are using a different image size
#' @param h The image height (in pixels) for the annotated plot. Only used if
#'  \code{make_plots=TRUE}. 
#' @param w The image width (in pixels) for the annotated plot.
#' @param col color of the bbox (and label if `plot_label=TRUE`). See `?plot` 
#'  for an explanation of `col`, `lwd`, and `lty`
#' @param lwd line width of bbox
#' @param lty line type of bbox
#' @return
#' 
#' @export
#' 
plot_img_bbox<- function(filename,
                         pred_df,
                         output_dir,
                         data_dir,
                         plot_label=TRUE,
                         col="red",
                         lty=1,
                         lwd=2,
                         prop_bbox = FALSE,
                         w = 408, h=307){
  
  # prop_bbox means that data are from megadetector, not from here, so 
  # things are a little different in the file_list. 
  filename_full <- ifelse(prop_bbox, file.path(data_dir, filename),
                          filename)
  img <- magick::image_read(filename_full)
  img <- magick::image_scale(img, paste0(w, 'x', h, '!'))
  
  
  # save file information
  if(!endsWith(data_dir, "/")){
    # add a slash to the end of data dir, for when I pull it from file name
    data_dir <- paste0(data_dir, "/")
  }
  # I want to replace slashes with _ for those recursive files. This will 
  # keep them all in the same place
  stripped_filename <- tools::file_path_sans_ext(gsub("/", "_", gsub(data_dir, "", filename)))
  output_nm <- file.path(output_dir, paste0(stripped_filename, ".png"))
  
  # when using megadetector output, the coordinates are proportional
  if(prop_bbox){
    pred_df$XMin <- pred_df$XMin*w
    pred_df$XMax <- pred_df$XMax*w
    pred_df$YMin <- (1-pred_df$YMin)*h
    pred_df$YMax <- (1-pred_df$YMax)*h
  } else {
    # rescale the bounding box
    if(w != 408 ){
      w_scale <- w/408
      pred_df$XMin <- pred_df$XMin*w_scale #(w*pred_df$XMin)/408
      pred_df$XMax <- pred_df$XMax*w_scale#(w*pred_df$XMax)/408
    }
    if(h!= 307){
      h_scale <- h/307
      pred_df$YMin <- pred_df$YMin*h_scale #(pred_df$YMin/307)*h -307/h # #(h*pred_df$YMin)/307
      pred_df$YMax <- pred_df$YMax*h_scale# (pred_df$YMax/307)*h - 307/h##(h*pred_df$YMax)/307
    }  
  }
  
  
  
  # make plot
  grDevices::png(output_nm, width=w, height=h)
  plot(img)
  if (nrow(pred_df) > 0){ # Only plot boxes if there are predictions
    for(i in 1:nrow(pred_df)){
      graphics::segments(x0=pred_df$XMin[i], y0=pred_df$YMin[i],
               x1=pred_df$XMin[i], y1=pred_df$YMax[i], 
               col=col, lty=lty, lwd=lwd)
      graphics::segments(x0=pred_df$XMin[i], y0=pred_df$YMin[i],
               x1=pred_df$XMax[i], y1=pred_df$YMin[i], 
               col=col, lty=lty, lwd=lwd)
      graphics::segments(x0=pred_df$XMin[i], y0=pred_df$YMax[i],
               x1=pred_df$XMax[i], y1=pred_df$YMax[i], 
               col=col, lty=lty, lwd=lwd)
      graphics::segments(x0=pred_df$XMax[i], y0=pred_df$YMax[i],
               x1=pred_df$XMax[i], y1=pred_df$YMin[i], 
               col=col, lty=lty, lwd=lwd)
      if(plot_label){
        graphics::text(x= pred_df$XMin[i]+6, y=pred_df$YMin[i]+10, pred_df$label.y[i],
             col=col, adj=0)  
      }
    }
  }

  grDevices::dev.off()
  
}