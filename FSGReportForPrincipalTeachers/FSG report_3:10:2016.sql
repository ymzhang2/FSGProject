     SELECT  GroupInfoTab.group_exit_status 'Group Exit Status', GroupInfoTab.Classroom, GroupInfoTab.Subject, 
			GroupInfoTab.exited_at,GroupInfoTab.GroupID, GroupInfoTab.GroupName 'Group Name', GroupInfoTab.number_of_students 'Number of Students',
			GroupInfoTab.T1, GroupInfoTab.DIP_T2_T3 'DIP/T2/T3',
			lessonsTab.first_lesson_date 'First Lesson Date',lessonsTab.last_lesson_date 'Last Lesson Date',
			lessonsTab.L 'Number of Lesson of Type L(Lesson)',lessonsTab.R 'Number of Lesson of Type R(Reteach)',
			lessonsTab.C 'Number of Lesson of Type C(custom)',lessonsTab.total_lessons 'Total Lesson Taught',
			GroupInfoTab.last_lesson_taught 'Last Lesson Enter', lessonsTab.number_of_weekly_assessments 'Number of Weekly Assessments',
			lessonsTab.exit_assessments_given 'Exit Assessments Given'
     FROM 	
		 (select groupTab.*, lastLessonGivenTab.last_lesson_taught 
		  from 
			 ( select 
						CASE 
						   when groups.exited_at is NULL and subjects.name in ('Math', 'Language', 'Literacy') then 'Open'
						   when groups.exited_at is not NULL and subjects.name in ('Math', 'Language', 'Literacy') then 'Close'
						   else NULL
						End  'group_exit_status', 
						classrooms.name 'Classroom', 
						subjects.name 'Subject', 
						groups.exited_at,
						groups.id 'GroupID', 
						plans.name 'GroupName', 
						count(*) 'number_of_students',
						sum(if(group_students.group_student_tier_id < 5,1,0)) 'T1',
						sum(if(group_students.group_student_tier_id > 4,1,0)) 'DIP_T2_T3'
						
				from groups 
				inner join classrooms
				inner join group_students
				inner join subjects
				inner join plans
				inner join skills
					   
				ON classrooms.id = groups.classroom_id
				And groups.id = group_students.group_id
				And groups.id = plans.id 
				And plans.skill_id = skills.id 
				And skills.subject_id = subjects.id
				where classrooms.lea_id=1 
				group by groups.id
				order by groups.id) AS groupTab

			   LEFT JOIN

			   (select t1.group_id,max(concat(t1.week,'.',t1.weight))'last_lesson_taught'
				from 
					 (select groups.id 'group_id',lessons.id 'lesson_id', fsg_lesson_stats.stat, lessons.week,lessons.weight,  lessons.type,fsg_lesson_stats.updated_at
					  from groups 
					  inner join lessons
					  inner join fsg_lesson_stats
					  on groups.id = lessons.plan_id
					  And lessons.id = fsg_lesson_stats.lesson_id
					  ) t1
				where t1.type in ('L','R','C') 
				group by t1.group_id) AS lastLessonGivenTab 
				ON groupTab.GroupID = lastLessonGivenTab.group_id) AS GroupInfoTab 
			
	INNER JOIN

		  (select  tab1.group_id,
			min(tab1.updated_at) 'first_lesson_date',
			max(tab1.updated_at) 'last_lesson_date',
			sum(if(tab1.type = 'L',1,0)) 'L',
			sum(if(tab1.type = 'R',1,0)) 'R',
			sum(if(tab1.type = 'C',1,0)) 'C',
			sum(if(tab1.type in ('L','R','C'),1,0)) 'total_lessons',
			sum(if(tab1.type = 'W', 1,0)) 'number_of_weekly_assessments',
			if(sum(if(tab1.type = 'E',1,0))>0, 'Yes','No') 'exit_assessments_given'

			from  
			(
			 select distinct t2.lesson_id, t2.type,t2.group_id,t2.updated_at
			 from 
				(select lessons.id 'lesson_id',groups.id 'group_id', fsg_lesson_stats.stat,  lessons.type,fsg_lesson_stats.updated_at
				 from groups 
				 inner join lessons
				 inner join fsg_lesson_stats
				 on groups.id = lessons.plan_id
				 And lessons.id = fsg_lesson_stats.lesson_id
				)t2
			 )tab1
		   group by tab1.group_id) AS lessonsTab

	ON GroupInfoTab.GroupID=lessonsTab.group_id;
    
