create_app_data <- function() {
  
  reactiveValues(
    
    salary = data.frame(
      employee = c("John","Mary"),
      year = c(2026,2026),
      fte = c(1,0.8),
      salary = c(50000,42000),
      comment = c("","")
    ),
    
    projects = data.frame(
      otp = character(),
      project_code = character(),
      project_name = character(),
      budget = numeric(),
      start_date = as.Date(character()),
      end_date = as.Date(character()),
      comment = character()
    ),
    
    allocation = data.frame(
      project_code = character(),
      employee = character(),
      start_date = as.Date(character()),
      end_date = as.Date(character()),
      fte = numeric(),
      comment = character()
    ),
    
    current_file = "data/current_data.xlsx"
  )
  
}