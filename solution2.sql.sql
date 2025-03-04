Solution 2:

SQL Queries and Solutions
Step 1: Create the Required Tables
sql
 
-- Create Employee Table
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Salary DECIMAL(10, 2),
    Department VARCHAR(50)
);

-- Insert sample data into Employee Table
INSERT INTO Employee (EmployeeID, Name, Salary, Department)
VALUES
(1, 'John Doe', 50000, 'HR'),
(2, 'Jane Smith', 60000, 'IT'),
(3, 'Alice Johnson', 70000, 'IT'),
(4, 'Bob Brown', 55000, 'HR'),
(5, 'Charlie Davis', 80000, 'Finance'),
(6, 'Eva Green', 75000, 'Finance'),
(7, 'Frank White', 65000, 'IT'),
(8, 'Grace Black', 72000, 'HR');

-- Create Sales Table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    SaleDate DATE,
    Amount DECIMAL(10, 2)
);

-- Insert sample data into Sales Table
INSERT INTO Sales (SaleID, SaleDate, Amount)
VALUES
(1, '2023-10-01', 1000),
(2, '2023-10-02', 1500),
(3, '2023-10-03', 2000),
(4, '2023-10-04', 2500),
(5, '2023-10-05', 3000),
(6, '2023-10-06', 3500),
(7, '2023-10-07', 4000);
Medium Level Queries
1. Find the second highest salary in the employee table.
sql
 
SELECT MAX(Salary) AS SecondHighestSalary
FROM Employee
WHERE Salary < (SELECT MAX(Salary) FROM Employee);
2. Fetch all employees whose names contain the letter 'a' exactly twice.
sql
 
SELECT *
FROM Employee
WHERE LENGTH(Name) - LENGTH(REPLACE(Name, 'a', '')) = 2;
3. Retrieve duplicate records from a table.
sql
 
SELECT Name, Salary, Department, COUNT(*)
FROM Employee
GROUP BY Name, Salary, Department
HAVING COUNT(*) > 1;
4. Calculate the running total of sales by date.
sql
 
SELECT SaleDate, Amount,
       SUM(Amount) OVER (ORDER BY SaleDate) AS RunningTotal
FROM Sales;
5. Find employees who earn more than the average salary in their department.
sql
 
SELECT e.*
FROM Employee e
JOIN (SELECT Department, AVG(Salary) AS AvgSalary
      FROM Employee
      GROUP BY Department) d
ON e.Department = d.Department
WHERE e.Salary > d.AvgSalary;
6. Find the most frequently occurring value in a column.
sql
 
SELECT Salary, COUNT(*) AS Frequency
FROM Employee
GROUP BY Salary
ORDER BY Frequency DESC
LIMIT 1;
7. Fetch records where the date is within the last 7 days from today.
sql
 
SELECT *
FROM Sales
WHERE SaleDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
8. Count how many employees share the same salary.
sql
 
SELECT Salary, COUNT(*) AS EmployeeCount
FROM Employee
GROUP BY Salary
HAVING COUNT(*) > 1;
9. Fetch the top 3 records for each group in a table.
sql
 
WITH RankedEmployees AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank
    FROM Employee
)
SELECT *
FROM RankedEmployees
WHERE Rank <= 3;
10. Retrieve products that were never sold (using LEFT JOIN).
sql
 
-- Assuming a Products table exists
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50)
);

-- Insert sample data
INSERT INTO Products (ProductID, ProductName)
VALUES
(1, 'Product A'),
(2, 'Product B'),
(3, 'Product C');

-- Query to find unsold products
SELECT p.*
FROM Products p
LEFT JOIN Sales s ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL;
Challenging Level Queries
1. Retrieve customers who made their first purchase in the last 6 months.
sql
 
-- Assuming a Customers table exists
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstPurchaseDate DATE
);

-- Query
SELECT *
FROM Customers
WHERE FirstPurchaseDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
2. Pivot a table to convert rows into columns.
sql
 
-- Example: Pivot total sales by department
SELECT Department,
       SUM(CASE WHEN Salary > 70000 THEN 1 ELSE 0 END) AS HighEarners,
       SUM(CASE WHEN Salary <= 70000 THEN 1 ELSE 0 END) AS LowEarners
FROM Employee
GROUP BY Department;
3. Calculate the percentage change in sales month over month.
sql
 
WITH MonthlySales AS (
    SELECT DATE_FORMAT(SaleDate, '%Y-%m') AS Month,
           SUM(Amount) AS TotalSales
    FROM Sales
    GROUP BY DATE_FORMAT(SaleDate, '%Y-%m')
)
SELECT Month,
       TotalSales,
       LAG(TotalSales) OVER (ORDER BY Month) AS PreviousMonthSales,
       (TotalSales - LAG(TotalSales) OVER (ORDER BY Month)) / LAG(TotalSales) OVER (ORDER BY Month) * 100 AS PercentChange
FROM MonthlySales;
4. Find the median salary of employees in a table.
sql
 
WITH RankedSalaries AS (
    SELECT Salary,
           ROW_NUMBER() OVER (ORDER BY Salary) AS RowAsc,
           ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowDesc
    FROM Employee
)
SELECT AVG(Salary) AS MedianSalary
FROM RankedSalaries
WHERE RowAsc = RowDesc OR RowAsc + 1 = RowDesc OR RowAsc = RowDesc + 1;
5. Fetch all users who logged in consecutively for 3 days or more.
sql
 
-- Assuming a Logins table exists
CREATE TABLE Logins (
    UserID INT,
    LoginDate DATE
);

-- Query
WITH ConsecutiveLogins AS (
    SELECT UserID,
           LoginDate,
           LAG(LoginDate, 2) OVER (PARTITION BY UserID ORDER BY LoginDate) AS Prev2Date
    FROM Logins
)
SELECT DISTINCT UserID
FROM ConsecutiveLogins
WHERE DATEDIFF(LoginDate, Prev2Date) = 2;
6. Delete duplicate rows while keeping one occurrence.
sql
 
DELETE FROM Employee
WHERE EmployeeID NOT IN (
    SELECT MIN(EmployeeID)
    FROM Employee
    GROUP BY Name, Salary, Department
);
7. Calculate the ratio of sales between two categories.
sql
 
-- Assuming a Category column exists in Sales
SELECT Category,
       SUM(Amount) / (SELECT SUM(Amount) FROM Sales) AS SalesRatio
FROM Sales
GROUP BY Category;
8. Implement a recursive query to generate a hierarchical structure.
sql
 
-- Assuming an Employees table with ManagerID
WITH RECURSIVE OrgChart AS (
    SELECT EmployeeID, Name, ManagerID
    FROM Employees
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.Name, e.ManagerID
    FROM Employees e
    INNER JOIN OrgChart o ON e.ManagerID = o.EmployeeID
)
SELECT * FROM OrgChart;
9. Find gaps in sequential numbering within a table.
sql
 
WITH NumberedRows AS (
    SELECT EmployeeID,
           ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employee
)
SELECT MIN(RowNum) AS GapStart, MAX(RowNum) AS GapEnd
FROM NumberedRows
WHERE EmployeeID <> RowNum
GROUP BY EmployeeID - RowNum;
10. Split a comma-separated string into individual rows.
sql
 
-- Assuming a table with a comma-separated column
WITH SplitStrings AS (
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(ColumnName, ',', n), ',', -1) AS Value
    FROM TableName
    JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) AS Numbers
    ON CHAR_LENGTH(ColumnName) - CHAR_LENGTH(REPLACE(ColumnName, ',', '')) >= n - 1
)
SELECT * FROM SplitStrings;
Advanced Queries
1. Rank products by sales in descending order for each region.
sql
 
SELECT Region, ProductID, Sales,
       RANK() OVER (PARTITION BY Region ORDER BY Sales DESC) AS SalesRank
FROM Sales;
2. Fetch all employees whose salaries fall within the top 10% of their department.
sql
 
WITH DepartmentSalaries AS (
    SELECT Department, Salary,
           PERCENT_RANK() OVER (PARTITION BY Department ORDER BY Salary) AS PercentRank
    FROM Employee
)
SELECT *
FROM DepartmentSalaries
WHERE PercentRank >= 0.9;
3. Identify orders placed during business hours (9 AM to 6 PM).
sql
 
-- Assuming an Orders table with OrderDateTime
SELECT *
FROM Orders
WHERE HOUR(OrderDateTime) BETWEEN 9 AND 18;
4. Get the count of users active on both weekdays and weekends.
sql
 
WITH UserActivity AS (
    SELECT UserID,
           SUM(CASE WHEN WEEKDAY(LoginDate) < 5 THEN 1 ELSE 0 END) AS WeekdayLogins,
           SUM(CASE WHEN WEEKDAY(LoginDate) >= 5 THEN 1 ELSE 0 END) AS WeekendLogins
    FROM Logins
    GROUP BY UserID
)
SELECT COUNT(*) AS ActiveUsers
FROM UserActivity
WHERE WeekdayLogins > 0 AND WeekendLogins > 0;
5. Retrieve customers who made purchases across at least three different categories.
sql
 
-- Assuming a Purchases table with CustomerID and Category
SELECT CustomerID
FROM Purchases
GROUP BY CustomerID
HAVING COUNT(DISTINCT Category) >= 3;
Save this content in a .txt file, and you'll have all the queries and solutions in one place! Let me know if you need further assistance. 😊

 