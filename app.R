library(shiny)
library(bslib)
library(ggplot2)
library(openxlsx2)
library(dplyr)
library(lubridate)

source("R/app_data.R")
source("R/mod_salary.R")
source("R/mod_project.R")
source("R/mod_allocation.R")
source("R/mod_results.R")
source("R/mod_file.R")
source("R/validation_warnings.R")
source("R/compute.R")

#TODO 
# simplify code description (otp, code, name) - no need for that much identifier
# add dropdown menus : https://stackoverflow.com/questions/60828661/how-to-create-a-dropdown-list-in-a-shiny-table-using-datatable-when-editing-the/60845695#60845695

ui <- page_navbar(
  title = "GRF Budget",
  nav_panel("File", file_ui("file")),
  nav_panel("Salary",salary_ui("salary")),
  nav_panel("Project",project_ui("project")),
  nav_panel("Allocation",allocation_ui("allocation")),
  nav_panel("Results",results_ui("results")),
  fillable = FALSE,
  theme = bs_theme(version = 5,bootswatch = "flatly")
)

server <- function(input, output, session){
  
  app_data <- create_app_data()
  output_data <- create_output_data()
  
  DEFAULT_CURRENT_DATA = "data/current_data.xlsx"
  
  load_input(app_data,DEFAULT_CURRENT_DATA)
  
  file_server("file",app_data,output_data)
  salary_server("salary",app_data)
  project_server("project",app_data)
  allocation_server("allocation",app_data)
  results_server("results",app_data,output_data)
  
}

shinyApp(ui, server)