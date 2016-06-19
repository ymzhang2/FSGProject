select t2.GroupName,t2.GroupID,t2.Grade,date(min(t2.updated_at)) 'start',date(max(t2.updated_at))  'end'
from 
			(select plans.name 'GroupName',lessons.id 'lesson_id',groups.id 'GroupID', fsg_lesson_stats.stat,  lessons.type,fsg_lesson_stats.updated_at,
                    if(school_year_students.student_grade=-1,'PK','PS') 'Grade'
			 from groups 
			 inner join lessons
			 inner join fsg_lesson_stats
			 inner join plans
			 inner join school_year_students
			  on groups.id = lessons.plan_id
			  And lessons.id = fsg_lesson_stats.lesson_id
			  And plans.id=lessons.plan_id
              And school_year_students.student_id=fsg_lesson_stats.student_id
			)t2
group by t2.GroupID;

