file_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    card(
      card_header("Input data (salary, project, allocation)"),
        fileInput(ns("open_input_file"),NULL,buttonLabel = "Load", accept = ".xlsx"),
        actionButton(ns("save_input_file"), "Save"),
        downloadButton(ns("export_input_file"),"Save as ...")),
    br(),
    card(card_header("Output data"),
         downloadButton(ns("export_output_file"),"Export as ...") 
         
           )
  )
}

file_server <- function(id, app_data, output_data){
  
  moduleServer(id, function(input, output, session){
    
    observeEvent(input$open_input_file, {
      load_input(app_data,input$open_file$datapath)
    })
    
    observeEvent(input$save_input_file, {
      showModal(
        modalDialog(
          title = "Confirm saving",
          "Are you sure you want to overwrite the existing file? This operation will erase previously saved data. This can take about 15 seconds.",
          footer = tagList(
            modalButton("Cancel"),
            actionButton(session$ns("confirm_save"), "Yes, overwrite", class = "btn-danger")),
          easyClose = FALSE
        )
      )
    })
    
    observeEvent(input$confirm_save, {
      removeModal()
      save_input(app_data, app_data$current_file)
      showNotification("File successfully saved.",type = "message")
      
    })
    
    output$export_input_file <- downloadHandler(
      filename = function() {paste0(format(today(), "%Y%m%d"),
                                    "_GRFbudget_InputData.xlsx")},
      content = function(file) {
        save_input(app_data, file)
      }
    )
    
    output$export_output_file <- downloadHandler(
      filename = function() {paste0(format(today(), "%Y%m%d"),"_GRFbudget_OutputData.xlsx")},
      content = function(file) {
        req(nrow(output_data$allocation_monthly) > 1)
        export_output(app_data, output_data, file)
        showNotification("File successfully saved.",type = "message")
      }
      
    )
  })
}