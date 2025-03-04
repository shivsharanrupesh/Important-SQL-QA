Solution 1: 
-- Medium Level SQL Queries

-- Creating Employee Table and Inserting Data
CREATE TABLE employee (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    salary DECIMAL(10,2),
    department VARCHAR(50)
);

INSERT INTO employee (emp_name, salary, department) VALUES
('Alice', 50000, 'HR'),
('Bob', 60000, 'IT'),
('Charlie', 70000, 'Finance'),
('David', 80000, 'IT'),
('Eve', 50000, 'Finance');

-- 1. Find the second highest salary in an employee table
SELECT DISTINCT salary FROM employee ORDER BY salary DESC LIMIT 1 OFFSET 1;

-- 2. Fetch all employees whose names contain the letter 'a' exactly twice
SELECT * FROM employee WHERE emp_name LIKE '%a%a%' AND emp_name NOT LIKE '%a%a%a%';

-- 3. Retrieve any duplicate records from the employee table
SELECT emp_name, salary, department, COUNT(*) FROM employee GROUP BY emp_name, salary, department HAVING COUNT(*) > 1;

-- Creating Sales Table and Inserting Data
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    sale_date DATE,
    amount DECIMAL(10,2)
);

INSERT INTO sales (sale_date, amount) VALUES
('2024-03-01', 100),
('2024-03-02', 200),
('2024-03-03', 150);

-- 4. Calculate the running total of sales by date
SELECT sale_date, amount, SUM(amount) OVER (ORDER BY sale_date) AS running_total FROM sales;

-- 5. Find employees who earn more than the average salary in their department
SELECT * FROM employee e WHERE salary > (SELECT AVG(salary) FROM employee WHERE department = e.department);

-- 6. Find the most frequently occurring value in a column
SELECT salary, COUNT(*) FROM employee GROUP BY salary ORDER BY COUNT(*) DESC LIMIT 1;

-- 7. Fetch records where the date is within the last 7 days from today
SELECT * FROM sales WHERE sale_date >= CURRENT_DATE - INTERVAL '7 days';

-- 8. Count how many employees share the same salary
SELECT salary, COUNT(*) FROM employee GROUP BY salary;

-- 9. Fetch the top 3 records for each department
SELECT * FROM (
    SELECT *, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank FROM employee
) ranked WHERE rank <= 3;

-- 10. Retrieve products that were never sold
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100)
);

CREATE TABLE product_sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products (product_name) VALUES
('Laptop'),
('Phone'),
('Tablet');

INSERT INTO product_sales (product_id, amount) VALUES
(1, 500),
(2, 300);

SELECT p.* FROM products p LEFT JOIN product_sales s ON p.product_id = s.product_id WHERE s.product_id IS NULL;

-- Challenging Level SQL Queries

-- 1. Retrieve customers who made their first purchase in the last 6 months
CREATE TABLE purchases (
    purchase_id SERIAL PRIMARY KEY,
    customer_id INT,
    purchase_date DATE
);

INSERT INTO purchases (customer_id, purchase_date) VALUES
(1, '2023-09-01'),
(2, '2024-02-15'),
(3, '2024-01-10');

SELECT customer_id, MIN(purchase_date) FROM purchases GROUP BY customer_id HAVING MIN(purchase_date) >= NOW() - INTERVAL '6 MONTHS';

-- 2. Pivot a table to convert rows into columns (Example for monthly sales)
SELECT * FROM (
    SELECT EXTRACT(MONTH FROM sale_date) AS month, amount FROM sales
) src PIVOT (SUM(amount) FOR month IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)) AS pvt;

-- 3. Calculate the percentage change in sales month-over-month
SELECT sale_date, amount,
    (amount - LAG(amount) OVER (ORDER BY sale_date)) / NULLIF(LAG(amount) OVER (ORDER BY sale_date), 0) * 100 AS percentage_change
FROM sales;

-- 4. Find the median salary of employees
SELECT AVG(salary) AS median_salary FROM (
    SELECT salary FROM employee ORDER BY salary OFFSET (SELECT COUNT(*)/2 FROM employee) LIMIT 2
) AS median_table;

-- 5. Fetch all users who logged in consecutively for 3 days or more
CREATE TABLE logins (
    user_id INT,
    login_date DATE
);

INSERT INTO logins (user_id, login_date) VALUES
(1, '2024-03-01'),
(1, '2024-03-02'),
(1, '2024-03-03'),
(2, '2024-03-01'),
(2, '2024-03-04');

SELECT user_id FROM (
    SELECT user_id, login_date, LEAD(login_date, 1) OVER (PARTITION BY user_id ORDER BY login_date) AS next_day,
    LEAD(login_date, 2) OVER (PARTITION BY user_id ORDER BY login_date) AS third_day
    FROM logins
) subquery WHERE next_day = login_date + INTERVAL '1 day' AND third_day = login_date + INTERVAL '2 days';

-- Advanced Level SQL Queries

-- 1. Rank products by sales in descending order for each region
CREATE TABLE regional_sales (
    product_id INT,
    region VARCHAR(50),
    amount DECIMAL(10,2)
);

INSERT INTO regional_sales (product_id, region, amount) VALUES
(1, 'North', 500),
(2, 'North', 600),
(1, 'South', 700),
(3, 'South', 400);

SELECT *, RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS rank FROM regional_sales;

-- 2. Fetch employees whose salaries fall within the top 10% of their department
SELECT * FROM (
    SELECT *, PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS percentile FROM employee
) ranked WHERE percentile <= 0.10;

-- 3. Identify orders placed during business hours (9 AM - 6 PM)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_time TIMESTAMP
);

INSERT INTO orders (customer_id, order_time) VALUES
(1, '2024-03-01 10:30:00'),
(2, '2024-03-01 18:45:00');

SELECT * FROM orders WHERE EXTRACT(HOUR FROM order_time) BETWEEN 9 AND 18;

-- 4. Get the count of users active on both weekdays and weekends
SELECT user_id FROM logins WHERE EXTRACT(DOW FROM login_date) IN (0,6) INTERSECT SELECT user_id FROM logins WHERE EXTRACT(DOW FROM login_date) BETWEEN 1 AND 5;

-- 5. Retrieve customers who made purchases across at least three different categories
SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(DISTINCT category) >= 3;
