library(shiny)
library(bslib)
library(ggplot2)

source("R/app_data.R")
source("R/mod_salary.R")
source("R/mod_projects.R")
source("R/mod_allocation.R")
source("R/mod_validation.R")
source("R/mod_results.R")

ui <- page_navbar(
  title = "Financial Tracking",
  
  nav_panel("Salary",salary_ui("salary")),
  nav_panel("Projects",projects_ui("projects")),
  nav_panel("Allocation",allocation_ui("allocation")),
  nav_panel("Validation",validation_ui("validation")),
  nav_panel("Results",results_ui("results")),
  fillable = FALSE,
  theme = bs_theme(version = 5,bootswatch = "flatly")
)

server <- function(input, output, session){
  
  app_data <- create_app_data()
  salary_server("salary",app_data)
  projects_server("projects",app_data)
  allocation_server("allocation",app_data)
  validation_server("validation",app_data)
  results_server("results",app_data)
  
}

shinyApp(ui, server)