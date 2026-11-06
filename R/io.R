save_input <- function(app_data,file) {
  message("Building workbook...")
  t1 <- Sys.time()
  wb<-get_input(app_data)
  message(Sys.time() - t1)
  message("Saving workbook...")
  wb_save(wb,file,overwrite = TRUE)
  message(Sys.time() - t1)
}

export_intput <- function(app_data,file) {
  wb<-get_input(app_data)
  wb_save(wb,file,overwrite = TRUE)
}

get_input <- function(app_data){

  wb <- wb_workbook()

  wb$add_worksheet("salary")
  wb$add_data("salary", app_data$salary)
  
  wb$add_worksheet("project")
  wb$add_data("project", app_data$project)
  
  wb$add_worksheet("allocation")
  wb$add_data("allocation", app_data$allocation)

}

load_input <- function(app_data, file) {
  
  print(file)
  if (!file.exists(file)) return()
  
  app_data$salary <- read_xlsx(file, sheet = "salary")
  app_data$project <- read_xlsx(file, sheet = "project")
  app_data$allocation <- read_xlsx(file, sheet = "allocation")
  
}

export_output <- function(app_data, output_data, file) {
  wb<-get_input(app_data)
  
  wb$add_worksheet("allocation_monthly")
  wb$add_data("allocation_monthly", output_data$allocation_monthly)
  
  wb$add_worksheet("sum_project_year")
  wb$add_data("sum_project_year", output_data$sum_project_year)
  
  wb$add_worksheet("sum_project")
  wb$add_data("sum_project", output_data$sum_project)
  
  wb$add_worksheet("sum_employee")
  wb$add_data("sum_employee", output_data$sum_employee)
  
  wb$add_worksheet("sum_employee_project")
  wb$add_data("sum_employee_project", output_data$sum_employee_project)
  
  wb$add_worksheet("sum_employee_project_month")
  wb$add_data("sum_employee_project_month", output_data$sum_employee_project_month)
  
  wb_save(wb,file,overwrite = TRUE)
}