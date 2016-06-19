data <- read.csv('/Users/yimanzhang/Desktop/intern/FSG/FSG_research/Q4.csv',stringsAsFactors = F)
head(data)
library('lubridate')
int1 <- interval(ymd("2015-09-07"), ymd("2015-11-02"))
int2 <- interval(ymd("2015-11-03"), ymd("2016-01-19"))
int3 <- interval(ymd("2016-01-20"), ymd("2016-03-21"))
int4 <- interval(ymd("2016-03-22"), ymd("2016-05-30"))
timerange <- interval(data$start,data$end)
Q1=int_overlaps(timerange, int1)
Q2=int_overlaps(timerange, int2)
Q3=int_overlaps(timerange, int3)
Q4=int_overlaps(timerange, int4)
Q=cbind(data[,c(1:3)],Q1,Q2,Q3,Q4)
head(Q,n=200)
library('magrittr')
library('dplyr')
library('reshape')
result1 <- Q %>% 
    melt(id=c('Grade','GroupID','GroupName')) %>%
    mutate(Quarter=variable) %>%
    filter(value=='TRUE') %>%
    group_by(Quarter,Grade,GroupName) %>%
    summarize(n=n()) %>%
    arrange(desc(n)) %>%
  tbl_df %>% print
dim(result1)[1]
write.csv(result1, "/Users/yimanzhang/Desktop/intern/FSG/FSG_research/Q4.csv")


