library(shiny)

project_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    # h3("Project management"),
    DT::DTOutput(ns("project_table")),
    br(),
    div(class = "d-flex gap-2",
        actionButton(ns("add_row"),"Add"),
        actionButton(ns("delete_row"),"Delete")),
    br(),
    verbatimTextOutput(ns("validation")))

}

project_server <- function(id,app_data){
  
  moduleServer(id, function(input, output, session){
    
    page_length <- 10
    
    observeEvent(input$add_row, {
      
      new_row <- data.frame(
        otp = "",
        project_code = "",
        project_name = "",
        budget = 0,
        start_date = as.Date(NA),
        end_date = as.Date(NA),
        comment = ""
      )
      
      app_data$project <- rbind(app_data$project,new_row)
      refresh_table()
      # jump to the last page to see the new row
      DT::selectPage(proxy, ceiling(nrow(app_data$project) / page_length))
      
    })
    observeEvent(input$delete_row, {
      row <- input$project_table_rows_selected
      if(length(row) > 0){
        app_data$project <- app_data$project[-row, ,drop=FALSE]
        refresh_table()
      }
    })
    
    observeEvent(input$project_table_cell_edit, {
      
      info <- input$project_table_cell_edit
      row <- info$row
      col <- info$col
      value <- info$value
      
      current_col <- app_data$project[[col]]
      
      if (is.integer(current_col)) {value <- as.integer(value)
      }else if (is.numeric(current_col)) {value <- as.numeric(value)}

      app_data$project[row, col] <- value
      
    })
    
    output$validation <- renderText({
      
      df <- app_data$project
      
      # print(df)
      
      duplicates <- df |>
        dplyr::count(project_code) |>
        dplyr::filter(n > 1)
      
      print(duplicates)
      
      if (nrow(duplicates) == 0) {
        "✓ No duplicate project_code"
      } else {
        paste(c("⚠ Duplicate project_code:",duplicates$project_code),collapse = "\n")
      }
      })
    
    output$project_table <- DT::renderDT({
      
      dat<-isolate(app_data$project)
      
      DT::datatable(dat,  editable = TRUE, selection = "multiple",
                    options = list(pageLength = page_length, stateSave = TRUE, searching = TRUE)) |>
        DT::formatRound(columns = "budget", digits = 0)
      })
    
    proxy <- DT::dataTableProxy("project_table")
    
    # Helper: push data to the table without resetting page / filters
    refresh_table <- function(){
      DT::replaceData(
        proxy,
        app_data$project,
        resetPaging    = FALSE,
        clearSelection = "none"
      )
    }
    
    observeEvent(app_data$project, refresh_table(), ignoreInit = TRUE)
  })
  
}