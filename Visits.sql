create database healthcare;
use healthcare;

create table patient_details (Name_ char(50) default "No Name",
							  Age tinyint check (Age>0 and Age<100),
                              Gender char(6) check (Gender in ("Male","Female")),
                              Blood_Type char(5) default "B+" ,
                              Medical_Condition char(20) default "Not mentioned",
                              Date_of_Admission date default "1900-01-01",
                              Doctor char(45) default "Not Mentioned",
                              Hospital varchar(60) default "Not Mentioned",
                              Insurance_Provider varchar(20) check (Insurance_Provider in ("Aetna","Blue Cross","Cigna","Medicare","UnitedHealthcare")),
                              Billing_Amount decimal(20,12) default 0,
                              Room_Number smallint check(Room_Number>99 and Room_Number<501),
                              Admission_Type varchar(20) check (Admission_Type in("Emergency","Elective" ,"Urgent")),
                              Discharge_Date date default "2000-01-01" ,
                              Medication varchar(15) default "Not Mentioned",
                              Test_Results varchar(15) default "Not Mentioned");
                              
                              
select * from patient_details;

show tables;




select count(*) from patient_details;
select count(distinct Hospital) from patient_details;

rename table patient_details to visits;


select * from visits;


# 1) patient_id column

alter table visits add column patient_id int;
set sql_safe_updates = 0;
update visits as v set v.patient_id = (select p.patient_id from patient as p where v.name_ = p.name_ and
																					v.age = p.age and
                                                                                    v.gender = p.gender and
                                                                                    v.blood_type = p.blood_type limit 1);
                                                                                    
                                                                                    
select count(patient_id) from visits where patient_id is not null;
alter table visits drop column name_,drop column age,drop column gender,drop column blood_type;


# visit_id unique column
alter table visits add column visit_id int auto_increment primary key;



# 2) doctor_id column

alter table visits add column doctor_id int;



update visits as v set v.doctor_id = (select d.doctor_id from doctor as d where v.doctor = d.doctor limit 1);
																			 
select count(doctor_id) from visits where doctor_id is not null;

alter table visits drop column doctor;

# 3) hospital column

alter table visits add column hospital_id int;

update visits as v set v.hospital_id = (select h.hospital_id from hospital as h where v.hospital = h.hospital limit 1);

select count(distinct hospital_id) from visits where hospital_id is not null;

alter table visits drop column hospital;


# 4) Add foreign keys of patient,doctor, and hospital

describe visits;

alter table visits add foreign key (patient_id) references patient (patient_id) on update cascade on delete cascade;
alter table visits add foreign key (doctor_id) references doctor (doctor_id) on update cascade on delete cascade;
alter table visits add foreign key (hospital_id) references hospital (hospital_id) on update cascade on delete cascade;


# Questions
#1) How many total visits are there?
select * from visits;
select count(visit_id) as total_visits from visits;

#2) what is the total revenue (sum of charges)?

select sum(Billing_Amount) as total_revenue from visits where Billing_Amount>0;
# --> 1.4Billion dollars

#3) which hosital has the most visits?
select hospital.hospital as hospital_name,count(visits.visit_id) as most_visits from visits  join hospital on visits.hospital_id = hospital.hospital_id group by hospital.hospital order by most_visits desc limit 1;

#4) which doctor treated the most patients?
select doctor.doctor as doctor_name,count(visits.patient_id) as number_of_patients from visits join doctor on visits.doctor_id = doctor.doctor_id group by doctor.doctor order by number_of_patients desc limit 1;

#5) Gender-wise count of patients?
select patient.gender,count(visits.patient_id) as number_of_patients from visits join patient on visits.patient_id = patient.patient_id group by gender order by number_of_patients desc;

#6) Average patient Age per hospital?
select hospital.hospital as hospital_name,avg(patient.age) as Average_age from visits join hospital on visits.hospital_id = hospital.hospital_id join patient on visits.patient_id = patient.patient_id group by hospital.hospital;

#7) Top5 most expensive visits (with patient & doctor details)?
select doctor.doctor as doctor_name,patient.name_ as patient_name,visits.Billing_Amount  from visits join patient on visits.patient_id = patient.patient_id join doctor on visits.doctor_id = doctor.doctor_id where visits.Billing_Amount>0 order by Billing_Amount desc limit 5;



#Intermediate 

#8) which hospital has the highest average billing amount per visit?
select hospital.hospital,avg(visits.Billing_Amount) as Average_Billing_amount from visits join hospital on hospital.hospital_id = visits.hospital_id group by hospital.hospital order by Average_Billing_amount desc limit 1;

#9) Number of visits per month?
select month(Date_of_Admission) as month_,count(visit_id) as number_of_visits from visits group by month_ order by month_;

#10) Top 3 doctors by total revenue generated?
select doctor.doctor,sum(visits.Billing_Amount) as total_revenue from visits join doctor on visits.doctor_id = doctor.doctor_id group by doctor.doctor order by total_revenue desc limit 3;

#11) Count of patients by blood_type?
select patient.Blood_type,count(patient.patient_id) as number_of_patients from visits join patient on patient.patient_id = visits.patient_id group by patient.blood_type;

#12) Average billing amount per gender?
select gender,avg(Billing_Amount) as Average_billing_amount from visits join patient on visits.patient_id = patient.patient_id group by gender;

#13) List patients who visited more than 3 times?
select patient.name_,count(visits.visit_id) as number_of_visits from visits join patient on patient.patient_id = visits.patient_id group by patient.name_ having number_of_visits>3; 

#14) Hospital-wise gender ratio of patients?
select hospital.hospital,patient.gender,count(visits.patient_id) as number_of_patients from visits join hospital on hospital.hospital_id = visits.hospital_id join patient on patient.patient_id = visits.patient_id group by hospital.hospital,patient.gender;

#15) Doctor-wise patient count and average billing amount?
select doctor.doctor,count(visits.patient_id) as number_of_patients,avg(Billing_Amount) as average_billing_amount from visits join doctor on doctor.doctor_id = visits.doctor_id group by doctor.doctor;


# Bussiness insights

#16) which hospital has the highest patient retention rate?

WITH unique_visits AS (
    SELECT hospital_id, patient_id, COUNT(*) AS visits
    FROM visits
    GROUP BY hospital_id, patient_id
),
hospital_stats AS (
    SELECT 
        hospital_id,
        COUNT(*) AS total_unique_patients,
        SUM(CASE WHEN visits > 1 THEN 1 ELSE 0 END) AS returning_patients
    FROM unique_visits
    GROUP BY hospital_id
)
SELECT 
    h.hospital,
    hs.total_unique_patients,
    hs.returning_patients,
    ROUND(returning_patients * 100.0 / total_unique_patients, 2) AS retention_rate_percent
FROM hospital_stats hs
JOIN hospital h ON hs.hospital_id = h.hospital_id
ORDER BY retention_rate_percent DESC
LIMIT 1;

#17) Hospital-wise revenue vs. number of visits — is there a correlation?
select hospital,sum(Billing_Amount) as total_revenue,count(visit_id) as number_of_visits from visits join hospital on visits.hospital_id = hospital.hospital_id group by hospital;

#18) Which hospital has the highest proportion of high-paying patients (billing > threshold)?
select hospital.hospital,count(case when Billing_Amount>(select avg(Billing_Amount) from visits) then 1 end)*1.0 / count(*) as high_paying_proportionate from visits join hospital on hospital.hospital_id = visits.hospital_id group by hospital.hospital order by high_paying_proportionate desc limit 1;

#19) Which doctors see the most unique patients?
select doctor.doctor,count(distinct patient_id) as unique_patients from visits join doctor on visits.doctor_id = doctor.doctor_id group by doctor.doctor order by unique_patients desc limit 1;

#20) which doctor treats the most repeated patients?
SELECT d.doctor,
       COUNT(*) AS repeated_patients
FROM (
    SELECT doctor_id, patient_id
    FROM visits
    GROUP BY doctor_id, patient_id
    HAVING COUNT(*) > 1
) AS repeated
JOIN doctor d ON repeated.doctor_id = d.doctor_id
GROUP BY d.doctor
ORDER BY repeated_patients DESC
LIMIT 1;

#21) Monthly revenue trends - are there peak seasons?
select * from visits;
select monthname(Date_of_Admission) as month_,sum(Billing_Amount) as revenue from visits group by monthname(Date_of_Admission) order by revenue desc;


#22) which combinatin of hospital and doctor generates highest revenue?
select hospital.hospital,doctor.doctor,sum(visits.Billing_Amount) as revenue from visits join doctor on visits.doctor_id = doctor.doctor_id join hospital on hospital.hospital_id = visits.hospital_id group by hospital.hospital,doctor.doctor order by revenue desc limit 1;

#23) what percentage of visits have negative or zero billing - is revenue leakage happening?

select count(*)*100/(select count(*) from visits) as negative_or_zero_billing_percentage from visits where Billing_Amount<=0;

#24) Which hospitals could benefit from recruiting more high-performing doctors?
select hospital.hospital,count(distinct doctor_id) as num_doctors,avg(visits.Billing_Amount) as lower_revenue from visits join hospital on hospital.hospital_id = visits.hospital_id where visits.Billing_Amount>0 group by hospital.hospital order by lower_revenue;

#25) Are there hospitals where patients frequently switch doctors?
select hospital.hospital,patient_id,count(distinct doctor_id) as num_doctors from visits join hospital on hospital.hospital_id = visits.hospital_id group by hospital.hospital,patient_id having num_doctors>1;




