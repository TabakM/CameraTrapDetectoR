# CameraTrapDetectoR: Detect, classify, and count animals in camera trap images

## Step 1: Install Microsoft Visual C++ and update R, if applicable
Note: Microsoft Visual C++ step may no longer be necessary, <b>and it is only necessary on Windows Computers</b>. If you are willing to risk it, try skipping this step and reporting to us if you get unexpected errors when running `deploy_model` in step 4. \
\
You can [install Microsoft Visual C++ from here](https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#visual-studio-2015-2017-2019-and-2022). It is free and allows the deep learning packages to work on Windows computers. It is installed like normal software, just follow the guidance in the prompts. \
\
You need to be running R version 4.1 for this package to work. If you are unsure of your R version, type `R.Version()` into the console. Update if necessary

## Step 2: Install CameraTrapDetectoR
```
# install devtools if you don't have it
if (!require('devtools')) install.packages('devtools')

# install CameraTrapDetectoR
devtools::install_github("https://github.com/TabakM/CameraTrapDetectoR.git")
```
Agree to update all necessary packages. 
If running the above command yields an error that looks like `Error: Failed to install 'CameraTrapDetectoR' from GitHub:
  System command 'Rcmd.exe' failed, exit status: 1, stdout + stderr:`, there is a permissions issue on your machine that prevents installation directly from github. [See the instructions below for installing from source](#install-from-source).

## Step 3: Load this library
```
library(CameraTrapDetectoR)
library(torchvisionlib)
```

If you are on a slow internet connection, you will need to modify your options. This is because we will be downloading the weights and architecture of the neural network. By default, R will timeout downloads at 60 seconds. Running this line will increase the timeout. Units are seconds. Feel free to use a larger number than 200 if you are on a very slow connection. 
```
options(timeout=200)
```

## Step 4: Deploy the model (if you want to use the Shiny App, skip to Alternative Step 4)
Deploy the model from the console with `deploy_model`
```
# specify the path to your images
data_dir = "C:/Users/..." # if you don't know how to specify paths, use the shiny app below. 
# deploy the model and store the output dataframe as predictions
predictions <- deploy_model(data_dir,
                            make_plots=TRUE, # this will plot the image and predicted bounding boxes
                            sample50 = TRUE) # this will cause the model to only work on 50 random images in your dataset. To do the whole dataset, set this to FALSE
```
There are many more options for this function. Type `?deploy_model` for details. 

## Alternative Step 4: Deploy using the Shiny App (if desired)
Copy and paste this code to the console.
```
runShiny("deploy")
```
This will launch a Shiny App on your computer. You will need to navigate to your `data_dir`. This is the location where you have camera trap images to be analyzed. All other options in this menu are optional. Hover your mouse over the options for more details, or see the help file in the center of the screen for descriptions of each option.



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
This [link](https://github.com/TabakM/CameraTrapDetectoR/blob/main/CameraTrapDetectoR_0.1.0.zip) holds the latest version of the package. DO NOT unzip this folder. 

## Install dependencies
Copy this code and paste it into your console. It will install all necessary R packages
```
install_dependencies <-function(packages=c('torchvision', 'torch', 'magick', 
                                           'shiny', 'shinyFiles', 'shinyBS', 
                                           'shinyjs', 'rappdirs', 'fs', 'sf', 
					   'operators', 'torchvisionlib')) {
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


## Citation

Tabak, M. A., Falbel, D., Hamzeh, T., Brook, R. K., Goolsby, J. A., Zoromski, L. D., Boughton, R. K., Snow, N. P., VerCauteren, K. C., & Miller, R. S. (2022). CameraTrapDetectoR: Automatically detect, classify, and count animals in camera trap images using artificial intelligence (p. 2022.02.07.479461). bioRxiv. [link to manuscript](https://doi.org/10.1101/2022.02.07.479461)

Or\
@article {Tabak2022.02.07.479461,
	author = {Tabak, Michael A and Falbel, Daniel and Hamzeh, Tess and Brook, Ryan K and Goolsby, John A and Zoromski, Lisa D and Boughton, Raoul K and Snow, Nathan P and VerCauteren, Kurt C and Miller, Ryan S},
	title = {CameraTrapDetectoR: Automatically detect, classify, and count animals in camera trap images using artificial intelligence},
	elocation-id = {2022.02.07.479461},
	year = {2022},
	doi = {10.1101/2022.02.07.479461},
	publisher = {Cold Spring Harbor Laboratory},,
	URL = {https://www.biorxiv.org/content/early/2022/02/09/2022.02.07.479461},
	eprint = {https://www.biorxiv.org/content/early/2022/02/09/2022.02.07.479461.full.pdf},
	journal = {bioRxiv}
}


