# Create desktop shortcut to run Shiny app without opening R

# -- Install and load shinyShortcut package
# install.packages("shinyShortcut") # should be installed with other package dependencies
library(shinyShortcut)

# -- Set directory to CameraTrapDetectoR package
setwd(find.package("CameraTrapDetectoR"))

# -- Create shortcut
shinyShortcut(shinyDirectory = "shiny-apps/deploy")

# Shortcut is now created. To activate on desktop:
# -- 1. Navigate to the deploy folder, open the file `.shiny_run`
# getwd()
# -- 2. Right click the file `shinyShortcut`, and click "Create Shortcut". 
# -- 3. Drag this new file to desktop and click to open

