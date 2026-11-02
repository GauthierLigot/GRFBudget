check_salary_duplicates<-function(app_data){
  message<-""
  
  df <- app_data$salary
  
  duplicates <- df |>
    dplyr::count(employee, year) |>
    dplyr::filter(n > 1)
  
  if (nrow(duplicates) == 0) {
    tmp_message<-"✓ No duplicate employee/year combinations"
  } else {
    tmp_message<-paste(
      c(
        "⚠ Duplicate employee/year combinations:",
        apply(
          duplicates,
          1,
          function(x)
            paste(
              "-",
              x["employee"],
              x["year"]
            )
        )
      ),
      collapse = "\n"
    )
  }
  message<-paste0(message, tmp_message, "\n")
  return(message)
}

check_salary_allocation_consistency<-function(app_data){
  message<-""
  
  name1<-app_data$salary%>%
    dplyr::select(employee)%>%
    distinct()
  name2<-app_data$allocation%>%
    dplyr::select(employee)%>%
    distinct()
  
  tmp1<-anti_join(name1,name2, by = "employee")
  tmp2<-anti_join(name2,name1, by = "employee")
  
  if(nrow(tmp1)>0){
    tmp_message<-paste("⚠ Employees with no allocation :",paste(tmp1$employee,collapse = "; "))
    message<-paste0(message, tmp_message, "\n")
  } 
  if(nrow(tmp2)>0){
    tmp_message<-paste("⚠ Employees with no salary :",paste(tmp1$employee,collapse = "; "))
    message<-paste0(message, tmp_message, "\n")
  } 
  if(nrow(tmp1)==0 & nrow(tmp2)==0){
    tmp_message<-"✓ A salary and an allocation was defined for all employees"
    message<-paste0(message, tmp_message, "\n")
  }
  
  return(message)
}

check_project_allocation_consistency<-function(app_data){
  
  message<-""
  
  name1<-app_data$project%>%
    dplyr::select(project_code)%>%
    distinct()
  name2<-app_data$allocation%>%
    dplyr::select(project_code)%>%
    distinct()
  
  tmp1<-anti_join(name1,name2, by = "project_code")
  tmp2<-anti_join(name2,name1, by = "project_code")
  
  if(nrow(tmp1)>0) {
    tmp_message<-paste("⚠ Projects without any allocation :",paste(tmp1$employee,collapse = "; "))
    message<-paste0(message, tmp_message, "\n")
  }
  if(nrow(tmp2)>0) {
    tmp_message<-paste("⚠ Allocations for undefined projects:",paste(tmp1$employee,collapse = "; "))
    message<-paste0(message, tmp_message, "\n")
  }
  if(nrow(tmp1)==0 & nrow(tmp2)==0){
    tmp_message<-"✓ All projects have an allocation and all allocations have a defined project"
    message<-paste0(message, tmp_message, "\n")
  }
  
  return(message)
  
}

