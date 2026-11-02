library(shiny)

allocation_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    # h3("Allocation : define who is working on what project and when"),
    DT::DTOutput(ns("allocation_table")),
    br(),
    div(class = "d-flex gap-2",
        actionButton(ns("add_row"),"Add"),
        actionButton(ns("delete_row"),"Delete")),
    br(),
    verbatimTextOutput(ns("validation")),    
    br())
  
}

allocation_server <- function(id, app_data, output_data){
  
  moduleServer(id, function(input, output, session){
    
    observeEvent(input$add_row, {
      
      
      new_row <- data.frame(
        project_code = "",
        employee = "",
        start_date = as.Date(NA),
        end_date = as.Date(NA),
        fte = 0,
        comment = ""
      )
      
      app_data$allocation <- rbind(
        app_data$allocation,
        new_row
      )
      
    })
    observeEvent(input$delete_row, {
      row <- input$allocation_table_rows_selected
      if(length(row) > 0){
        app_data$allocation <- app_data$allocation[-row, ]
      }
    })
    observeEvent(input$allocation_table_cell_edit, {
      
      info <- input$allocation_table_cell_edit
      row <- info$row
      col <- info$col
      value <- info$value
      
      current_col <- app_data$allocation[[col]]
      
      if (is.numeric(current_col)) {
        value <- as.numeric(value)
      }
      
      if (is.integer(current_col)) {
        value <- as.integer(value)
      }
      
      if(inherits(current_col, "Date")){
        value <- as.Date(value)
      }
      app_data$allocation[row, col] <- value
      
    })
    output$validation <- renderText({
      warnings<-paste0(check_salary_allocation_consistency(app_data),
                      check_project_allocation_consistency(app_data))
      warnings
    })
    
    output$allocation_table <- DT::renderDT(DT::datatable(
      app_data$allocation,  editable = list(target = "cell",
                                            date = which(names(app_data$allocation) %in%
                                                c("start_date", "end_date"))),
                                            selection = "multiple"))
    
  })
    
}