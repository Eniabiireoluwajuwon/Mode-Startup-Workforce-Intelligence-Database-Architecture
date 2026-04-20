-- Drop the database if it already exists to ensure a clean slate for testing
DROP DATABASE IF EXISTS `Mode_Startup`;

-- Create the new database
CREATE DATABASE `Mode_Startup`;

-- Tell the SQL engine to use this specific database for all following commands
USE `Mode_Startup`;

-- Create the demographics table to hold personal employee information
CREATE TABLE employee_demographics (
  employee_id INT NOT NULL,  	-- Unique identifier for each employee (Primary Key)
  first_name VARCHAR(50),    	-- Employee's first name
  last_name VARCHAR(50), 		-- Employee's last name
  age INT, 						-- Employee's age
  gender VARCHAR(10), 			-- Employee's gender
  birth_date DATE, 				-- Employee's date of birth
  PRIMARY KEY (employee_id) 	-- Enforces uniqueness on the employee_id column
);


-- DATA GENERATION (EMPLOYEE DEMOGRAPHICS)
-- We use a Recursive Common Table Expression (CTE) to act as a loop.
-- This automatically generates 1,000 rows of randomized demographic data.
INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
WITH RECURSIVE DataGenerator AS (
    -- Start our counter at 1
    SELECT 1 AS n
    UNION ALL
    -- Loop and add 1 until we hit 1000
    SELECT n + 1 
    FROM DataGenerator 
    WHERE n < 1000
)
SELECT 
    n + 12, 														-- Starts the employee_id at 13 to avoid conflicts
    CONCAT('Employee', n), 											-- Generates names like Employee1, Employee2
    CONCAT('Smith', n),    											-- Generates last names like Smith1, Smith2
    FLOOR(RAND() * 45) + 20, 										-- Generates a random age between 20 and 65
    CASE WHEN n % 2 = 0 THEN 'Female' ELSE 'Male' END, 				-- Alternates gender evenly
    DATE_ADD('1960-01-01', INTERVAL FLOOR(RAND() * 15000) DAY) 		-- Adds random days to a base date for unique DOBs
FROM DataGenerator;



CREATE TABLE employee_salary (
  employee_id INT NOT NULL, 				-- Foreign key link back to employee_demographics
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  occupation VARCHAR(50), 					-- Job title
  salary INT, 								-- Annual salary
  dept_id INT 								-- Numeric ID representing the department they work in
);



-- DATA GENERATION (EMPLOYEE SALARY)
-- We use another Recursive CTE here. 
-- CRITICAL: By using the exact same 'n' logic, the names and IDs will perfectly 
-- match the demographics table generated above, ensuring our JOINs work perfectly later.
INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
WITH RECURSIVE DataGenerator AS (
    -- Start our counter at 1
    SELECT 1 AS n
    UNION ALL
    -- Loop and add 1 until we hit 1000
    SELECT n + 1 
    FROM DataGenerator 
    WHERE n < 1000
)
SELECT 
    n + 12,                 -- Matches the employee_ids from 13 to 1012
    CONCAT('Employee', n),  -- Matches the first names from the demographics table
    CONCAT('Smith', n),     -- Matches the last names from the demographics table
    ELT(FLOOR(RAND() * 8) + 1, 'Manager', 'Analyst', 'Coordinator', 'Director', 'Specialist', 'Assistant', 'Consultant', 'Technician'), -- Picks a random job title from 8 options
    FLOOR(RAND() * 90000) + 30000, -- Generates a completely random salary between $30,000 and $120,000
    FLOOR(RAND() * 6) + 1          -- Assigns a random department ID between 1 and 6
FROM DataGenerator;

 

-- TABLE CREATION (DEPARTMENTS LOOKUP)
-- Create a lookup table for departments. 
-- This translates the numeric 'dept_id' into a readable text name for our BI reports.
CREATE TABLE mode_startup_departments (
  department_id INT NOT NULL AUTO_INCREMENT, 		-- Automatically increments the ID for each new row
  department_name varchar(50) NOT NULL, 			-- The readable name of the department
  PRIMARY KEY (department_id)
);


-- Insert the 6 core departments for the startup
INSERT INTO mode_startup_departments (department_name)
VALUES
('Health Safety Environment'), 		-- ID 1
('Human Resources'), 				-- ID 2	
('Admin'),							-- ID 3
('Operation'),						-- ID 4
('Sales and Marketing'),			-- ID 5
('Finance')							-- ID 6
; 


-- BUSINESS INTELLIGENCE (BI) & DATA EXPLORATION QUERIES
# A. General Quality Assurance (QA) Checks

-- View the newly created departments table
SELECT*
FROM mode_startup_departments;



-- Combine all three tables to see a complete profile of the workforce.
-- We use an INNER JOIN for salary (must exist in both) and a LEFT JOIN for departments 
-- (just in case someone doesn't have a department assigned yet).
SELECT dem.first_name,
dem.last_name,
age,
gender,
occupation,
salary,
dept.department_name
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
LEFT JOIN mode_startup_departments dept
	ON dept.department_id = sal.dept_id;
    

-- Find all employees older than 40 
SELECT first_name, last_name, age 
FROM employee_demographics 
WHERE age > 40;



-- Number of employees by gender
SELECT gender, COUNT(*) as total_employees 
FROM employee_demographics 
GROUP BY gender;


-- Order employees from youngest to oldest
SELECT first_name, last_name, birth_date 
FROM employee_demographics 
ORDER BY birth_date DESC;


-- TOP 3 Highest paid employee 
SELECT first_name, last_name, occupation, salary
FROM employee_salary
ORDER BY salary DESC
LIMIT 3;


SELECT AVG(salary) as average_admin_salary
FROM employee_salary
WHERE dept_id = 3;



# B. Executive Finance Metrics
-- 1. Total Annual Payroll & Salary Spread. How much is the organization spending on its workforce globally?
SELECT 
    SUM(salary) AS total_annual_payroll,				-- Total financial liability
    ROUND(AVG(salary), 2) AS company_average_salary,	-- Average cost per head
    MAX(salary) AS highest_salary,						-- Salary ceiling
    MIN(salary) AS lowest_salary						-- Salary floor
FROM employee_salary;


# 2. Salary Spend by Department (Budget Allocation). Which departments are consuming the most operational capital?
SELECT 
    dept.department_name,
    SUM(sal.salary) AS total_department_cost,				-- Sums all salaries within the grouping
    ROUND(AVG(sal.salary), 2) AS average_department_salary
FROM employee_salary sal
LEFT JOIN mode_startup_departments dept 
    ON sal.dept_id = dept.department_id
GROUP BY dept.department_name
ORDER BY total_department_cost DESC							-- Ranks them from most expensive to least
;



# C. HR & Governance Metrics
-- 1. Gender Pay Equity Analysis. Are we compensating employees equitably across gender lines?
SELECT 
    dem.gender,
    COUNT(dem.employee_id) AS total_headcount,		-- Number of people in each gender bucket
    ROUND(AVG(sal.salary), 2) AS average_salary		-- Average pay for that gender bucket
FROM employee_demographics dem
INNER JOIN employee_salary sal 
    ON dem.employee_id = sal.employee_id
GROUP BY dem.gender;




-- 2. Age Distribution & Compensation. Does the organization reward tenure/age, or are younger employees earning comparable rates?

SELECT 
	-- Use a CASE statement to group individual ages into generational brackets
    CASE 
        WHEN dem.age BETWEEN 20 AND 29 THEN '20s'
        WHEN dem.age BETWEEN 30 AND 39 THEN '30s'
        WHEN dem.age BETWEEN 40 AND 49 THEN '40s'
        WHEN dem.age BETWEEN 50 AND 59 THEN '50s'
        ELSE '60+' 
    END AS age_bracket,
    COUNT(dem.employee_id) AS headcount,
    ROUND(AVG(sal.salary), 2) AS average_salary
FROM employee_demographics dem
INNER JOIN employee_salary sal 
    ON dem.employee_id = sal.employee_id
GROUP BY age_bracket								-- Groups the results by the CASE statement above
ORDER BY average_salary DESC;

# D. Operational Efficiency Metrics
-- 1. Departmental Headcount & Resource Allocation. Which departments have the largest workforce?
SELECT 
    COALESCE(dept.department_name, 'Unassigned') AS department,
    COUNT(sal.employee_id) AS total_employees
FROM employee_salary sal
LEFT JOIN mode_startup_departments dept
    ON sal.dept_id = dept.department_id
GROUP BY department
ORDER BY total_employees DESC;


-- 2. Organizational Structure (Title Distribution). Are there too many managers and not enough technicians? (Checks organizational hierarchy)
SELECT 
    occupation AS job_title,
    COUNT(employee_id) AS total_in_role,			-- Counts how many people hold that exact title
    ROUND(AVG(salary), 2) AS average_role_salary	-- Shows average rate for that specific title
FROM employee_salary
GROUP BY occupation
ORDER BY total_in_role DESC
;
    
    

