library(shiny)
library(bslib)
library(ggplot2)
library(openxlsx2)
library(dplyr)

source("R/app_data.R")
source("R/mod_salary.R")
source("R/mod_project.R")
source("R/mod_allocation.R")
source("R/mod_validation.R")
source("R/mod_results.R")
source("R/mod_file.R")


ui <- page_navbar(
  title = "Financial Tracking",
  nav_panel("File", file_ui("file")),
  nav_panel("Salary",salary_ui("salary")),
  nav_panel("Project",projects_ui("project")),
  nav_panel("Allocation",allocation_ui("allocation")),
  nav_panel("Validation",validation_ui("validation")),
  nav_panel("Results",results_ui("results")),
  fillable = FALSE,
  theme = bs_theme(version = 5,bootswatch = "flatly")
)

server <- function(input, output, session){
  
  app_data <- create_app_data()
  DEFAULT_CURRENT_DATA = "data/current_data.xlsx"
  
  load_workbook(app_data,DEFAULT_CURRENT_DATA)
  
  file_server("file",app_data)
  salary_server("salary",app_data)
  projects_server("project",app_data)
  allocation_server("allocation",app_data)
  validation_server("validation",app_data)
  results_server("results",app_data)
  
}

shinyApp(ui, server)