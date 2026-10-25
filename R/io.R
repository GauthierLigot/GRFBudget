save_workbook <- function(app_data) {
  wb<-get_workbook(app_data)
  wb_save(wb,app_data$current_file,overwrite = TRUE)
}

export_workbook <- function(app_data,filename) {
  wb<-get_workbook(app_data)
  wb_save(wb,filename,overwrite = TRUE)
}

get_workbook <- function(app_data){
  
  wb <- wb_workbook()
  
  wb$add_worksheet("salary")
  wb$add_data("salary", app_data$salary)
  
  wb$add_worksheet("projects")
  wb$add_data("projects", app_data$projects)
  
  wb$add_worksheet("allocation")
  wb$add_data("allocation", app_data$allocation)
  
  return(wb)
}

load_workbook <- function(app_data) {
  file <- app_data$current_file
  
  if (!file.exists(file)) return()
  
  app_data$salary <- read_xlsx(file, sheet = "salary")
  app_data$projects <- read_xlsx(file, sheet = "projects")
  app_data$allocation <- read_xlsx(file, sheet = "allocation")
  
}