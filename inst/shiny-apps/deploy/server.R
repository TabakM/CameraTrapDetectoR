
shinyServer(function(input, output) {
    
    volumes <- shinyFiles::getVolumes()
    
    # data_dir and output_dir setup
    shinyFiles::shinyDirChoose(input, "data_dir", roots = volumes())
    dirname_data_dir <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$data_dir)})
    
    shinyFiles::shinyDirChoose(input, "output_dir", roots = volumes())
    dirname_output_dir <- shiny::reactive({shinyFiles::parseDirPath(volumes, input$output_dir)})
    
    # observe data_dir changes
    shiny::observe({
        
        if(identical(dirname_data_dir(), character(0))){
            textToRender <- "data_dir is the location of your images. Not yet selected"
        } else {
            textToRender <- dirname_data_dir()
        }
        
        output$data_dir_Display <- shiny::renderText(textToRender)
        
    })# end observe
    
    # observe output_dir changes
    shiny::observe({
        if(identical(dirname_output_dir(), character(0))){
            textToRender <- "NULL"
        } else {
            textToRender <- dirname_output_dir()
        }
        
        output$output_dir_Display <- shiny::renderText(textToRender)
        
    })# end observe
    
    # render warnings and disable / enable Run model button
    shiny::observe({
        
        # data_dir warning / disable
        if(identical(dirname_data_dir(), character(0))){
            output$dataDirWarning <- shiny::renderText("You must select a path for data_dir.")
            shinyjs::disable("deploy_modelRun")
        } else {
            output$dataDirWarning <- shiny::renderText("")
        }
        
        # file extension warning / disable
        if(is.null(input$file_extensions)){
            output$fileExtensionWarning <- shiny::renderText("You must select at least one file extension.")
            shinyjs::disable("deploy_modelRun")
        } else {
            output$fileExtensionWarning <- shiny::renderText("")
        }
        
        # only enable run model button if required fields are provided
        if(!identical(dirname_data_dir(), character(0)) && 
           !is.null(input$file_extensions)){
            output$allowedToDeployModel <- shiny::renderText("You have the necessary arguments to run the model.")
            shinyjs::enable("deploy_modelRun")
        } else {
            output$allowedToDeployModel <- shiny::renderText("")
        }
        
    })# end observe
    
    # show code that can be copied for user to run deploy_model themselves
    shiny::observe({
        
        # set data_dir to "NULL" if none selected
        if(identical(dirname_data_dir(), character(0))){
            data_dir <- "NULL"
        } else {
            data_dir <- paste0("'", dirname_data_dir(), "'")
        }
        
        # set output_dir to "NULL if none has been selected
        if(identical(dirname_output_dir(), character(0))){
            output_dir <- "NULL"
        } else {
            output_dir <- paste0("'", dirname_output_dir(), "'")
        }
        
        output$deploy_modelCode <- shiny::renderText({
            paste0("predictions <- deploy_model(", 
                   "data_dir = ", data_dir, ", ",
                   "model_type = '", input$model_type, "', ", 
                   "recursive = ", as.logical(input$recursive), ", ",
                   "file_extensions = c('", paste(input$file_extensions, collapse = "', '"), "'), ",
                   "labeled = ", as.logical(input$labeled), ", ",
                   "make_plots = ", as.logical(input$make_plots), ", ",
                   "plot_label = ", as.logical(input$plot_label), ", ",
                   "output_dir = ", output_dir, ", ",
                   "sample50 = ", as.logical(input$sample50), ", ",
                   "write_bbox_csv = ", as.logical(input$write_bbox_csv), ", ",
                   "score_threshold = ", input$score_threshold, ", ",
                   "overlap_correction = ", input$overlap_correction, ", ",
                   "overlap_threshold = ", input$overlap_threshold, ", ",
                   "return_data_frame = ", input$return_data_frame, ", ",
                   "prediction_format = ", input$prediction_format, ", ",
                   "latitude = ", input$latitude, ", ",
                   "longitude = ", input$longitude, ", ",
                   "h = ", input$h, ", ",
                   "w = ", input$w, ", ",
                   "lty = ", input$lty, ", ",
                   "lwd = ", input$lwd, ", ",
                   "col = '", input$color, "')")
        })
        
    })# end observe
    
    # run model
    shiny::observeEvent(input$deploy_modelRun, { 
        
        # only run model if data_dir has been selected
        if(!identical(dirname_data_dir(), character(0))){
            
            # set output_dir to data_dir if none has been selected
            if(identical(dirname_output_dir(), character(0))){
                output_dir <- NULL
                output_dirText <- paste0("the most recent model_predictions folder in: ", 
                                         dirname_data_dir(), ". When this window closes model deployment is done and you can close the Shiny App window.
                                         
                                         Also, if you want to work with model predictions directly in R. You can find them as the object `predictions`.
                                         Try typing `head(predictions)` in the R console to see this object.")
            } else {
                output_dir <- dirname_output_dir()
                output_dirText <- paste0(": ", dirname_output_dir())
            }
            
            # let user know about predicted bounding boxes during deployment
            if(as.logical(input$make_plots)){
                additionalText <- paste0("During deployment, you can optionally view predicted bounding boxes as they are produced in ", output_dirText)
            } else {
                additionalText <- paste0("")
            }
            
            # show loading modal
            # NOTE: it will only close after the model is finished running
            shiny::showModal(
                shiny::modalDialog(
                    shiny::h4("Running model. This will take a few minutes. If this is your first time using this package or you are using a different model, we must download some files first. You may need to disconnect from VPN to allow these files to download.", align = "center"),
                    
                    # include loading spinner
                    shiny::HTML('<center><img src="spinner.gif"></center>'),
                    
                    shiny::hr(),
                    
                    shiny::h5(additionalText),
                    
                    easyClose = FALSE,
                    footer = NULL
                )
            )
            
            # show cats / warnings normally shown in console in app
            withConsoleRedirect("console", {
                predictions <<- deploy_model(data_dir = dirname_data_dir(), 
                                             model_type = input$model_type, 
                                             recursive = as.logical(input$recursive), 
                                             file_extensions = input$file_extensions, 
                                             labeled = as.logical(input$labeled), 
                                             make_plots = as.logical(input$make_plots), 
                                             plot_label = as.logical(input$plot_label), 
                                             output_dir = output_dir, 
                                             sample50 = as.logical(input$sample50), 
                                             write_bbox_csv = as.logical(input$write_bbox_csv), 
                                             score_threshold = input$score_threshold, 
                                             overlap_correction = as.logical(input$overlap_correction),
                                             overlap_threshold = input$overlap_threshold,
                                             return_data_frame = as.logical(input$return_data_frame),
                                             prediction_format = input$prediction_format,
                                             latitude = input$latitude,
                                             longitude = input$longitude,
                                             h = input$h, 
                                             w = input$w, 
                                             lty = input$lty, 
                                             lwd = input$lwd, 
                                             col = input$color)  
            })
            
            # close the loading modal after model has finished running
            shiny::removeModal()
            
        }# end if
        
    }) # end observeEvent
    
})
