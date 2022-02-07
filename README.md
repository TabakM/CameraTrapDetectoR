# CameraTrapDetectoR: Detect, classify, and count animals in camera trap images
 Note: This package is currently only available for Windows computers. Support for Mac and Linux will soon be available. 

## Step 1: Install Microsoft Visual C++
Note: this step may no longer be necessary. If you are willing to risk it, try skipping this step and reporting to us if you get unexpected errors when running `deploy_model` in step 4. \
You can install this software from [here](https://aka.ms/vs/16/release/vc_redist.x64.exe). It is free and allows the deep learning packages to work on Windows computers. It is installed like normal software, just follow the guidance in the prompts. 

## Step 2: Install CameraTrapDetectoR
```
# install devtools if you don't have it
if (!require('devtools')) install.packages('devtools')

# install CameraTrapDetectoR
devtools::install_github("https://github.com/TabakM/CameraTrapDetectoR.git")
```
If running the above command yields an error that looks like `Error: Failed to install 'CameraTrapDetectoR' from GitHub:
  System command 'Rcmd.exe' failed, exit status: 1, stdout + stderr:`, there is a permissions issue on your machine that prevents installation directly from github. [See the instructions below for installing from source](#install-from-source).

## Step 3: Load this library
```
library(CameraTrapDetectoR)
```

## Step 4: Run the Shiny App (if desired)
Copy anbd paste this code to the console.
```
runShiny("deploy")
```
This will launch a Shiny App on your computer. You will need to navigate to your `data_dir`. This is the location where you have camera trap images to be analyzed. All other options in this menu are optional. Hover your mouse over the options for more details, or see the help file in the center of the screen for descriptions of each option.

## Alternative Step 4: Deploy in the console (if you don't want to use Shiny)
Deploy the model from the console with `deploy_model`
```
# specify the path to your images
data_dir = "C:/Users/..."
# deploy the model and store the output dataframe as predictions
predictions <- deploy_model(data_dir,
                            make_plots=TRUE, # this will plot the image and predicted bounding boxes
                            sample50 = TRUE) # this will cause the model to only work on 50 random images in your dataset. To do the whole dataset, set this to FALSE
```
There are many more options for this function. Type `?deploy_model` for details. 

\
\
#-------------------------------------------------------------------------------------------------------------------
## Install from source
#### If you could not install package from github, follow these instructions to install from source
There is currently a problem in the Windows version of `install_github` that is creating this error when certain permissions are set on your machine. Hopefully it will be fixed soon. In the mantime, you can install from source by following the instructions below.

## Before attempting to install from source, you may want to try running these to lines to install instead
```
Sys.setenv(R_REMOTES_STANDALONE="true", build=FALSE)
devtools::install_github("https://github.com/mikeyEcology/CameraTrapDetectoR.git", auth_token = "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")
```
If this works, return to [Step 3](#step-3-load-this-library). If it does not, proceed with installation from source. 

## Download CameraTrapDetectoR
This [link](https://github.com/TabakM/CameraTrapDetectoR/raw/main/CameraTrapDetectoR_0.0.3.zip) holds the latest version of the package. DO NOT unzip this folder. 

## Install dependencies
Copy this code and paste it into your console. It will install all necessary R packages
```
install_dependencies <-function(packages=c('torchvision', 'torch', 'magick', 
                                           'shiny', 'shinyFiles', 'shinyBS', 
                                           'shinyjs', 'rappdirs', 'fs')) {
  cat(paste0("checking package installation on this computer"))
  libs<-unlist(list(packages))
  req<-unlist(lapply(libs,require,character.only=TRUE))
  need<-libs[req==FALSE]
  
  if(length(need)>0){ 
    cat(paste0("The packages: ", need, "\n Need to be installed. Installing them now.\n"))
    utils::install.packages(need)
    lapply(need,require,character.only=TRUE)
  } else{
    cat("All necessary packages are installed on this computer. Proceed.\n")
  }
}
install_dependencies()
```

## Install CameraTrapDetectoR from source
- In Rsutdio, Click on `Packages`, then click `Install` (just below and to the left of `Packages`)
- In the install menu, click on the arrow by `Install From`
- Click on `Package Achive File`
- Click `Browse` and navigate to the zip file that you just downloaded. 
- click `install`

## Return to [Step 3](#step-3-load-this-library) above to use the package. 

