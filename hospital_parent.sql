select * from visits;

create table hospital as
select row_number() over(order by hospital) as hospital_id,hospital 
from (select distinct hospital from visits) main;

select count(*) from hospital;
select * from hospital;

describe hospital;
alter table hospital modify column hospital_id int;
alter table hospital add primary key (hospital_id);