library(openxlsx2)
source("R/io.R")

app_data<-list()
app_data$salary<-read_xlsx("data/current_data.xlsx", sheet = "salary")


ggplot(app_data$salary,aes(x = employee,y = salary,fill = as.factor(year)))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_minimal()+
  labs(x = "Employee", y = "Gross salary (€/month)", fill = "year") 

ggplot(app_data$salary,aes(x = employee,y = salary,fill = as.factor(year)))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_minimal()+
  labs(x = "Employee", y = "Gross salary (€/month)", fill = "year")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x=element_blank())


levels_order<-app_data$salary%>%
  group_by(employee)%>%
  summarise(mean_salary = mean(salary))%>%
  arrange(mean_salary)

ggplot(app_data$salary,aes(x = factor(employee,order=T,levels=levels_order$employee),
            y = salary,fill = as.factor(year)))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_minimal()+
  labs(x = "Employee", y = "Gross salary (€/month)", fill = "year")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        axis.title.x=element_blank())
