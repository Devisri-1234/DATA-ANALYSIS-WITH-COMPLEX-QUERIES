-- DROP TABLES IF THEY ALREADY EXIST
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Products;

-- CREATE PRODUCTS TABLE
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    Category VARCHAR(50)
);

-- CREATE SALES TABLE
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    SaleDate DATE,
    Quantity INT,
    Amount DECIMAL(10, 2)
);

-- INSERT SAMPLE DATA INTO PRODUCTS
INSERT INTO Products (ProductID, ProductName, Category) VALUES
(1, 'Laptop', 'Electronics'),
(2, 'Headphones', 'Electronics'),
(3, 'Notebook', 'Stationery'),
(4, 'Mouse', 'Electronics'),
(5, 'Pen', 'Stationery');

-- INSERT SAMPLE DATA INTO SALES
INSERT INTO Sales (SaleID, CustomerID, ProductID, SaleDate, Quantity, Amount) VALUES
(1, 101, 1, '2024-01-10', 1, 75000),
(2, 102, 2, '2024-01-12', 2, 3000),
(3, 101, 3, '2024-02-01', 3, 150),
(4, 103, 1, '2024-02-15', 1, 75000),
(5, 104, 2, '2024-03-05', 1, 1500),
(6, 102, 3, '2024-03-10', 5, 250),
(7, 105, 4, '2024-03-15', 1, 1200),
(8, 106, 5, '2024-04-02', 10, 100),
(9, 107, 1, '2024-04-05', 1, 75000),
(10, 108, 2, '2024-04-10', 1, 1500);

-- ANALYSIS QUERY USING CTE + WINDOW FUNCTION + SUBQUERY (MYSQL COMPATIBLE)

-- STEP 1: Monthly Sales per Product
WITH MonthlySales AS (
    SELECT
        P.ProductName,
        P.Category,
        DATE_FORMAT(S.SaleDate, '%Y-%m-01') AS SaleMonth,
        SUM(S.Quantity) AS TotalUnits,
        SUM(S.Amount) AS TotalSales
    FROM Sales S
    JOIN Products P ON S.ProductID = P.ProductID
    GROUP BY P.ProductName, P.Category, DATE_FORMAT(S.SaleDate, '%Y-%m-01')
),

-- STEP 2: Rank Products Within Each Month
RankedMonthlySales AS (
    SELECT *,
           RANK() OVER (PARTITION BY SaleMonth ORDER BY TotalSales DESC) AS SalesRank
    FROM MonthlySales
)

-- STEP 3: Final Report - Top 3 Products Each Month
SELECT 
    DATE_FORMAT(SaleMonth, '%Y-%m') AS SaleMonth,
    ProductName,
    Category,
    TotalUnits,
    TotalSales,
    SalesRank
FROM RankedMonthlySales
WHERE SalesRank <= 3
ORDER BY SaleMonth, SalesRank;
