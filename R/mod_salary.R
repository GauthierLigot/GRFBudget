library(shiny)

salary_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    # h3("Salary"),
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
    
    page_length <- 10
    
    observeEvent(input$add_row, {
      
      new_row <- data.frame(
        employee = "",
        year = as.integer(format(Sys.Date(), "%Y")),
        fte = 1,
        salary = 0,
        comment = ""
      )
      
      app_data$salary <- rbind(app_data$salary,new_row)
      refresh_table()
      # jump to the last page to see the new row
      DT::selectPage(proxy, ceiling(nrow(app_data$salary) / page_length))
      
    })
    
    observeEvent(input$delete_row, {
      row <- input$salary_table_rows_selected
      if(length(row) > 0){
        app_data$salary <- app_data$salary[-row, ,drop=FALSE]
        refresh_table()
      }
    })
    
    observeEvent(input$salary_table_cell_edit, {
      
      info <- input$salary_table_cell_edit
      row <- info$row
      col <- info$col
      value <- info$value
      
      current_col <- app_data$salary[[col]]
      
      if (is.integer(current_col)) {value <- as.integer(value)
      }else if (is.numeric(current_col)) {
        value <- as.numeric(value)
      }
      
      app_data$salary[row, col] <- value
      # refresh_table()
    })
    
    
    output$salary_plot <- renderPlot({
      
      req(nrow(app_data$salary) > 0)
      
      levels_order<-app_data$salary%>%
        group_by(employee)%>%
        summarise(mean_salary = mean(salary))%>%
        arrange(mean_salary)
      
      ggplot(app_data$salary,aes(x = factor(employee,order=T,levels=levels_order$employee),
                                 y = salary,fill = as.factor(year)))+
        geom_bar(stat = "identity", position = "dodge")+
        theme_minimal()+
        labs(x = "Employee", y = "Gross salary (€/month)", fill = "year")+
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
              axis.title.x=element_blank())
      
    })
    
    output$validation <- renderText({
        check_salary_duplicates(app_data)
    })
    
    output$salary_table <- DT::renderDT({
      
      dat<-isolate(app_data$salary)
      
      DT::datatable(dat,  editable = TRUE, 
                    selection = "multiple", 
                    #filter = "top",
                    options = list(pageLength = page_length, stateSave = TRUE, searching = TRUE)) |>
        DT::formatRound(columns = "salary", digits = 0)
      }
      )
    
    proxy <- DT::dataTableProxy("salary_table")
    
    # Helper: push data to the table without resetting page / filters
    refresh_table <- function(){
      DT::replaceData(
        proxy,
        app_data$salary,
        resetPaging    = FALSE,
        clearSelection = "none"
      )
    }
    
    observeEvent(app_data$salary, refresh_table(), ignoreInit = TRUE)
      
      
  })

}

