library(shiny)

allocation_ui <- function(id){
  ns <- NS(id)
  
  tagList(
    DT::DTOutput(ns("allocation_table")),
    br(),
    div(class = "d-flex gap-2",
        actionButton(ns("add_row"), "Add"),
        actionButton(ns("delete_row"), "Delete")),
    br(),
    verbatimTextOutput(ns("validation")),
    br()
  )
}

allocation_server <- function(id, app_data, output_data){
  
  moduleServer(id, function(input, output, session){
    
    page_length <- 10
    
    # ---- Allowed values (reactive: table re-renders only if these change) ----
    choices <- reactive({
      list(
        project_code = sort(unique(na.omit(app_data$project$project_code))),
        employee     = sort(unique(na.omit(app_data$salary$employee)))
      )
    })
    
    # ---- Initial render: isolate() so edits never trigger a re-render ----
    output$allocation_table <- DT::renderDT({
      
      dat <- isolate(app_data$allocation)
      ch <- choices()
      
     DT::datatable(
        dat,
        filter    = "top",
        selection = "multiple",
        editable  = list(
          target  = "cell",
          date    = which(names(dat) %in% c("start_date", "end_date"))
        ),
        options = list(pageLength = page_length, stateSave = TRUE, searching = TRUE)
      )
    })
    
    proxy <- DT::dataTableProxy("allocation_table")
    
    # Helper: push data to the table without resetting page / filters
    refresh_table <- function(){
      DT::replaceData(
        proxy,
        app_data$allocation,
        resetPaging    = FALSE,
        clearSelection = "none"
      )
    }
    
    # ---- Shared setter with type coercion ----
    set_cell <- function(row, col, value){
      current_col <- app_data$allocation[[col]]
      
      if (inherits(current_col, "Date"))   value <- as.Date(value)
      else if (is.integer(current_col))    value <- as.integer(value)
      else if (is.numeric(current_col))    value <- as.numeric(value)
      
      app_data$allocation[row, col] <- value
      refresh_table()
    }
    
    # ---- Dropdown edits ----
    observeEvent(input$select_edit, {
      info <- input$select_edit
      set_cell(info$row, info$col, info$value)
    })
    
    # ---- Add ----
    observeEvent(input$add_row, {
      new_row <- data.frame(
        project_code = "",
        employee     = "",
        start_date   = as.Date(NA),
        end_date     = as.Date(NA),
        fte          = 0,
        comment      = ""
      )
      app_data$allocation <- rbind(app_data$allocation, new_row)
      refresh_table()
      
      # optional: jump to the last page to see the new row
      DT::selectPage(proxy, ceiling(nrow(app_data$allocation) / page_length))
    })
    
    # ---- Delete ----
    observeEvent(input$delete_row, {
      rows <- input$allocation_table_rows_selected
      if (length(rows) > 0) {
        app_data$allocation <- app_data$allocation[-rows, , drop = FALSE]
        refresh_table()
      }
    })
    
    # ---- Cell edit: update the data only, NOT the widget ----
    observeEvent(input$allocation_table_cell_edit, {
      info  <- input$allocation_table_cell_edit
      set_cell(info$row, info$col, info$value)
    })
    
    output$validation <- renderText({
      paste0(check_salary_allocation_consistency(app_data),
             check_project_allocation_consistency(app_data))
    })
    
    observeEvent(app_data$allocation, refresh_table(), ignoreInit = TRUE)
  })
}