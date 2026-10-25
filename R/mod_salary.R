library(shiny)

salary_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    h3("Salary"),
    DT::DTOutput(ns("salary_table")),
    br(),
    div(class = "d-flex gap-2",
        actionButton(ns("add_row"),"Add"),
        actionButton(ns("delete_row"),"Delete")),
    br(),
    verbatimTextOutput(ns("validation")),
    br(),
    plotOutput(ns("salary_plot"),height = "500px"))
}

salary_server <- function(id, app_data){
  
  moduleServer(id, function(input, output, session){
    
    observeEvent(input$add_row, {
      
      new_row <- data.frame(
        employee = "",
        year = as.integer(format(Sys.Date(), "%Y")),
        fte = 1,
        salary = 0,
        comment = ""
      )
      
      app_data$salary <- rbind(
        app_data$salary,
        new_row
      )
      
    })
    observeEvent(input$delete_row, {
      row <- input$salary_table_rows_selected
      if(length(row) > 0){
        app_data$salary <- app_data$salary[-row, ]
      }
    })
    observeEvent(input$salary_table_cell_edit, {
      
      info <- input$salary_table_cell_edit
      row <- info$row
      col <- info$col
      value <- info$value
      
      current_col <- app_data$salary[[col]]
      
      if (is.numeric(current_col)) {
        value <- as.numeric(value)
      }
      
      if (is.integer(current_col)) {
        value <- as.integer(value)
      }
      
      app_data$salary[row, col] <- value
      
    })
    # observeEvent(input$save, {
    #   save_workbook(app_data)
    # })
    # observeEvent(input$load, {
    #   load_workbook(app_data)
    # })
    # observeEvent(input$export, {
    #   export_workbook(app_data)
    # })
    output$salary_plot <- renderPlot({
      
      req(nrow(app_data$salary) > 0)
      ggplot(app_data$salary,aes(x = employee,y = salary,fill = as.factor(year)))+
        geom_bar(stat = "identity", position = "dodge")+
        theme_minimal()+
        labs(x = "Employee", y = "Gross salary (€/month)", fill = "year") 
    })
    output$validation <- renderText({
      
      df <- app_data$salary
      
      duplicates <- df |>
        dplyr::count(employee, year) |>
        dplyr::filter(n > 1)
      
      if (nrow(duplicates) == 0) {
        "✓ No duplicate employee/year combinations"
      } else {
        
        paste(
          c(
            "⚠ Duplicate employee/year combinations:",
            apply(
              duplicates,
              1,
              function(x)
                paste(
                  "-",
                  x["employee"],
                  x["year"]
                )
            )
          ),
          collapse = "\n"
        )
        
      }})
    
    # observe({
    #   
    #   cat(
    #     "Rows in salary table:",
    #     nrow(app_data$salary),
    #     "\n"
    #   )
    #   
    # })
    
    
    output$salary_table <- DT::renderDT(app_data$salary,editable=T,selection="single",filter="top")
  })

}

