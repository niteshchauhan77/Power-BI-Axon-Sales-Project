USE classicmodels;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM offices;
SELECT * FROM orderdetails;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM productlines;
SELECT * FROM products;

-- Product Line selling the most
SELECT SUM(od.quantityOrdered) AS TotalQuantityOrdered, p.productCode, p.productName, od.priceEach, p.productLine, p.buyPrice, p.MSRP
FROM products AS p 
INNER JOIN orderdetails AS od
ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, od.priceEach, p.productLine;

-- Customer spending the most
SELECT SUM(od.quantityOrdered * od.priceEach) AS Sales, c.customerNumber, c.customerName, c.country, od.productCode, SUM(od.quantityOrdered) AS TotalQuantityOrdered, AVG(od.priceEach) AS AveragePriceEach
FROM orders AS o
INNER JOIN customers AS c 
ON o.customerNumber = c.customerNumber
INNER JOIN orderdetails AS od
ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName, c.country, od.productCode
ORDER BY Sales DESC;

-- Joining all the tables
SELECT p.productCode, p.productName, od.priceEach, od.quantityOrdered, p.productLine, od.orderNumber, o.orderDate, o.customerNumber, c.customerName, c.city, c.country, p.buyPrice, p.MSRP
FROM products AS p
INNER JOIN orderdetails AS od
ON p.productCode = od.productCode
INNER JOIN orders AS o 
ON od.orderNumber = o.orderNumber
INNER JOIN customers AS c
ON o.customerNumber = c.customerNumber
GROUP BY p.productCode, od.priceEach, od.quantityOrdered, od.orderNumber, o.orderDate, o.customerNumber, c.customerName, c.city, c.country, p.buyPrice, p.MSRP;
         
-- Getting Sales Amount
SELECT CONCAT('$', FORMAT(priceEach * quantityOrdered, 2)) AS sales_amount
FROM orderdetails;

-- Getting Total Sales
SELECT CONCAT('$', FORMAT(SUM(priceEach * quantityOrdered) / 1000000, 2), 'M') AS total_sales
FROM orderdetails;

-- Getting Average, Minimum and Maximum Sales
SELECT CONCAT('$', FORMAT(AVG(priceEach * quantityOrdered), 2)) AS average_sales,
       CONCAT('$', FORMAT(MIN(priceEach * quantityOrdered), 2)) AS minimum_sales,
       CONCAT('$', FORMAT(MAX(priceEach * quantityOrdered), 2)) AS maximum_sales
FROM orderdetails;

-- Filtering by Order Date
SELECT o.orderDate, od.priceEach * od.quantityOrdered AS sales_amount
FROM orders AS o
INNER JOIN orderdetails od 
ON o.orderNumber = od.orderNumber
WHERE o.orderDate BETWEEN '2003-01-01' AND '2005-12-31' 
ORDER BY sales_amount DESC; 

-- Getting Order Number, Order Date and Customer Name
SELECT o.orderNumber, o.orderDate, c.customerName
FROM orders AS o
INNER JOIN customers AS c 
ON o.customerNumber = c.customerNumber;

--  Getting Order Number, Product Code and Sales Greater than Average Sales
SELECT orderNumber, productCode, CONCAT('$', FORMAT(priceEach * quantityOrdered, 2)) AS sales
FROM orderdetails
WHERE (priceEach * quantityOrdered) > (SELECT AVG(priceEach * quantityOrdered) FROM orderdetails);

-- Getting orders from USA
SELECT * FROM orders
WHERE customerNumber IN (SELECT customerNumber FROM customers WHERE country = "USA");

-- Getting Average Sales from USA
SELECT c.country, AVG(od.priceEach * od.quantityOrdered) AS avg_sales
FROM orderdetails AS od
INNER JOIN orders AS o 
ON od.orderNumber = o.orderNumber
INNER JOIN customers AS c 
ON o.customerNumber = c.customerNumber
WHERE c.country = "USA"
GROUP BY c.country;

-- Creating View for Total Amount By USA
CREATE VIEW orders_In_USA AS
 SELECT o.orderNumber, c.customerName, o.orderDate,
       CONCAT('$', FORMAT(SUM(od.priceEach * od.quantityOrdered) / 1000000, 2), 'M') AS total_amount
 FROM orders o
 INNER JOIN customers AS c 
 ON o.customerNumber = c.customerNumber
 INNER JOIN orderdetails AS od 
 ON o.orderNumber = od.orderNumber
 WHERE c.country = 'USA'
 GROUP BY o.orderNumber, c.customerName, o.orderDate;

SELECT * FROM orders_In_USA;

-- Updating comments column In Orders
UPDATE orders
SET comments = COALESCE(comments, 'NA')
WHERE comments IS NULL;
SELECT * FROM orders;
