select *
from new_loan
limit 100;

alter table new_loan 
add column con_issue_date Date;

update new_loan
set con_issue_date =
case
	when issue_date like '__/__/____' 
        then TO_DATE(issue_date, 'DD/MM/YYYY')
    when issue_date like '__-__-____' 
        THEN TO_DATE(issue_date, 'DD/MM/YYYY')
    when issue_date like'____/__/__' 
        then TO_DATE(issue_date, 'YYYY/MM/DD')
    else null
end;

alter table new_loan 
drop column issue_date;

alter table new_loan 
rename con_issue_date to issue_date;



alter table new_loan 
add column con_last_credit_pull_date date;

update new_loan
set con_last_credit_pull_date =
case
	when last_credit_pull_date like '__/__/____' 
        then TO_DATE(last_credit_pull_date, 'DD/MM/YYYY')
    when last_credit_pull_date like '__-__-____' 
        then TO_DATE(last_credit_pull_date, 'DD/MM/YYYY')
    when last_credit_pull_date like'____/__/__' 
        then TO_DATE(last_credit_pull_date, 'YYYY/MM/DD')
    else null
end;

alter table new_loan 
drop column last_credit_pull_date;

alter table new_loan 
rename con_last_credit_pull_date to last_credit_pull_date;



alter table new_loan 
add column con_next_payment_date date;

update new_loan
set con_next_payment_date =
case
	when next_payment_date like '__/__/____' 
        then TO_DATE(next_payment_date, 'DD/MM/YYYY')
    when next_payment_date like '__-__-____' 
        then TO_DATE(next_payment_date, 'DD/MM/YYYY')
    when next_payment_date like'____/__/__' 
        then TO_DATE(next_payment_date, 'YYYY/MM/DD')
    else null
end;

alter table new_loan 
drop column next_payment_date;

alter table new_loan 
rename con_next_payment_date to next_payment_date;



alter table new_loan 
add column con_last_payment_date date;

update new_loan
set con_last_payment_date =
case
	when last_payment_date like '__/__/____' 
        then TO_DATE(last_payment_date, 'DD/MM/YYYY')
    when last_payment_date like '__-__-____' 
        then TO_DATE(last_payment_date, 'DD/MM/YYYY')
    when last_payment_date like'____/__/__' 
        then TO_DATE(last_payment_date, 'YYYY/MM/DD')
    else null
end;

alter table new_loan 
drop column last_payment_date;

alter table new_loan 
rename con_last_payment_date to last_payment_date;


-- calculating the total application received
select count(id) as total_loan_application
from new_loan;

-- calculating mtd_total_loan_application
select count(*) AS mtd_applications
from new_loan
where issue_date >= DATE_TRUNC('month', (select max(issue_date) from new_loan))
  and issue_date <= (select max(issue_date) from new_loan);
  
-- calculating pmtd_total_loan_application
with max_date as (
    select max(issue_date) as max_dt
    from new_loan
)
select count(*) as pmtd_applications
from new_loan, max_date
where issue_date >= DATE_TRUNC('month', max_dt - INTERVAL '1 month')
  and issue_date < DATE_TRUNC('month', max_dt)
  and extract(day from issue_date) 
      <= extract(day from max_dt);

-- calculating mom total_loan_applications
with monthly_data as (
    select
        DATE_TRUNC('month', issue_date) as month,
        count(*) as total_loans
    from new_loan
    group by month
)
select
    month,
    total_loans,
    lag(total_loans) over (order by month) as previous_month,
    ROUND(
        (total_loans - lag(total_loans) over (order by month)) * 100.0
        / lag(total_loans) over (order by month), 2
    ) as mom_growth_percent
from monthly_data;



--calculating the total funded amount
select sum(loan_amount) as total_loan_amount
from new_loan

-- calculating mtd_total_amount_funded
select sum(loan_amount) AS mtd_total_amount_funded
from new_loan
where issue_date >= DATE_TRUNC('month', (select max(issue_date) from new_loan))
  and issue_date <= (select max(issue_date) from new_loan);
  
-- calculating pmtd_total_amount_recieved
with max_date as (
    select max(issue_date) as max_dt
    from new_loan
)
select sum(loan_amount) as pmtd_total_amount_funded
from new_loan, max_date
where issue_date >= DATE_TRUNC('month', max_dt - INTERVAL '1 month')
  and issue_date < DATE_TRUNC('month', max_dt)
  and extract(day from issue_date) 
      <= extract(day from max_dt);

-- calculating mom_total_amount_recieved
with monthly_data as (
    select
        DATE_TRUNC('month', issue_date) as  month,
        sum(loan_amount) as total_loan_amount
    from new_loan
    group by month
)
select
    month,
    total_loan_amount,
    lag(total_loan_amount) over (order by month) as previous_month,
    ROUND(
        (total_loan_amount - lag(total_loan_amount) over (order by month)) * 100.0
        / lag(total_loan_amount) over (order by month), 2
    ) as mom_total_amount_funded_growth_percent
from monthly_data;




--calculating the total amount recieved
select sum(total_payment) as total_amount_recieved
from new_loan

-- calculating mtd total amount recieved
select sum(total_payment) AS mtd_total_amount_recieved
from new_loan
where issue_date >= DATE_TRUNC('month', (select max(issue_date) from new_loan))
  and issue_date <= (select max(issue_date) from new_loan);
  
-- calculating pmtd total amount recieved
with max_date as (
    select max(issue_date) as max_dt
    from new_loan
)
select sum(total_payment) as pmtd_total_amount_recieved
from new_loan, max_date
where issue_date >= DATE_TRUNC('month', max_dt - INTERVAL '1 month')
  and issue_date < DATE_TRUNC('month', max_dt)
  and extract(day from issue_date) 
      <= extract(day from max_dt);

-- calculating mom total amount recieved
with monthly_data as (
    select
        DATE_TRUNC('month', issue_date) as  month,
        sum(total_payment) as total_amount_recieved
    from new_loan
    group by month
)
select
    month,
    total_amount_recieved,
    lag(total_amount_recieved) over (order by month) as previous_month,
    ROUND(
        (total_amount_recieved - lag(total_amount_recieved) over (order by month)) * 100.0
        / lag(total_amount_recieved) over (order by month), 2
    ) as mom_total_amount_recieved_growth_percent
from monthly_data;




--calculating the avg interest rate in %
select round(avg(int_rate)*100,2) as avg_interest_rate
from new_loan

--calculating mtd avg int rate
select round(avg(int_rate)*100,2) AS mtd_avg_init_rate
from new_loan
where issue_date >= DATE_TRUNC('month', (select max(issue_date) from new_loan))
  and issue_date <= (select max(issue_date) from new_loan);
  
-- calculating pmtd avg int rate
with max_date as (
    select max(issue_date) as max_dt
    from new_loan
)
select round(avg(int_rate)*100,2) AS pmtd_avg_init_rate
from new_loan, max_date
where issue_date >= DATE_TRUNC('month', max_dt - INTERVAL '1 month')
  and issue_date < DATE_TRUNC('month', max_dt)
  and extract(day from issue_date) 
      <= extract(day from max_dt);

-- calculating mom avg init rate and change in %
with monthly_data as (
    select
        DATE_TRUNC('month', issue_date) as  month,
        round(avg(int_rate)*100,2) as avg_per_month_int_rate
    from new_loan
    group by month
)
select
    month,
    avg_per_month_int_rate,
    lag(avg_per_month_int_rate) over (order by month) as previous_month_avg_int_rate,
    ROUND(
        (avg_per_month_int_rate - lag(avg_per_month_int_rate) over (order by month)) * 100.0
        / lag(avg_per_month_int_rate) over (order by month), 2
    ) as mom_change_in_avg_interest_rate_percent
from monthly_data;




--calculating the avg debt to income ratio(dti)
select round(avg(dti)*100,2) as avg_dti
from new_loan

--calculating mtd the avg debt to income ratio(dti)
select round(avg(dti)*100,2) AS mtd_avg_dti
from new_loan
where issue_date >= DATE_TRUNC('month', (select max(issue_date) from new_loan))
  and issue_date <= (select max(issue_date) from new_loan);
  
-- calculating pmtd the avg debt to income ratio(dti)
with max_date as (
    select max(issue_date) as max_dt
    from new_loan
)
select round(avg(dti)*100,2) AS pmtd_dti
from new_loan, max_date
where issue_date >= DATE_TRUNC('month', max_dt - INTERVAL '1 month')
  and issue_date < DATE_TRUNC('month', max_dt)
  and extract(day from issue_date) 
      <= extract(day from max_dt);

-- calculating mom the avg debt to income ratio(dti) and change in %
with monthly_data as (
    select
        DATE_TRUNC('month', issue_date) as  month,
        round(avg(dti)*100,2) as avg_dti_per_month
    from new_loan
    group by month
)
select
    month,
    avg_dti_per_month,
    lag( avg_dti_per_month) over (order by month) as previous_month_avg_dti,
    ROUND(
        ( avg_dti_per_month - lag( avg_dti_per_month) over (order by month)) * 100.0
        / lag( avg_dti_per_month) over (order by month), 2
    ) as mom_change_in_avg_dti_percent
from monthly_data;




--calculating the good loan application percent
select count(case when loan_status='Fully Paid' or loan_status='Current' then id end)*100/
count(id) as good_loan_percentage
from new_loan;
--calculating the total good loan application 
select count(id) as total_good_loan
from new_loan
where loan_status='Fully Paid' or loan_status='Current';
--calculating the total good loan amount 
select sum(loan_amount) as total_good_loan_amount_funded
from new_loan
where loan_status='Fully Paid' or loan_status='Current';
--calculating the total good loan amount recieved
select sum(total_payment) as total_good_loan_amount_recieved
from new_loan
where loan_status='Fully Paid' or loan_status='Current';




--calculating the bad loan application percent
select count(case when loan_status='Charged Off' then id end)*100/
count(id) as bad_loan_percentage
from new_loan;
--calculating the total bad loan application 
select count(id) as total_bad_loan
from new_loan
where loan_status='Charged Off';
--calculating the total bad loan amount 
select sum(loan_amount) as total_bad_loan_amount_funded
from new_loan
where loan_status='Charged Off';
--calculating the total bad loan amount recieved
select sum(total_payment) as total_bad_loan_amount_recieved
from new_loan
where loan_status='Charged Off';


--calculating the loan_count,total_funded_amount,total_amount_recieved,interest_rate,dti on basis of the loan_status
select
	loan_status,
	count(id) as loan_count,
	sum(loan_amount) as Total_funded_amount,
	sum(total_payment) as Total_recieved_amount,
	avg(int_rate*100) as Interest_rate,
	avg(dti*100) as Avg_dti
from new_loan
group by loan_status



--calculating mtd_total_amount_recieved,mtd_Total_funded_amount on basis of the loan_status
select loan_status,sum(loan_amount) AS mtd_total_amount_funded ,
	sum(total_payment) AS mtd_total_amount_recieved
from new_loan
where issue_date >= DATE_TRUNC('month', (select max(issue_date) from new_loan))
  and issue_date <= (select max(issue_date) from new_loan)
group by loan_status
	
	

--calculating mmonthly total_loan_applications,total_funded_amount,total_amount_recieved,interest_rate
select	
	extract (month from issue_date) as  month,
	TO_CHAR(issue_date, 'Month') AS month_name,
	count(id) as monthly_total_loan_applications,
	sum(loan_amount) as monthly_total_funded_amount,
	sum(total_payment) as monthly_total_recieved_amount,
	round(avg(int_rate*100),2) as monthly_avg_interest_rate
from new_loan
group by month ,month_name
order by month


--bank loan report | overview-state
select 
	address_state as State,
	count(id) as monthly_total_loan_applications,
	sum(loan_amount) as monthly_total_funded_amount,
	sum(total_payment) as monthly_total_recieved_amount
from new_loan
group by address_state
order by address_state



--bank loan report | overview-state
select 
	term as Term ,
	count(id) as monthly_total_loan_applications,
	sum(loan_amount) as monthly_total_funded_amount,
	sum(total_payment) as monthly_total_recieved_amount
from new_loan
group by term
order by term


--bank loan report | overview-employee length
select 
	emp_length as employee_Length ,
	count(id) as monthly_total_loan_applications,
	sum(loan_amount) as monthly_total_funded_amount,
	sum(total_payment) as monthly_total_recieved_amount
from new_loan
group by employee_Length
order by employee_Length


--bank loan report | overview-purpose
select 
	purpose as purpose ,
	count(id) as monthly_total_loan_applications,
	sum(loan_amount) as monthly_total_funded_amount,
	sum(total_payment) as monthly_total_recieved_amount
from new_loan
group by purpose
order by purpose


--bank loan report | overview-home ownership
select 
	home_ownership as Home_Ownership ,
	count(id) as monthly_total_loan_applications,
	sum(loan_amount) as monthly_total_funded_amount,
	sum(total_payment) as monthly_total_recieved_amount
from new_loan
group by home_ownership
order by home_ownership






