
shinyUI(fluidPage(

    # Application title
    shiny::titlePanel("Deploy Model"),
    
    shinyjs::useShinyjs(),
    
    # Sidebar with a slider input for number of bins
    shiny::sidebarLayout(
        shiny::sidebarPanel(
            
            ## data_dir
            shinyFiles::shinyDirButton("data_dir", "data_dir", 
                                       title="Select the location of photos to be analyzed. Just select the folder where it resides in the top half of the menu and press `Select`"),
            shinyBS::bsTooltip("data_dir", "Location of image files on your computer. If they are in sub-directories within your data_dir, select `recursive=TRUE`", 
                               placement = "top"),
            shiny::verbatimTextOutput("data_dir_Display", placeholder = TRUE),
            
            ## model_type
            shiny::selectInput("model_type", "model_type", 
                        choices = c("general", "species", "family", "pig_only")),
            shinyBS::bsTooltip("model_type", "This defines how you want to ID animals, generally (to class), to species, to family, or to pig_only",
                               placement = "top"),
            
            ## recursive
            shiny::selectInput("recursive", "recursive", 
                        choices = c(TRUE, FALSE)),
            shinyBS::bsTooltip("recursive", "Do you have images in subfolders within data_dir?", 
                               placement = "top"),
            
            ## file_extensions
            shiny::checkboxGroupInput("file_extensions", "file_extensions",  
                                      choices = c(".jpg", ".JPG", ".png", ".PNG", 
                                                  ".tif", ".TIF", ".pdf", ".PDF"), 
                                      selected = c(".jpg", ".JPG"), 
                                      inline = TRUE),
            shinyBS::bsTooltip("file_extensions", "The types of extensions on your image files", 
                               placement = "top"),
            
            ## make_plots
            shiny::selectInput("make_plots", "make_plots", choices = c(TRUE, FALSE)),
            shinyBS::bsTooltip("make_plots", "Do you want to make plots of the images with their predicted bounding boxes?", 
                      placement = "top"),
            
            ## plot_label
            shiny::selectInput("plot_label", "plot_label", choices = c(TRUE, FALSE)),
            shinyBS::bsTooltip("plot_label", "Do you want the plots to contain the predicted class of object?", 
                               placement = "top"),
            
            ## output_dir
            shinyFiles::shinyDirButton("output_dir", "output_dir", 
                                       title="Select the location to output. Just select the folder where it resides in the top half of the menu and press `Select`"),
            shinyBS::bsTooltip("output_dir", "Location for output to be written on your computer. If folder is not selected, then a folder will be created within your data_dir.", 
                               placement = "top"),
            shiny::verbatimTextOutput("output_dir_Display", placeholder = TRUE),
            
            ## sample50
            shiny::selectInput("sample50", "sample50", choices = c(FALSE, TRUE)),
            shinyBS::bsTooltip("sample50", "Do you want to run the model only on a subset of 50 images from your dataset?", 
                               placement = "top"),
            
            ## write_bbox_csv
            shiny::selectInput("write_bbox_csv", "write_bbox_csv", choices = c(TRUE, FALSE)),
            shinyBS::bsTooltip("write_bbox_csv", "Do you want to create a csv with all of the information on predicted bounding boxes?", 
                               placement = "top"),

            ## score_threshold
            shiny::numericInput("score_threshold", "score_threshold", value = 0.6, 
                                min = 0, max = 1, step = 0.01),
            shinyBS::bsTooltip("score_threshold", 
                               "Confidence threshold for using a bounding box. A lower number will produce more bboxes (it will be less stringent in deciding to make a bbox). A higher number will produce fewer bboxes (it will be more stringent).", 
                               placement = "top"),
            
            ## overlap_correction
            shiny::selectInput("overlap_correction", "overlap_correction", choices = c(TRUE, FALSE)),
            shinyBS::bsTooltip("write_bbox_csv", "Do you want overlapping detections to be evaluated and the detection with highest confidence returned?", 
                               placement = "top"),
            
            ## overlap_threshold
            shiny::numericInput("overlap_threshold", "overlap_threshold", value = 0.9, 
                                min = 0, max = 1, step = 0.01),
            shinyBS::bsTooltip("overlap_threshold", 
                               "Proportion of bounding box overlap to determine if detections are to be considered a single detection.",
                               placement = "top"),
            
            ## return_data_frame
            shiny::selectInput("return_data_frame", "return_data_frame", choices = c(FALSE, TRUE)),
            shinyBS::bsTooltip("return_data_frame", "Do you want a dataframe read into R environment with predictions for each file? The rows in this dataframe are the file names in your `data_dir`; the columns are the categories in the model. If any of your images were not loaded properly, there will be a column in the dataframe called `image_error`. Images with a 1 in this column had issues and the model was not deployed on them.",
                               placement = "top"),
            
            ## prediction_format
            shiny::selectInput("prediction_format", "prediction_format", choices = c('wide', 'long')),
            shinyBS::bsTooltip("prediction_format", "What format do you want used for your prediction file?",
                               placement = "top"),
            
            ## h
            shiny::numericInput("h", "h", value = 307),
            shinyBS::bsTooltip("h", "The image height (in pixels) for the annotated plot"),
            
            ## w
            shiny::numericInput("w", "w", value = 408),
            shinyBS::bsTooltip("w", "The image width (in pixels) for the annotated plot"),
            
            ## lty
            shiny::numericInput("lty", "lty", value = 1, step = 1),
            #shiny::selectInput("lty", "lty", choices = 1:6, 
            #                   selected = "solid"),
            shinyBS::bsTooltip("lty", "line type for bbox plot"),
            
            ## lwd
            shiny::numericInput("lwd", "lwd", value = 2, min = 0, step = 0.1),
            shinyBS::bsTooltip("lwd", "line width for bbox plot. NOTE: Values less than 1 or greater than 4 will be difficult to see."),
            
            ## col
            shiny::selectInput("color", "color", 
                               choices = c("white", "grey", "black", "red", "yellow", 
                                           "green", "blue", "orange", "purple"), 
                               selected = "red"),
            shinyBS::bsTooltip("col", "line color for bbox plot", placement = "top"),
            
            ## labeled - commented out due to non-functionality
            # shiny::selectInput("labeled", "labeled", choices = c(FALSE, TRUE)),
            # shinyBS::bsTooltip("labeled", "This is not functional yet", placement = "top"),
            
        ),
        
        # run model button / console output
        shiny::mainPanel(
            
            shiny::h4("Current deploy_model code: (You can copy this and paste it to the console if you prefer)"),
            shiny::fluidRow(column(12, textOutput("deploy_modelCode"))),
            
            shiny::hr(),
            
            shiny::actionButton("deploy_modelRun", "Run model"),
            
            shiny::fluidRow(shiny::column(12, shiny::span(style = "color:green;font-size:125%;", 
                                                          shiny::textOutput("allowedToDeployModel")))),
            shiny::fluidRow(shiny::column(12, shiny::span(style = "color:red;font-size:125%;", 
                                                          shiny::textOutput("dataDirWarning")))),
            shiny::fluidRow(shiny::column(12, shiny::span(style = "color:red;font-size:125%;", 
                                                          shiny::textOutput("fileExtensionWarning")))),
            shiny::fluidRow(shiny::column(12, shiny::span(style = "color:red;font-size:125%;", 
                                                          shiny::textOutput("colorWarning")))),
            
            # console output
            shiny::pre(id = "console"),
            
            # make rd file as image
            shiny::h3("Below are some more details about each of the options on the left:"),
            shiny::img(src = "manual_image.PNG", align="center")
        )
    )
))
