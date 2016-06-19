exit <- read.csv('/Users/yimanzhang/Desktop/intern/FSG/FSG_research/NumberofExitvsPass.csv', header=T,na.strings=T,stringsAsFactors = F)
str(exit)
exit$name=as.factor(exit$name)
score = rep(0)
Last_Exit_Exam_Score <- function(x){ 
  if(!is.na(x[3])) {
    score= x[3]
  } else if (!is.na(x[2])) {
    score = x[2]
  } else 
    score =x[1]
  return (score)
}
library('dplyr')
library('magrittr')
#str(exit)
Last_Score <- exit[,c(8,9,10)] %>% 
  apply(2,function(x) as.numeric(x)) %>%
  apply(1, Last_Exit_Exam_Score) 

exit1 <- na.omit(cbind(exit[,c(1,2,3,4)],Last_Score))
head(exit1)
PassRate <- exit1 %>%
            group_by(plan_id) %>% 
            summarise(PassRate=sum(Last_Score>=75)/n())
PassRate

#str(exit1)
#exit1[exit1$plan_id==3,]
#head(exit1)
pace <- read.csv('/Users/yimanzhang/Desktop/intern/FSG/FSG_research/LastLesson.csv', header=T,na.strings = F)
summary(pace)
str(pace)
head(pace)
pace = pace %>% 
  filter(plan_tier_id==1) %>%
  mutate(Round_Last_lesson_Taught=ifelse(abs(Last_Lesson_Taught-(trunc(Last_Lesson_Taught)+0.5))>=0.25, trunc(Last_Lesson_Taught), trunc(Last_Lesson_Taught)+0.5))


avg_by_month <- pace %>% 
        group_by(plan_name,Grade) %>% 
        summarize(mean=mean(Round_Last_lesson_Taught),n=n()) 
dim(avg_by_month)

avg_by_month1 =
              data.frame (
                plan_name = avg_by_month$plan_name,
                Grade=avg_by_month$Grade,
                mean = sapply(avg_by_month$mean,function(a) round(a, 1)),
                n = avg_by_month$n)%>% 
                print
library('ggplot2')
pace1 = pace%>%
       inner_join(avg_by_month1,by=c('plan_name','Grade')) %>% 
       inner_join(PassRate,by='plan_id') %>%
       mutate(diff=Round_Last_lesson_Taught-mean) %>%
       #mutate(rate=ifelse(abs(diff)<=0.3, "equal","unequal")) %>%
       mutate(rate=ifelse(abs(diff)<=0.3, "equal", ifelse(diff>0, 'more','less')))%>%
       mutate(speed=ifelse(Round_Last_lesson_Taught==mean,'equal',ifelse(Round_Last_lesson_Taught<mean,'slow','fast')))

head(pace1,n=10)

#data1 = pace1[pace1$plan_name%in%c('T1 Rhyme','T1 Rational Counting','T1 Phonemes','T1 Word Awareness'),]
model1= lm(PassRate~Last_Lesson_Taught+Grade, data=pace1)
summary(model1)
model2 = lm(PassRate ~ Last_Lesson_Taught + rate + First_Lesson_Taught+Grade,data=pace1)
summary(model2)
model3 = lm(PassRate~Last_Lesson_Taught*rate+Grade ,data=pace1)
summary(model3)



#install.packages('corrplot')
library('corrplot')
corrplot(cor(pace1[,names(pace1) %in% c("PassRate", "diff", "Last_Lesson_Taught", "First_Lesson_Taught","mean")]),method='number')

ggplot(pace1,aes(x=rate,y=PassRate,fill=Grade)) + geom_boxplot() + facet_wrap(~plan_name, scales='free')
library('mgcv')
library('nlme')
library('gamclass')
gam.fit = gam(PassRate ~ rate+s(Last_Lesson_Taught), data=pace1)
summary(gam.fit)
plot(gam.fit)


write.csv(pace1,'/Users/yimanzhang/Desktop/pace1.csv')



