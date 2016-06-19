SELECT descriptionFieldsTable.*,
       lessonsTable.Total_lessons 'Total Lessons', lessonsTable.L 'Number of Lesson of Type L(Lesson)', 
       lessonsTable.R 'Number of Lesson of Type R(Reteach)',lessonsTable.C 'Number of Lesson of Type C(Custom)',
       lessonsTable.Last_Lesson_Taught 'Last Lesson Taught', lessonsTable.First_Lesson_Date 'First Lesson Date', lessonsTable.Last_Lesson_Date 'Last Lesson Date',
       weeklyExitTable.Weekly_Assessments_Given 'Number of Weekly Assessments', weeklyExitTable.preclass_exit_exam 'Preclass Exit Exam Score',weeklyExitTable.first_exit_exam 'First Exit Exam Score',      
       weeklyExitTable.second_exit_exam 'Second Exit Exam Score', weeklyExitTable.third_exit_exam 'Third Exit Exam Score', weeklyExitTable.Maximum_Exit_Score 'Maximum Exit Score'

FROM
	### description fields
	(select students.id 'StudentID',students.first_name 'First Name',students.last_name 'Last Name',concat(students.first_name,' ',students.last_name) 'Full Name',
			group_students.group_id 'GroupID', plans.name 'Group Name', 
			classrooms.id 'ClassroomID',classrooms.name 'Classroom Name',
			school_year_students.student_grade 'Grade',
			group_students.group_student_tier_id  'Student Plan Tier',
			group_students.exited_at 'Student Exit Date',
			groups.exited_at 'Group Exit Date'

	from students inner join group_students inner join groups 
	inner join classrooms inner join plans 
	inner join school_year_students

	on students.id = group_students.student_id And groups.id = group_students.group_id
	And classrooms.id = groups.classroom_id And groups.id = plans.id 
	And school_year_students.student_id=students.id

	group by StudentID, groups.id
	order by StudentID) AS descriptionFieldsTable

INNER JOIN

	#### Lessons 
	(select  fsg_lesson_stats.student_id,lessons.plan_id,count(fsg_lesson_stats.lesson_id) 'Total_Lessons',
			sum(if(lessons.type = 'L',1,0)) 'L',
			sum(if(lessons.type = 'R',1,0)) 'R',
			sum(if(lessons.type = 'C',1,0)) 'C',
			max(concat(lessons.week,'.',lessons.weight))'Last_Lesson_Taught',
			min(fsg_lesson_stats.updated_at) 'First_Lesson_Date',
			max(fsg_lesson_stats.updated_at) 'Last_Lesson_Date'
	from lessons inner join fsg_lesson_stats
	on lessons.id = fsg_lesson_stats.lesson_id
	where lessons.type in ('L','R','C')
	group by student_id, plan_id
	order by student_id) AS lessonsTable

inner join

	### Week assessment and Exit 
	(select fsg_lesson_stats.student_id,lessons.plan_id,
		   sum(if(lessons.type = 'W', 1,0)) 'Weekly_Assessments_Given',
		   round(avg(if(lessons.week = 0.5,fsg_lesson_stats.stat,NULL)),0) 'preclass_exit_exam',
		   round(avg(if(lessons.week = 2.5,fsg_lesson_stats.stat,NULL)),0) 'first_exit_exam',
		   round(avg(if(lessons.week = 4.5,fsg_lesson_stats.stat,NULL)),0) 'second_exit_exam',
		   round(avg(if(lessons.week = 6.5,fsg_lesson_stats.stat,NULL)),0) 'third_exit_exam',
		   max(if(lessons.type='E',fsg_lesson_stats.stat,NULL)) 'Maximum_Exit_Score'
	from fsg_lesson_stats inner join lessons
	on fsg_lesson_stats.lesson_id = lessons.id
	where lessons.type in ('W','E')
	group by student_id, lessons.plan_id
	order by student_id) AS weeklyExitTable
    
ON descriptionFieldsTable.StudentID=lessonsTable.student_id
	AND descriptionFieldsTable.GroupID=lessonsTable.plan_id
    AND lessonsTable.student_id=weeklyExitTable.student_id
    AND lessonsTable.plan_id=weeklyExitTable.plan_id;
