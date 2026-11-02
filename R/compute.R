compute<-function(app_data){
  
  
  results<-list()
  
  allocation_monthly<-tibble()
  
  allocation_tmp<-app_data$allocation%>%
    mutate(start_day = as.numeric(format(start_date,"%d")),
           start_month = as.numeric(format(start_date,"%m")),
           start_year = as.numeric(format(start_date,"%Y")),
           end_day = as.numeric(format(end_date,"%d")),
           end_month = as.numeric(format(end_date,"%m")),
           end_year = as.numeric(format(end_date,"%Y")),
    )
  
  # i=27
  
  for(i in 1:nrow(allocation_tmp)){
    
    month <- allocation_tmp$start_month[i]
    year <-allocation_tmp$start_year[i]
    
    end_month <- allocation_tmp$end_month[i]
    end_year <-allocation_tmp$end_year[i]  
    
    nb_month <- 12 * (end_year-year) + end_month - month
    
    if(nb_month!=0){
      months <- c(month,month+1:nb_month-12*floor((month+1:nb_month-1)/12))
      years<-  c(year,year + floor((month+1:nb_month-1)/12))
    }else{
      months <- month
      years <- year
    }
    
    years_july<-ifelse(months<7,paste0(years-1,"-",years),paste0(years,"-",years+1))
    
    ### to be verfied for several years computation
    work_time_prop_month<-rep(1,nb_month+1)
    work_time_prop_month[1] <- (Hmisc::monthDays(allocation_tmp$start_date[i])-allocation_tmp$start_day[i]+1)/Hmisc::monthDays(allocation_tmp$start_date[i])
    work_time_prop_month[nb_month+1] <- allocation_tmp$end_day[i]/Hmisc::monthDays(allocation_tmp$end_date[i])
    
    tmp<-tibble(project_code = allocation_tmp$project_code[i],
                employee = allocation_tmp$employee[i],
                fte_project = allocation_tmp$fte[i],
                work_days_prop = work_time_prop_month,
                month = months,
                year = years,
                year_july = years_july)
    
    allocation_monthly<-allocation_monthly%>%
      bind_rows(tmp)
    rm(tmp)
  }
  
  #store outputs in app_data
  allocation_monthly<-allocation_monthly%>%
    left_join(app_data$salary,by = c("employee", "year"))%>%
    left_join(app_data$project, by="project_code",suffix=c("",".project"))%>%
    mutate(fte_from_allocation = fte_project * work_days_prop,
           fte_from_salary = fte * work_days_prop,
           expense = salary * fte_project/fte * work_days_prop)
  
  results$allocation_monthly <- allocation_monthly
  
  results$sum_project_year<-allocation_monthly%>%
    group_by(project_name,project_code,year_july)%>%
    summarise(fte = sum(fte_from_allocation),
              expense = sum(expense), 
              budget = first(budget),.groups = "drop_last")%>% # bad estimates for multi-year projects
    arrange(year_july)%>%
    group_by(project_name,project_code)%>%
    mutate(cumexpense = cumsum(expense))%>%
    ungroup()%>%
    mutate(net = budget-cumexpense)%>%
    arrange(project_name, project_code, year_july)
  
  
  results$sum_project<-results$sum_project_year%>%
    group_by(project_name,project_code)%>%
    summarise(budget = first(budget),
              expense = sum(expense,na.rm = T),.groups = "drop_last")%>%
    ungroup()%>%
    mutate(net = budget - expense)
  
  results$sum_employee<-allocation_monthly%>%
    group_by(employee,year_july)%>%
    summarise(fte_from_allocation = sum(fte_from_allocation,na.rm=T),
              fte_from_salary = sum(fte_from_salary),
              expense = sum(expense),.groups = "drop_last")%>%
    arrange(employee,year_july)
  
  results$sum_employee_project<-allocation_monthly%>%
    group_by(project_name,project_code,employee,year_july)%>%
    summarise(fte_from_allocation = sum(fte_from_allocation,na.rm=T),
              fre_from_salary = sum(fte_from_salary),
              expense = sum(expense),.groups = "drop_last")%>%
    arrange(employee,year_july)
  
  results$sum_employee_project_month<-allocation_monthly%>%
    group_by(project_name,project_code,employee,year,month)%>%
    summarise(fte_from_allocation = sum(fte_from_allocation,na.rm=T),
              fte_from_salary = sum(fte_from_salary),
              expense = sum(expense),.groups = "drop_last")%>%
    arrange(project_code,employee,year,month)
  
  return(results)
  
  
}