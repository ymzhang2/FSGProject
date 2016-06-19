
select weekly.student_id,weekly.plan_name,weekly.plan_id,daily.week,weekly.stat 'weekly_assessment_score', daily.avg 'daily_avg_score',daily.n
from
		(select fsg_lesson_stats.student_id,plans.id 'plan_id',plans.name 'plan_name', lessons.week,lessons.weight,lessons.type,fsg_lesson_stats.stat
		from fsg_lesson_stats inner join lessons inner join plans
		on fsg_lesson_stats.lesson_id = lessons.id and plans.id = lessons.plan_id 
		where lessons.type='W' and fsg_lesson_stats.stat is not NULL 
		order by plan_name,plan_id,student_id,lessons.week, lessons.weight) weekly
inner join

		(select fsg_lesson_stats.student_id,plans.id 'plan_id',plans.name 'plan_name', lessons.week,lessons.weight,lessons.type,round(avg(fsg_lesson_stats.stat),0) 'avg',count(*) 'n'
		 from fsg_lesson_stats inner join lessons inner join plans
		 on fsg_lesson_stats.lesson_id = lessons.id and plans.id = lessons.plan_id 
		 where lessons.type='L' and fsg_lesson_stats.stat is not NULL 
		 group by plan_name,plan_id,student_id,lessons.week) daily
on weekly.student_id = daily.student_id and weekly.plan_id = daily.plan_id and weekly.week=daily.week
order by plan_name, plan_id, student_id;
