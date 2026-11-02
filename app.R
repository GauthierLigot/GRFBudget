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
# debugger (possibly because of column with date format or erroneously deleted code???)
# define the table in the output data (particularly sum_project)
# it stops before launching the compute function, likely because tables are empty
# the compute functions returns nothing and update output data. check that it is the right way
# work on date format in the table

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