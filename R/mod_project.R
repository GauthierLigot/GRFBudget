library(shiny)

project_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    h3("Project management"),
    
    p("This tab will manage projects.")
    
  )
}

project_server <- function(id,app_data){
  
  moduleServer(id, function(input, output, session){
    
  })
  
}