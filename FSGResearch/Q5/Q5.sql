select StudentPlanInfo.*,PlanInfo.start, PlanInfo.end
from 
   (select students.id 'StudentID',
			group_students.group_id 'GroupID', plans.name 'GroupName', 
			classrooms.name 'Classroom',campuses.name 'Campus',
			if(school_year_students.student_grade=-1,'PK','PS') 'Grade'


	from students inner join group_students inner join groups 
	inner join classrooms inner join plans 
	inner join school_year_students inner join campuses

	on students.id = group_students.student_id And groups.id = group_students.group_id
	And classrooms.id = groups.classroom_id And groups.id = plans.id 
	And school_year_students.student_id=students.id And campuses.id=classrooms.campus_id
    where campuses.lea_id = 1
	group by StudentID, groups.id
    )StudentPlanInfo
Inner join  

(select t2.plan_name,t2.group_id,date(min(t2.updated_at)) 'start',date(max(t2.updated_at))  'end'
from 
			(select plans.name 'plan_name',lessons.id 'lesson_id',groups.id 'group_id', fsg_lesson_stats.stat,  lessons.type,fsg_lesson_stats.updated_at
			 from groups 
			 inner join lessons
			 inner join fsg_lesson_stats
			 inner join plans
			 on groups.id = lessons.plan_id
			  And lessons.id = fsg_lesson_stats.lesson_id
			  And plans.id=lessons.plan_id
			)t2
group by t2.group_id)PlanInfo 
ON StudentPlanInfo.GroupID=PlanInfo.group_id;
