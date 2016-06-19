select fsg_lesson_stats.student_id,lessons.plan_id,plans.name,
				   if(school_year_students.student_grade=-2, "PS", "PK") 'Grade',
                   sum(if(lessons.type = 'W', 1,0)) 'Weekly_Assessments_Given', 
                   sum(if(lessons.type = 'E', 1, 0)) 'Number of Exit Exam',
                   round(avg(if(lessons.week = 0.5,fsg_lesson_stats.stat,NULL)),0) 'preclass_exit_exam',
                   round(avg(if(lessons.week = 2.5,fsg_lesson_stats.stat,NULL)),0) 'first_exit_exam',
                   round(avg(if(lessons.week = 4.5,fsg_lesson_stats.stat,NULL)),0) 'second_exit_exam',
                   round(avg(if(lessons.week = 6.5,fsg_lesson_stats.stat,NULL)),0) 'third_exit_exam',
                   max(if(lessons.type='E',fsg_lesson_stats.stat,NULL)) 'Maximum_Exit_Score',
                   if(max(if(lessons.type='E',fsg_lesson_stats.stat,NULL))>=75, 'Pass', 'Fail') 'Pass_Exam_or_Not'
from fsg_lesson_stats inner join lessons inner join plans inner join school_year_students
on fsg_lesson_stats.lesson_id = lessons.id and plans.id = lessons.plan_id 
   and school_year_students.student_id=fsg_lesson_stats.student_id
where lessons.type in ('W','E')
group by student_id, lessons.plan_id
order by student_id;