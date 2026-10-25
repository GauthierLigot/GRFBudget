library(shiny)

allocation_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    h3("Allocation management"),
    
    p("Allocation of employees to projects.")
    
  )
}

allocation_server <- function(id, app_data){
  
  moduleServer(id, function(input, output, session){
    
  })
  
}