library(openxlsx2)
source("R/io.R")

app_data<-list()
app_data$salary<-read_xlsx("data/current_data.xlsx", sheet = "salary")
app_data$allocation<-read_xlsx("data/current_data.xlsx", sheet = "allocation")
app_data$project<-read_xlsx("data/current_data.xlsx", sheet = "project")

message<-"Check consistency between salary and allocation data"

name1<-app_data$salary%>%
  dplyr::select(employee)%>%
  distinct()
name2<-app_data$allocation%>%
  dplyr::select(employee)%>%
  distinct()

tmp1<-anti_join(name1,name2, by = "employee")
tmp2<-anti_join(name2,name1, by = "employee")

if(nrow(tmp1)>0){
  tmp_message<-paste("⚠ Employees with missing allocation :",paste(tmp1$employee,collapse = "; "))
  message<-paste(message, "\n", tmp_message)
} 
if(nrow(tmp2)>0){
  tmp_message<-paste("⚠ Employees with missing salary :",paste(tmp1$employee,collapse = "; "))
  message<-paste(message, "\n", tmp_message)
} 
if(nrow(tmp1)==0 & nrow(tmp2)==0){
  print("✓ A salary and an allocation was defined for all employees")
}
############

######

message<-paste(message, "\n", "Check consistency between project and allocation data")

name1<-app_data$project%>%
  dplyr::select(project_code)%>%
  distinct()
name2<-app_data$allocation%>%
  dplyr::select(project_code)%>%
  distinct()

tmp1<-anti_join(name1,name2, by = "project_code")
tmp1<-anti_join(name2,name1, by = "project_code")

if(nrow(tmp1)>0) {
  tmp_message<-paste("⚠ Projects without any allocation :",paste(tmp1$employee,collapse = "; "))
  message<-paste(message, "\n", tmp_message)
}
if(nrow(tmp2)>0) {
  tmp_message<-paste("⚠ Allocations for undefined projects:",paste(tmp1$employee,collapse = "; "))
  message<-paste(message, "\n", tmp_message)
}
if(nrow(tmp1)==0){
  tmp_message("✓ All projects have allocation and all allocations have defined projects")
  message<-paste(message, "\n", tmp_message)
  }


check_project_allocation_consistency<-function(app_data){
  
  message<-paste(message, "\n", "Check consistency between project and allocation data")
  
  name1<-app_data$project%>%
    dplyr::select(project_code)%>%
    distinct()
  name2<-app_data$allocation%>%
    dplyr::select(project_code)%>%
    distinct()
  
  tmp1<-anti_join(name1,name2, by = "project_code")
  tmp1<-anti_join(name2,name1, by = "project_code")
  
  if(nrow(tmp1)>0) {
    tmp_message<-paste("⚠ Projects without any allocation :",paste(tmp1$employee,collapse = "; "))
    message<-paste(message, "\n", tmp_message)
  }
  if(nrow(tmp2)>0) {
    tmp_message<-paste("⚠ Allocations for undefined projects:",paste(tmp1$employee,collapse = "; "))
    message<-paste(message, "\n", tmp_message)
  }
  if(nrow(tmp1)==0){
    tmp_message("✓ All projects have allocation and all allocations have defined projects")
    message<-paste(message, "\n", tmp_message)
  }
  
  return(message)
  
}
