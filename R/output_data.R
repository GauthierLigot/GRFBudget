create_output_data <- function() {
  
  reactiveValues(
    allocation_monthly = data.frame(),
    sum_employee = data.frame(),
    sum_employee_project = data.frame(),
    sum_employee_project_month = data.frame(),
    sum_project = data.frame(project_name=character(),
                             project_code=character(),
                             budget=numeric(),
                             expense=numeric(),
                             net=numeric())
  )
  
}
