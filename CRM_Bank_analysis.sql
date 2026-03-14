use powerbi;
 -- Objective Questions 
--  Objective Q2 
with TotalSalaryQ4 as (select customerID, 
Surname as LastName,
 sum(estimatedSalary) as Total_salary 
  from customerinfo

where bank_doj between "2019-10-01" and "2019-12-31"
group by customerID)

select CustomerID, LastName, Total_salary as HighestSalary, 
rank() over(order by total_salary desc ) as "Rank"
 from TotalSalaryQ4
 limit 5;


-- Qbjective Q3
select round(avg(numofproducts),2)  as avg_Product from bank_churn
where hascrcard = 1;


-- Question Q5
select Round(Avg(b.creditScore),2) as Avg_creditScore_Exited_customers, Q.Avg_creditScore_remain_customers from customerinfo c 
join bank_churn b 
 on c.customerID = b.customerID
join (
 select Round(Avg(b.creditScore),2) as Avg_creditScore_remain_customers from customerinfo c 
join bank_churn b 
 on c.customerID = b.customerID
 where b.exited = 0) as Q 
 group by Q.Avg_creditScore_remain_customers;
 
  -- Question 6
  
  with Avg_salary as (select G.GenderCategory as Gender, round(Avg(c.estimatedSalary),2) as Avg_EstimatedSalary from customerinfo c 
  join gender g 
  
  on c.genderID = g.genderID 

  where g.genderID = 1 
  group by G.GenderCategory
  
  union all 
  
  
   select G.GenderCategory as Gender, round(Avg(c.estimatedSalary),2) as Avg_EstimatedSalary  from customerinfo c 
  join gender g 
  on c.genderID = g.genderID 
  
  where g.genderID = 2 

  group by G.GenderCategory),
  
 Active_accounts as ( select G.GenderCategory as Gender, count(c.customerID) as NumberOFActive_accounts from customerinfo c 
  join gender g 
  
  on c.genderID = g.genderID 
join bank_churn b 
on b.customeriD = c.customerID 
  where b.IsActiveMember = 1 and g.genderID = 1
  group by G.GenderCategory
  union all 
  
   select G.GenderCategory as Gender, count(c.customerID) as  NumberOFActive_accounts from customerinfo c 
  join gender g 
  on c.genderID = g.genderID 
  
 join bank_churn b 
on b.customeriD = c.customerID 
  where b.IsActiveMember = 1 and g.genderID = 2
  group by G.GenderCategory)

select a.gender,a.Avg_EstimatedSalary,a2.NumberOFActive_accounts from Avg_salary a join Active_accounts a2 
on a.gender = a2.gender
order by Avg_EstimatedSalary desc;



-- Question 7 

with Segments as (select c.customerID, 
b.creditScore,
(case when b.creditScore>750 then "Excellent" 
when b.creditScore between 700 and 750 then "Very Good"
when b.creditScore between 600 and 700 then "Average"
when b.creditScore<600 then "Poor"

end ) as CreditCategory,
b.Exited

from customerinfo c 
join bank_churn b 
on b.customerID = c.customerID ),
  
ExitedCustomer as ( select CreditCategory,count(customerID) as Total_LeftCustomers from segments
 where Exited = 1
 group by CreditCategory)
 
 
 select distinct e.CreditCategory,round(e.Total_LeftCustomers/(select count(customerID) as Total_customer  from bank_churn )*100,2) as Exit_rate from Segments  s 
 join ExitedCustomer e 
 on s.creditCategory=s.creditcategory
order by Exit_rate desc;

-- Question 8
select g.GeographyLocation,count(c.customerID) as NumberOF_Active_User from customerinfo c 
join geography g 
on g.geographyID = c.geographyID
join bank_churn b 
on c.customerID = b.customerID
where b.IsActiveMember=1 and b.tenure>5
group by g.GeographyLocation order by NumberOF_Active_User desc;

 --  QUestion 11
 
 select DATE_FORMAT(bank_DOJ,"%M")as MonthOfJoining, 
 Year(bank_DOJ) as YearOfJoining,  
 Quarter(Bank_DOJ) as CurrentQuarter,
 count(customerId) as NumberOfJoining 
 from customerinfo 
 group by MonthOfJoining, YearOfJoining, CurrentQuarter order by  YearOfJoining asc, CurrentQuarter asc;
 
 -- Question 15 
 with AverageINcome as (select 
 g.genderCategory,
 gh.GeographyLocation,
 round(Avg(c.estimatedSalary),2) as Average_Salary
 from customerInfo c 
 join gender g 
 on g.genderID = c.genderID
 join geography gh 
 on gh.geographyID = c.geographyID
 group by  g.genderCategory, gh.GeographyLocation)
 
 select GenderCategory,GeographyLocation,Average_Salary, 
 rank() over(partition by GenderCategory order by Average_Salary desc) as "Rank"  
 from  AverageINcome; 
 
 -- Question 16
 select 
(Case when c.age between 18 and 30 then "18-30"
 when c.age between 30 and 50 then "30-50"
 when c.age>50 then "50+"
 end
 )as Age_Group,
 round(avg(b.tenure),2) as Avg_Tenure
 from bank_churn b
 join customerinfo c 
on b.customerID = c.customerID 
 where b.exited = 1 
 group by Age_group order by  Age_group asc;
 
 
-- Question 23

SELECT *,
       (SELECT ec.ExitCategory 
        FROM exitcustomer ec
        WHERE ec.ExitID = bank_churn.Exited
       ) AS ExitCategory
FROM bank_churn;

 -- Subjective Questions 
 
 -- Question 9
 select 
 g.geographyLocation,
(case when b.balance>150000 then "high balance"
  else "Low Balance" end) as Balance_Category,
  
  (Case when b.tenure>5 then "Long Tenure"
   when b.tenure<=5 and b.tenure>2 then "Moderate Tenure"
   else "New"
   end) as Tenure_category , count(c.customerID) as CntOFCustomers 
 from CustomerInfo c
 join geography g 
 on c.geographyID = g.geographyID
 join bank_churn b 
 on b.customerID = c.customerID 
 group by g.geographyLocation,  Balance_Category, Tenure_category order by g.geographyLocation