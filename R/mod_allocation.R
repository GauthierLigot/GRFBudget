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
    dropdown_cols <- c("project_code", "employee")
    
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
      idx <- match(dropdown_cols, names(dat))   
      
      js_choices <- jsonlite::toJSON(
        setNames(unname(ch[dropdown_cols]), as.character(idx)),
        auto_unbox = FALSE
      )
      
      callback <- DT::JS(paste0("
  var choices = ", js_choices, ";
  var inputId = '", session$ns("select_edit"), "';

  // Capture phase on the table node: runs BEFORE DT's own dblclick editor
table.table().node().addEventListener('dblclick', function(e){
    var td = $(e.target).closest('tbody td')[0];
    if (!td) return;

    var cell = table.cell(td);
    if (!cell.index()) return;
    var col = cell.index().column;
    if (!(col in choices)) return;          // other columns: DT edits normally

    // Dropdown column: DT's text editor must never open
    e.stopImmediatePropagation();
    e.preventDefault();

    if ($(td).find('select').length) return; // dropdown already open

    var current = cell.data();
    var shown   = current;
    var rn      = table.row(cell.index().row).data()[0];   // row name

    var $sel = $('<select style=\"width:100%\"></select>');
    $('<option>').val('').text('\u2014 select \u2014').prop('disabled', true).appendTo($sel);
    choices[col].forEach(function(x){
      $('<option>').val(x).text(x).appendTo($sel);
    });
    $sel.val(current);
    $(td).empty().append($sel);
    $sel.focus();

    $sel.on('change', function(){
      shown = $sel.val();
      Shiny.setInputValue(inputId, {rowname: rn, col: col, value: shown},
                          {priority: 'event'});
      $(td).text(shown);
    });
    $sel.on('blur', function(){ $(td).text(shown); });

  }, true);   // <- true = capture phase
"))
      
     DT::datatable(
        dat,
        # filter    = "top",
        selection = "single",
        callback = callback,
        editable  = list(target  = "cell", date    = which(names(dat) %in% c("start_date", "end_date"))),
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
    
    # dropdown menu observer
    observeEvent(input$select_edit, {
      info <- input$select_edit
      row  <- match(as.character(info$rowname), rownames(app_data$allocation))
      
      if (is.na(row)) {
        showNotification("Could not find the row to update.", type = "error")
        return()
      }
      
      col_name <- names(app_data$allocation)[info$col]
      allowed  <- choices()[[col_name]]
      
      if (!(info$value %in% allowed)) {
        showNotification(
          paste0("'", info$value, "' is not a valid ", col_name, "."),
          type = "error"
        )
        refresh_table()    # revert the cell to the stored value
        return()
      }
      
      set_cell(row, info$col, info$value)
    })
    
    # ---- Shared setter with type coercion ----
    set_cell <- function(row, col, value){
      current_col <- app_data$allocation[[col]]
      
      if (inherits(current_col, "Date"))   value <- as.Date(value)
      else if (is.integer(current_col))    value <- as.integer(value)
      else if (is.numeric(current_col))    value <- as.numeric(value)
      
      app_data$allocation[row, col] <- value
    }
    
    # ---- Add ----
    observeEvent(input$add_row, {
      new_row <- data.frame(
        project_code = NA_character_,
        employee     = NA_character_,
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
      
      if (names(app_data$allocation)[info$col] %in% dropdown_cols) {
        showNotification("Please use the dropdown for this column.", type = "warning")
        refresh_table()     # revert the cell
        return()
      }
      
      set_cell(info$row, info$col, info$value)
    })
    
    output$validation <- renderText({
      paste0(check_salary_allocation_consistency(app_data),
             check_project_allocation_consistency(app_data))
    })
    
    observeEvent(app_data$allocation, refresh_table(), ignoreInit = TRUE)
  })
}