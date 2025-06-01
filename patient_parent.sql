use healthcare;
select * from visits;
describe visits;


select row_number() over(order by name_) as patient_id,
	   name_,
       age,
       gender,
       blood_type 
	   from (select distinct name_,age,gender,blood_type from visits) as main;


create table patient (patient_id int primary key,
					  name_ char(50),
                      age tinyint,
                      gender char(6),
                      Blood_Type char(5));

       
       
select * from patient;

insert into patient (patient_id,name_,age,gender,blood_type) 
	        select row_number() over(order by name_) as patient_id,
                   name_,
                   age,
                   gender,
                   blood_type
                   from (select distinct name_,age,gender,blood_type from visits) as main;





describe patient;

