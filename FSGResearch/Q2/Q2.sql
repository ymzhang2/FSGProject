
select tab.campus_name, tab.classroom_name,tab.plan_name,tab.grade,avg(tab.diffdate) 'avg'
from 
	(select fsg_lesson_stats.student_id 'student_id', campuses.name 'campus_name',classrooms.name 'classroom_name',
				plans.name 'plan_name',plans.id 'plan_id',datediff(date(max(fsg_lesson_stats.updated_at)), date(min(fsg_lesson_stats.updated_at))) 'diffdate',
                if(school_year_students.student_grade='-1',"PK","PS") 'grade'
	from fsg_lesson_stats inner join lessons inner join plans inner join groups inner join classrooms 
         inner join classroom_students inner join campuses inner join school_year_students
	on fsg_lesson_stats.lesson_id = lessons.id and plans.id = lessons.plan_id and plans.id = groups.id
		and classrooms.id=groups.classroom_id and classroom_students.classroom_id = classrooms.id 
		and campuses.id=classrooms.campus_id and school_year_students.student_id = fsg_lesson_stats.student_id
    where classrooms.lea_id = 1 
	group by student_id,plan_id
    having diffdate >0
    order by plan_name, plan_id, grade,campus_name,classroom_name) tab
where classroom_name!='DEMO' 
group by tab.grade,tab.classroom_name, tab.plan_name
order by plan_name,grade,avg desc;



