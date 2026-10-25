save_workbook <- function(app_data,file) {
  wb<-get_workbook(app_data)
  wb_save(wb,file,overwrite = TRUE)
}

export_workbook <- function(app_data,file) {
  wb<-get_workbook(app_data)
  wb_save(wb,file,overwrite = TRUE)
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

load_workbook <- function(app_data, file) {
  
  if (!file.exists(file)) return()
  
  app_data$salary <- read_xlsx(file, sheet = "salary")
  app_data$project <- read_xlsx(file, sheet = "project")
  app_data$allocation <- read_xlsx(file, sheet = "allocation")
  
}