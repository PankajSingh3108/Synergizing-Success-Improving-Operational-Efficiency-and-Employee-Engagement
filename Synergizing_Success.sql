create database Synergizing_Success
use Synergizing_Success
select * from Business_Operations_Dataset

--Problem Statement:
--Enhancing Operational Efficiency and Growth Strategies in a Multi-Departmental
--Business

--Context:
--? Business operations involve a complex interaction between departments,
--products, suppliers, and employees, where each element contributes to
--overall performance. Challenges such as managing inventory levels,
--optimizing employee performance, maintaining customer satisfaction, and
--navigating supply chain dependencies require constant data analysis for
--informed decision-making. Effective alignment between leadership,
--employees, and market trends is also crucial for future planning and
--sustainable growth.

--Problem:
--? The company is experiencing several operational inefficiencies:
--? Employee Performance & Retention Challenges: Inconsistent employee
--performance and high turnover rates negatively impact productivity. The
--company needs to evaluate whether training programs, salary, and tenure
--influence employee retention and performance.
--? Product Sales & Customer Satisfaction Issues: Some products have low
--customer feedback scores despite high sales, indicating potential quality or
--support issues. Additionally, low sales for certain products may suggest
--gaps in marketing strategies or misalignment with market demands.
--? Supply Chain & Inventory Management Issues: Supply chain risks are
--posed by low inventory levels approaching reorder points, potentially
--leading to missed sales opportunities if not addressed promptly.

--? Technology Usage & Future Planning Concerns: The company is
--underutilizing technology in several departments, leading to inefficiencies.
--Weak market research and unclear company direction could affect
--long-term growth and competitiveness.

--Analysis Questions:
--? Employee Performance:

--? Which department had the highest average profit margin among its
--products?

select top 1 department, avg(profit_margin) as avg_profit_margin  from Business_Operations_Dataset
group by department
order by department desc

--Which employee in the IT department had the highest performance score,
--and what was their role?

select top 1 employee_name, employee_role, employee_performance_score from Business_Operations_Dataset
where department = 'IT'
order by employee_performance_score desc

select * from Business_Operations_Dataset

--Product Sales & Customer Satisfaction:
-- Identify the product with the highest revenue generated in the HR
--department.

select top 1 product_name, revenue, department from Business_Operations_Dataset
where department = 'HR'
order by revenue desc

--What is the average customer feedback score for products in the
--Accessories category, and which product received the highest score?

select avg(customer_feedback_score) as avg_score from Business_Operations_Dataset
where category = 'Accessories' 
select top 1 product_name from Business_Operations_Dataset
order by customer_feedback_score desc

--? Which supplier had the highest total inventory level across all
--departments
select top 1 supplier_id , inventory_level from Business_Operations_Dataset
order by supplier_id desc

--? Which product in the Gadgets category had the lowest inventory level?
select top 1 supplier_id , inventory_level from Business_Operations_Dataset
where category = 'Gadgets'
order by supplier_id asc

-- Employee Training & Sales:
--? How many employees in the Sales department have completed training
--programs, and what percentage does this represent of the total employees
--in that department

select * from Business_Operations_Dataset
select count(employee_id) as total_emp from Business_Operations_Dataset
where department = 'Sales' and training_program_completed = '1'

SELECT
    COUNT(CASE WHEN training_program_completed = 1 THEN 1 END) AS completed_training,
    COUNT(*) AS total_employees,
    ROUND(
        COUNT(CASE WHEN training_program_completed = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS completion_percentage
FROM
    Business_Operations_Dataset

WHERE
    department = 'Sales';

--What is the total number of units sold for all products in the Marketing
--department, and which product contributed the most to this total?

 select * from Business_Operations_Dataset
 select sum(units_sold) as total_unit_sold from Business_Operations_Dataset
 where department = 'Marketing'

 select top 1 product_name from Business_Operations_Dataset
 order by units_sold desc
 
-- ? Write a query to rank employees in each department by their revenue
--generated using a window function.

SELECT 
    employee_id,
    employee_name,
    department,
    revenue,
    RANK() OVER (PARTITION BY department ORDER BY revenue DESC) AS revenue_rank
FROM 
    Business_Operations_Dataset;


    WITH DepartmentAvgSalary AS (
    SELECT 
        department,
        AVG(salary) AS avg_salary
    FROM 
        Business_Operations_Dataset
    GROUP BY 
        department
)
SELECT 
    department,
    avg_salary
FROM 
    DepartmentAvgSalary
WHERE 
    avg_salary > 70000;

-- Create a view that shows only the product name, revenue, and profit
--margin for products in the Accessories category.

CREATE VIEW Accessories_Product_Performance AS
SELECT 
    product_name,
    revenue,
    profit_margin
FROM 
    Business_Operations_Dataset
WHERE 
    category = 'Accessories';

    select * from Accessories_Product_Performance

--    Write a query to create a non-clustered index on the employee_name
--column to improve query performance.

CREATE NONCLUSTERED INDEX idx_employee_name
ON Business_Operations_Dataset (employee_name);

--Create a stored procedure that accepts a department name as a
--parameter and returns the total revenue generated by that department.

CREATE PROCEDURE GetDepartmentRevenue
    @DeptName NVARCHAR(100)
AS
BEGIN
    SELECT 
        department,
        SUM(revenue) AS total_revenue
    FROM 
        Business_Operations_Dataset
    WHERE 
        department = @DeptName
    GROUP BY 
        department;
END;
EXEC GetDepartmentRevenue @DeptName = 'Sales';

--Write a trigger that logs changes to the revenue column in a separate table
--whenever an update occurs.

CREATE TABLE RevenueChangeLog (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT,
    product_id INT,
    old_revenue DECIMAL(18, 2),
    new_revenue DECIMAL(18, 2),
    changed_at DATETIME DEFAULT GETDATE()
);
CREATE TRIGGER trg_LogRevenueChange
ON Business_Operations_Dataset
AFTER UPDATE
AS
BEGIN
    INSERT INTO RevenueChangeLog (employee_id, product_id, old_revenue, new_revenue)
    SELECT 
        d.employee_id,
        d.product_id,
        d.revenue AS old_revenue,
        i.revenue AS new_revenue
    FROM 
        deleted d
    INNER JOIN 
        inserted i ON d.employee_id = i.employee_id AND d.product_id = i.product_id
    WHERE 
        d.revenue <> i.revenue;
END;

UPDATE Business_Operations_Dataset
SET revenue = revenue + 1000
WHERE employee_id = 13847;
SELECT * FROM RevenueChangeLog;

--● Create a scalar UDF that calculates the profit from a given product's
--revenue and profit margin.


CREATE FUNCTION dbo.CalculateProfit
(
    @Revenue DECIMAL(18, 2),
    @ProfitMargin DECIMAL(18, 4)  -- Assuming margin is in percentage (e.g., 15.75)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Profit DECIMAL(18, 2);

    SET @Profit = @Revenue * (@ProfitMargin / 100.0);

    RETURN @Profit;
END;

-- Example usage in a SELECT query
SELECT 
    product_name,
    revenue,
    profit_margin,
    dbo.CalculateProfit(revenue, profit_margin) AS profit
FROM 
    dbo.Business_Operations_Dataset;

--Provide a query to create a clustered index on the company_id column.
CREATE CLUSTERED INDEX idx_company_id
ON Business_Operations_Dataset (company_id);

EXEC sp_helpindex 'Business_Operations_Dataset';
