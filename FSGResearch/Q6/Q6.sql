
SELECT DescriptionTab.* , lessonTab.LessonId, lessonTab.Lesson_Name, lessonTab.Lesson_Number, lessonTab.Score, lessonTab.Lesson_Type, lessonTab.Lesson_Stat_Date, lessonTab.Lesson_Template, lessonTab.Lesson_Template_Number
FROM 
				(select students.id 'StudentID',students.first_name 'First Name',students.last_name 'Last Name',concat(students.first_name,' ',students.last_name) 'Full Name',
												group_students.group_id 'GroupID', plans.name 'Group Name', 
												classrooms.id 'ClassroomID',classrooms.name 'Classroom Name',
												if(school_year_students.student_grade=-1,'PK','PS') 'Grade',
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
				order by StudentID) AS DescriptionTab
INNER JOIN
				(select lessons.plan_id, fsg_lesson_stats.student_id,lessons.id 'LessonId', lesson_templates.name 'Lesson_Name',concat(lessons.week, '.', lessons.weight) 'Lesson_Number', 
					   fsg_lesson_stats.stat 'Score',
					   lessons.type 'Lesson_Type', lessons.updated_at 'Lesson_Stat_Date', 
					   lessons.lesson_template_id 'Lesson_Template',concat(lesson_templates.week, '.', lesson_templates.weight) 'Lesson_Template_Number'
				from lessons inner join fsg_lesson_stats inner join lesson_templates
				on lessons.id = fsg_lesson_stats.lesson_id and lesson_templates.id = lessons.lesson_template_id 
				where lessons.type in ('L','R','C')
				order by plan_id, student_id, Lesson_Number) AS lessonTab
ON DescriptionTab.GroupID = lessonTab.plan_id 
And DescriptionTab.StudentID = lessonTab.student_id;