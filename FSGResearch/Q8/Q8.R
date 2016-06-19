exit_daily <- read.csv('/Users/yimanzhang/Desktop/intern/FSG/FSG_research/Exit_Daily.csv',stringsAsFactors = F)
str(exit_daily)
exit_daily$exitPass <- ifelse(exit_daily$exit_avg_score>=75,"Pass","Fail")
exit_daily$dailyPass <- ifelse(exit_daily$daily_avg_score>=75,"Pass","Fail")
sum(exit_daily$exitPass==exit_daily$dailyPass)/length(exit_daily$exitPass)

matchrate <- function(x){
  y=exit_daily[exit_daily$plan_name==x,]
  return(sum(y$exitPass==y$dailyPass)/length(y$exitPass))
}

plan_name=data.frame(summary(factor(exit_daily$plan_name)))
colnames(plan_name)='N'
library('magrittr')
library('dplyr')
matchrate <- exit_daily$plan_name %>%
  unique %>% 
  as.data.frame %>%
  apply(1,matchrate) %>% 
  print

y=cbind(plan_name,matchrate)
rownames(y)=NULL
result = cbind(rownames(plan_name),y)
write.csv(result,'/Users/yimanzhang/Desktop/intern/FSG/FSG_research/exit_daily_match.csv')
