library(openxlsx2)
source("R/io.R")
source("R/compute.R")
source("R/output_data.R")

app_data<-list()

app_data$salary<-read_xlsx("c:/Users/gligot/Desktop/20261103_GRFbudget_InputData_scénario catastrophe.xlsx", sheet = "salary")
app_data$allocation<-read_xlsx("c:/Users/gligot/Desktop/20261103_GRFbudget_InputData_scénario catastrophe.xlsx", sheet = "allocation")
app_data$project<-read_xlsx("c:/Users/gligot/Desktop/20261103_GRFbudget_InputData_scénario catastrophe.xlsx", sheet = "project")


app_data$salary<-read_xlsx("data/current_data.xlsx", sheet = "salary")
app_data$allocation<-read_xlsx("data/current_data.xlsx", sheet = "allocation")
app_data$project<-read_xlsx("data/current_data.xlsx", sheet = "project")

output_data<-list()

results<-compute(app_data)

head(results$sum_project)

output_data$allocation_monthly <- results$allocation_monthly
output_data$sum_project_year <- results$sum_project_year
output_data$sum_project <- results$sum_project
output_data$sum_employee <- results$sum_employee
output_data$sum_employee_project <- results$sum_employee_project
output_data$sum_employee_project_month <- results$sum_employee_project_mont

# add text box to make these values editable
output_data$mindate = min(app_data$project$start_date)
output_data$maxdate = max(app_data$project$end_date)


spcm<-output_data$sum_employee_project_month%>%
  mutate(month_year = as.Date(paste0(year,"-",month,"-01")))%>%
  filter(month_year >= ymd(output_data$mindate),
         month_year <= ymd(output_data$maxdate))

pers<-unique(spcm$employee)

ggplot(spcm,aes(x=month_year,y=project_code,col=fte_from_allocation))+
  facet_wrap(~employee,ncol=4)+geom_point()+
  ylab("")+xlab("Date")+
  scale_colour_gradientn(colours = rainbow(4),name="EFT")+
  # scale_x_date(breaks = as.Date(c("2019-07-01","2020-07-01","2021-07-01","2022-07-01","2023-07-01","2024-07-01")),
  # labels = paste0("7/",19:24))+
  theme(legend.position="bottom",axis.text.x = element_text(angle = 90, vjust = .5),
        panel.grid.minor = element_blank())


spcm<-output_data$sum_employee_project_month%>%
  mutate(month_year = as.Date(paste0(year,"-",month,"-01")))%>%
  filter(month_year >= ymd(output_data$mindate),
         month_year <= ymd(output_data$maxdate))

ggplot(spcm,aes(x=month_year,y=employee,col=fte_from_allocation))+
  facet_wrap(~project_name,ncol=4)+geom_point()+
  ylab("")+xlab("Date")+
  scale_colour_gradientn(colours = rainbow(4),name="EFT")+
  theme(legend.position="none")+
  # scale_x_date(breaks = as.Date(c("2019-07-01","2020-07-01","2021-07-01","2022-07-01","2023-07-01","2024-07-01")),
  # labels = paste0("7/",19:24))+
  theme(axis.text.x = element_text(angle = 90,vjust=.5), panel.grid.minor = element_blank())


output_data$sum_project %>%
  left_join(select(app_data$project,project_code,start_date,end_date),by="project_code")%>%
  filter(start_date >= ymd(output_data$mindate),
         start_date <= ymd(output_data$maxdate))%>%
  select(-start_date,-end_date)%>%
DT::datatable(editable = FALSE, filter = "top") |>
    DT::formatRound(columns = c("budget","expense","net"), digits = 0)
