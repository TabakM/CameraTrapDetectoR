#' Create the data loader
#' 
#' This function loads a batch of data to be passed to the model
#'
#' @param h image height after resizing. Recommend not changing this
#' @param w image width after resizing. Recommend not changing this
#' @param file_list passed from deploy fuction
#' @param index i value from deploy function
#' @return
#' 
#' @export
dataLoader <- function(file_list,
                       index,
                       w = 408, h=307){

  # load image
  image_path <- file_list[index]
  # get image file and resize
  img <- magick::image_read(image_path)
  
  # resize image
  img <- magick::image_scale(img, paste0(w, 'x', h, '!'))
  # convert image to tensor. Sometimes this throws an error, so I need to catch it
  img_tensor <- torchvision::transform_to_tensor(img)
  # img_tensor <- tryCatch(img_tensor <- torchvision::transform_to_tensor(img),
  #          error = function(e) 'error')
  # create a dummy target, just so we can pass something to the net
  target <- torch::torch_rand(3, h, w)
  
  # create the object that will get passed to network for this index
  nn_input <- list(img_tensor, target)
  
  return(nn_input)
}
