library(shiny)

results_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    h3("Results"),
    
    p("Calculation outputs will be displayed here.")
    
  )
}

results_server <- function(id, app_data){
  
  moduleServer(id, function(input, output, session){
    
  })
  
}