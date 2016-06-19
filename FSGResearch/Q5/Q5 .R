PM_students <- read.csv('/Users/yimanzhang/Desktop/intern/FSG/FSG_research/Q5.csv',stringsAsFactors = F)
head(PM_students)
library('lubridate')
int1 <- interval(ymd("2015-09-07"), ymd("2015-11-02"))
int2 <- interval(ymd("2015-11-03"), ymd("2016-01-19"))
int3 <- interval(ymd("2016-01-20"), ymd("2016-03-21"))
int4 <- interval(ymd("2016-03-22"), ymd("2016-05-30"))
timerange <- interval(PM_students$start,PM_students$end)
Q1=int_overlaps(timerange, int1)
Q2=int_overlaps(timerange, int2)
Q3=int_overlaps(timerange, int3)
Q4=int_overlaps(timerange, int4)
PM=cbind(PM_students[,c(1:6)],Q1,Q2,Q3,Q4)
head(PM)

result2 <-  PM %>% 
  melt(id=c('Campus','Classroom','Grade','GroupID','GroupName','StudentID'),na.rm=T) %>%
  mutate(Quarter=variable) %>% 
  filter(value=='TRUE') %>%
  group_by(Campus,Classroom,Quarter,Grade,GroupName) %>%
  summarize(n=n()) %>%
  arrange(desc(n)) %>%
  tbl_df %>% print
dim(result2)[1]
write.csv(result2, "/Users/yimanzhang/Desktop/intern/FSG/FSG_research/Q5.csv")
