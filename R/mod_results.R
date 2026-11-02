library(shiny)

results_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    # h3("Results"),
    # 
    # p("Calculation outputs will be displayed here.")
    div(class = "d-flex gap-2",
        dateInput(ns("mindate"),"Start date"),
        dateInput(ns("maxdate"),"End date"),
        actionButton(ns("compute"),"Compute")#,
        #actionButton(ns("export"),"Export results (.xlsx)")
        ),
    br(),
    DT::DTOutput(ns("output_table")),
    br(),
    plotOutput(ns("allocation_per_employee_plot"),height = "750px"),    
    br(),
    plotOutput(ns("allocation_per_project_plot"),height = "750px")
  )
}

results_server <- function(id, app_data, output_data){
  
  moduleServer(id, function(input, output, session){
    
    observe({
      req(nrow(app_data$project) > 0)
      updateDateInput(session,"mindate",value = ymd(paste0(year(today()),"0701"))) 
      updateDateInput(session,"maxdate",value = ymd(paste0(year(today())+1,"0630")))
      # to show all data by default
      # updateDateInput(session,"mindate",value = min(app_data$project$start_date,na.rm = TRUE))
      # updateDateInput(session,"maxdate",value = max(app_data$project$end_date,na.rm = TRUE))
    })
    
    observeEvent(input$compute, {
      req(input$mindate)
      req(input$maxdate)
      
      if (input$mindate >= input$maxdate) {
        
        showNotification(
          "Start date must be before the end date.",
          type = "error"
        )
        
        return(NULL)
      }
      
      withProgress(
        message = "Computing results...",
        value = 0,
        {
          
          incProgress(0.2, detail = "Monthly allocations")
          
          results = compute(app_data)
          
          incProgress(0.8, detail = "Preparing outputs")
          
          output_data$allocation_monthly <- results$allocation_monthly
          output_data$sum_project_year <- results$sum_project_year
          output_data$sum_project <- results$sum_project
          output_data$sum_employee <- results$sum_employee
          output_data$sum_employee_project <- results$sum_employee_project
          output_data$sum_employee_project_month <- results$sum_employee_project_mont
      })
      
    })
    
    output$allocation_per_employee_plot <- renderPlot({
      
      req(nrow(output_data$sum_employee_project_month) > 0)
      
      spcm<-output_data$sum_employee_project_month%>%
        mutate(month_year = as.Date(paste0(year,"-",month,"-01")))%>%
        filter(month_year >= ymd(input$mindate),
               month_year <= ymd(input$maxdate))
      
      req(nrow(spcm) > 0)
      pers<-unique(spcm$employee)
      
      ggplot(spcm,aes(x=month_year,y=project_code,col=fte_from_allocation))+
        facet_wrap(~employee,ncol=4)+geom_point()+
        ylab("")+xlab("Date")+
        scale_colour_gradientn(colours = rainbow(4),name="EFT")+
        # scale_x_date(breaks = as.Date(c("2019-07-01","2020-07-01","2021-07-01","2022-07-01","2023-07-01","2024-07-01")),
        # labels = paste0("7/",19:24))+
        theme(legend.position="bottom",axis.text.x = element_text(angle = 90, vjust = .5),
              panel.grid.minor = element_blank())
      
    })
    
    output$allocation_per_project_plot <- renderPlot({
      req(nrow(output_data$sum_employee_project_month) > 0)
      
      spcm<-output_data$sum_employee_project_month%>%
        mutate(month_year = as.Date(paste0(year,"-",month,"-01")))%>%
        filter(month_year >= ymd(input$mindate),
               month_year <= ymd(input$maxdate))
      req(nrow(spcm) > 0)
      
      ggplot(spcm,aes(x=month_year,y=employee,col=fte_from_allocation))+
        facet_wrap(~project_name,ncol=4)+geom_point()+
        ylab("")+xlab("Date")+
        scale_colour_gradientn(colours = rainbow(4),name="EFT")+
        theme(legend.position="none")+
        # scale_x_date(breaks = as.Date(c("2019-07-01","2020-07-01","2021-07-01","2022-07-01","2023-07-01","2024-07-01")),
        # labels = paste0("7/",19:24))+
        theme(axis.text.x = element_text(angle = 90,vjust=.5), panel.grid.minor = element_blank())
      
    })
    
    output$output_table <- DT::renderDT(output_data$sum_project %>%
                                          left_join(select(app_data$project,project_code,start_date,end_date),by="project_code")%>%
                                          filter(start_date >= ymd(input$mindate),
                                                 start_date <= ymd(input$maxdate))%>%
                                          select(-start_date,-end_date)%>%
                                          DT::datatable(editable = FALSE, filter = "top") |>
                                          DT::formatRound(columns = c("budget","expense","net"), digits = 0))
    
  })
  
}