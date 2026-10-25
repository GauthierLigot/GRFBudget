library(openxlsx2)
source("R/io.R")

app_data<-list()
app_data$salary<-read_xlsx("data/financial_data.xlsx", sheet = "salary")


ggplot(app_data$salary,aes(x = employee,y = salary,fill = as.factor(year)))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_minimal()+
  labs(x = "Employee", y = "Gross salary (€/month)", fill = "year") 

  