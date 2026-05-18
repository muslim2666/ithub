create or replace function Get_Discip_Group_Count(p_Group_Name text)
returns smallint
language plpgsql
as $$
	declare p_G_Count int ;
	begin
		p_G_Count := count(distinct dep_discipl_id) from workload
		inner join study_grpoup on
			id_study_grpoup = study_grpoup_id
			where 
				name_st_grp = p_Group_Name;
		return p_G_Count;
	end;
$$;

select Get_Discip_Group_Count('2П1.22');
select Get_Discip_Group_Count('2П2.22');
select Get_Discip_Group_Count('2P1.22');
select Get_Discip_Group_Count('3БК1.21');
select Get_Discip_Group_Count('Тест');

create or replace function Get_Student_Data (p_ID_Card text)
returns text
language plpgsql
as $$
	declare p_Student text;
	begin
		if (select 
				count(*) 
			from identity_card
				where 
		   			idcard_number = p_ID_Card) = 0 then
			p_Student := 'Нет данных';
		else
			if (select 
					status_card_name
			   from identity_card
			   		inner join card_status on
			   			id_card_status = card_status_id
			   		where 
			   			idcard_number = p_ID_Card) <> 'Активна' then
				p_Student := 'В доступе отказано!';
			else
				p_Student := 'ФИО: '||u_surname||' '||u_name||' '||u_patronymic||', фото: '||student_photo||', группа: '||name_st_grp 
					from identity_card
						inner join student on
							login_student_card = login_student
						inner join user_profile on
							login_student = up_login
						inner join distrib_grps on
							login_student = student_login
						inner join study_grpoup on
							id_study_grpoup = study_grpoup_id
						where
							idcard_number = p_ID_Card;
			end if;
		end if;
		return p_Student;
	end;
$$;
select Get_Student_Data('ID_0000000001');
select Get_Student_Data('ID_0000000002');
select Get_Student_Data('ID_0000000004');
select Get_Student_Data('ID_0000000009');
select Get_Student_Data('ID_0000000011');

create or replace function Get_Discipline_Skill_List(p_Skill text, p_Discipline text)
returns table (PFXDisc text, NMDisc text, PRFXSkll text, NMSkll text)
language plpgsql
as $$
	begin
		return query select 
						prefix_discipline::text, 
						name_discipline::text, 
						prefix::text, 
						skills_name::text 
					from discipline
						inner join dep_discipl on id_discipline = discipline_id
						inner join discip_skills on id_dep_discipl = dep_discipl_id
						inner join skills on id_skills = skills_id
						where
							prefix||' '||skills_name like '%'||p_Skill||'%' and
							prefix_discipline||' '||name_discipline like '%'||p_Discipline||'%';
	end;
$$;
select * from Get_Discipline_Skill_List('У.1','Основы');
select * from Get_Discipline_Skill_List('','Python');
select * from Get_Discipline_Skill_List('З.2','');

grant execute on function Get_Discip_Group_Count to rl_architect;
grant execute on function Get_Discipline_Skill_List to rl_teacher;
grant execute on function Get_Discipline_Skill_List to rl_student;
grant execute on function Get_Discip_Group_Count to rl_managersd;
grant execute on function Get_Student_Data to rl_administrator;