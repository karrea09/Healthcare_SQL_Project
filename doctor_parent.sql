select * from visits;

create table doctor 
select row_number() over(order by doctor) as doctor_id,doctor
from (select distinct doctor from visits) as main;


select * from doctor;

describe doctor;

alter table doctor modify column doctor_id int;

alter table doctor add primary key (doctor_id);
