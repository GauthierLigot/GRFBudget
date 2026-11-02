create_app_data <- function() {
  
  reactiveValues(
    
    salary = data.frame(
      employee = character(),
      year = numeric(),
      fte = numeric(),
      salary = numeric(),
      comment = character()
    ),
    
    project = data.frame(
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
    
    current_file = "data/current_data.xlsx")
  
}
