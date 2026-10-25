file_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    h3("Workbook"),
    fileInput(ns("open_file"),"Load workbook",accept = ".xlsx"),
    actionButton(ns("save_file"), "Save current workbook"),
    downloadButton(ns("export_file"),"Export workbook")    
  )
}

file_server <- function(id, app_data){
  
  moduleServer(id, function(input, output, session){
    
    observeEvent(input$open_file, {
      load_workbook(app_data,input$open_file$datapath)
    })
    
    observeEvent(input$save_file, {
      save_workbook(app_data,app_data$current_file)
    })
    
    output$export_file <- downloadHandler(
      
      filename = function() {"financial_data.xlsx"},
      content = function(file) {
        save_workbook(app_data, file)
      }
    )
  })
}