create database prison;
use prison;
select * from age_group;

alter table age_group
add column Total int;
update age_group
set Total=age_16_18+age_18_30+age_30_50+age_50_above;

alter table sentence_period
add column Total int;
update sentence_period
set Total=age_16_18_years+age_18_30_years+age_30_50_years+age_50_above;

alter table education
add column Total int;
update education
set Total=convicts+under_trial+detenues+others;

describe age_group;
select distinct state_name from age_group;
select distinct category from age_group;
select distinct type from age_group;


 select * from crime_inmates_convicted;
  select distinct `CRIME HEAD` from crime_inmates_convicted;
  update crime_inmates_convicted
  set `CRIME HEAD`=replace(`CRIME HEAD`,'Robbery','Thefts');
  
  select * from crime_inmates_under_trial;
  select distinct `CRIME HEAD` from crime_inmates_under_trial;
  update crime_inmates_convicted
  set `CRIME HEAD`=
  case 
	  when `CRIME HEAD`='Robbery' then 'Thefts'
  end;



-- / Q1. Find no of Prisoner Yearly between 2001-2013 and increment in percentage.

select year,Total_No_of_Prisioner,`Percentage Increament in prisioner yearly`
from (select year,sum(Total) as 'Total_No_of_Prisioner' ,
lag(sum(Total)) over(),
round((sum(Total)-lag(sum(Total)) over())/lag(sum(Total)) over()*100,2) as 'Percentage Increament in prisioner yearly'
from age_group
group by 1)b;

-- / Q2. Find yearly Convicts, Detenus and Under Trials Prisoner, show by making Three different Columns.
select Year,
sum(case when type='Convicts' then Total else 0 end) as 'Convicts Prisioner',
sum(case when type='Detenus' then Total else 0 end) as 'Detenus Prisioner ',
sum(case when type='Under Trials' then Total else 0 end)'Under Trials Prisioner'
 from age_group
 group by 1;
 
 -- / Q3. Find yearly Female and Male Prisoner and Their Percentage.
 
select *,
concat(round((Female_Prisioner/(Female_Prisioner+Male_Prisioner))*100,2)," %") "Percentage_of_Female_Prisioner",
concat(round((Male_Prisioner/(Female_Prisioner+Male_Prisioner))*100,2)," %") "Percentage_of_Male_Prisioner" from
(
select Year,
sum(case when gender='Female' then Total else 0 end) as 'Female_Prisioner',
sum(case when gender='Male' then Total else 0 end) as 'Male_Prisioner'
 from age_group
 group by 1
 )t;
 
 
 -- / Q4.  No of Foreign Prisoner in India Yearly.
  select * from age_group;
  select year,sum(Total) as "Foreign_prisioner_in_India" from age_group
  where category='Foreigners'
  group by 1;
  
 -- / Q5.  Total No of Inmates try escaping from prison and their percentage with total Number  
  with Prisoner as  (select state_name,year,sum(Total) as 'Total_prisoner'  from age_group
  group by 1,2),
   Escapee as (select state_name,year,sum(total) as 'No_of_inmates_esacape' from inmates_escapee
  group by 1,2)  
  select *,  concat(round((No_of_inmates_esacape/(Total_prisoner+No_of_inmates_esacape))*100,2)," %") as "Percentage_of_Inmate_Escape" 
   from
  (select A.year,sum(A.Total_prisoner) as "Total_prisoner",
  sum(B.No_of_inmates_esacape) as "No_of_inmates_esacape" from Prisoner A 
  join Escapee B on A.state_name=B.state_name
  and A.year=B.year
  group by 1)b;
  -- /prisoners escapee
with a as(select year,sum(total) as a1 from age_group group by year),
b as(select year,sum(total) as b1 from inmates_escapee group by year)
select a.year,a1,b1,b1*100/(a1+b1) from a join b using(year) group by  1;

  
  -- / Q6.  States from which inmates mostly try escaping and gives ranking order by total.
   select *,
  round((Number_Escape/sum(Number_Escape) over())*100,2) as 'Percentage Of Total Escape'
   from
  (select  dense_rank() over(order by sum(total) desc) as "Rank_no",
  state_name,sum(total) as 'Number_Escape'
  from inmates_escapee
  group by 2)t;
  
 -- / Q7. Total Number of Punishment received categorized by sentence period.
  select * from sentence_period;
  select sentence_period,sum(Total) as 'Total'
  from sentence_period
  group by 1
  order by 2 desc;
  
 -- / Q8. States from which inmates mostly received Capital Punishment and find their Percentage of total.
  select *,
  round((No_of_capital_punishment/sum(No_of_capital_punishment) over())*100,2) as 'Percentage Of Capital Punishment'
   from
  (select  dense_rank() over(order by sum(total) desc) as "Rank_no",
  state_name,sum(total) as 'No_of_capital_punishment'
  from sentence_period
  where sentence_period='Capital Punishment'
  group by 2)t;
  
 -- / Q9.  Percentage of People got Capital Punishment, Life Imprisonment combined.
    with Prisoner as  (select year,sum(Total) as 'Total_prisoner'  from age_group
  group by 1),
  sentence as (select year,sum(Total) as 'Total_received_Capital_life_imprisonment' from sentence_period
  where sentence_period='Capital Punishment' or sentence_period='Life Imprisonment'
  group by 1)
  select *,
  round(Total_received_Capital_life_imprisonment/(Total_prisoner+Total_received_Capital_life_imprisonment)*100,2)
			as 'Percentage in Punishment'
  from Prisoner
  join sentence using(Year);
  
 -- / Q10. Prisoners Education categorized by female and male in Percentage.
  select * from education;
  select education,
  round((Female_Prisioner/sum(Female_Prisioner) over())*100,2) as 'Percentage of Female ',
  round((Male_prisioner/sum(Male_prisioner) over())*100,2) as 'Percentage of Male '
  from
  (select education,
  sum(case when gender='Female' then Total else 0 end ) as 'Female_Prisioner' ,
  sum(case when gender='male' then Total else 0 end ) as 'Male_prisioner'
  from education
  group by 1)b;
  
-- / Q11.  Find Total and Percentage of convicted Prisoner categorized by their crime.
 select * from crime_inmates_convicted;

  select * from crime_inmates_under_trial;
  select *, round((No_of_Prisioner/sum(No_of_Prisioner) over())*100,2) as 'Percentage Of Prisioner'
  from (select `CRIME HEAD` ,sum(`Grand Total`) as 'No_of_Prisioner'
  from crime_inmates_convicted
  group by 1)b;
  
-- / Q12.  Find Total and Percentage of total (convicted + undertrial) Prisoner categorized by their crime.
  select *, round((No_of_Prisioner/sum(No_of_Prisioner) over())*100,2) as 'Percentage Of Prisioner'
  from (select `CRIME HEAD`,sum(a.`Grand Total`+b.`Grand Total`) as 'No_of_Prisioner'
  from crime_inmates_convicted a
  join crime_inmates_under_trial b using(`STATE/UT`,YEAR,`CRIME HEAD`)
  group by 1)b;
  
-- / Q13.  Find Years most dangerous crime and that Years most number of prisoner according to crime head.
  with Crime as (select year,`CRIME HEAD`, sum(a.`Grand Total`+b.`Grand Total`) as 'No_of_Prisioner'
  from crime_inmates_convicted a
  join crime_inmates_under_trial b using(`STATE/UT`,YEAR,`CRIME HEAD`)
  group by 1,2)
  select * from crime a
  where No_of_Prisioner  in
  (select max(No_of_Prisioner) from crime b where b.year=a.year) ;
  
-- / Q14. Find state's most dangerous crime and that Years most number of prisoner according to crime head.
  with Crime as (select `STATE/UT`,`CRIME HEAD`, sum(a.`Grand Total`+b.`Grand Total`) as 'No_of_Prisioner'
  from crime_inmates_convicted a
  join crime_inmates_under_trial b using(`STATE/UT`,YEAR,`CRIME HEAD`)
  group by 1,2)
  select * from crime a
  where No_of_Prisioner  in
  (select max(No_of_Prisioner) from crime b where b.`STATE/UT`=a.`STATE/UT`);
  with x as(select distinct `STATE/UT`,`CRIME HEAD`,sum(`Grand Total`)over(partition by `STATE/UT`order by `CRIME HEAD`)
 as a from crime_inmates_under_trial) 
select * from x where a in(select max(a)over(partition by `STATE/UT` ) from x);
 use prison;
  