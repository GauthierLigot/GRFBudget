library(shiny)

validation_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    h3("Validation"),
    
    p("Data quality checks will appear here.")
    
  )
}

validation_server <- function(id, app_data){
  
  moduleServer(id, function(input, output, session){
    
  })
  
}