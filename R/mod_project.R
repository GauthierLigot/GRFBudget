library(shiny)

project_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    h3("Project management"),
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
      
      app_data$project <- rbind(
        app_data$project,
        new_row
      )
      
    })
    observeEvent(input$delete_row, {
      row <- input$project_table_rows_selected
      if(length(row) > 0){
        app_data$project <- app_data$project[-row, ]
      }
    })
    observeEvent(input$project_table_cell_edit, {
      
      info <- input$project_table_cell_edit
      row <- info$row
      col <- info$col
      value <- info$value
      
      current_col <- app_data$project[[col]]
      
      if (is.numeric(current_col)) {
        value <- as.numeric(value)
      }
      
      if (is.integer(current_col)) {
        value <- as.integer(value)
      }
      
      app_data$project[row, col] <- value
      
    })
    output$validation <- renderText({
      
      df <- app_data$project
      
      print(df)
      
      duplicates <- df |>
        dplyr::count(project_code) |>
        dplyr::filter(n > 1)
      
      print(duplicates)
      
      if (nrow(duplicates) == 0) {
        "✓ No duplicate project_code"
      } else {
        paste(c("⚠ Duplicate project_code:",duplicates$project_code),collapse = "\n")
      }})
    
    output$project_table <- DT::renderDT(DT::datatable(
      app_data$project,  editable = TRUE, selection = "single") |>
        DT::formatRound(columns = "budget", digits = 0))
  })
  
}