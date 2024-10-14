CREATE DATABASE autoservice;
USE  autoservice;
CREATE TABLE customer (
	CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Address VARCHAR(255),
    Phone VARCHAR(20)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv"
INTO TABLE customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Name, Address, Phone);

SELECT *
FROM customer;

CREATE TABLE vehicle (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    Make VARCHAR(50),
    Model VARCHAR(50),
    Year INT,
    Color VARCHAR(50),
    VIN VARCHAR(25),
    Reg_num VARCHAR(20),
    Mileage INT,
    OwnerName VARCHAR(100)
);


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vehicle.csv.csv"
INTO TABLE vehicle
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Make, Model, Year, Color, VIN, Reg_num, Mileage, OwnerName);

SELECT*
FROM vehicle;

CREATE TABLE invoice (
    InvoiceID INT PRIMARY KEY,
    InvoiceDate DATE,
    SubtotalParts DECIMAL(10,2),
	SubtotalLabour DECIMAL(10,2),
    SalesTaxRate DECIMAL(10,2),
    SalesTax DECIMAL(10,5),
    TotalLabour DECIMAL(10,2),
    TotalParts DECIMAL(10,2),
    Total DECIMAL(10,5),
    CustomerID INT,
    VehicleID INT,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
	FOREIGN KEY (VehicleID) REFERENCES vehicle(VehicleID)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoices.csv.csv"
INTO TABLE invoice
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT*
FROM invoice;

CREATE TABLE job (
    JobID INT PRIMARY KEY,
    VehicleID INT,
    Description VARCHAR(255),
    Hours DECIMAL(5,2),
    Rate DECIMAL(10,2),
	Amount DECIMAL(10, 2),
    InvoiceID INT,
	FOREIGN KEY (VehicleID) REFERENCES vehicle(VehicleID),
	FOREIGN KEY (InvoiceID) REFERENCES invoice(InvoiceID)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/job.csv"
INTO TABLE job
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM job;

CREATE TABLE parts (
    PartID INT,
    JobID INT,
    Part_num VARCHAR(50),
    PartName VARCHAR(100),
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    Amount DECIMAL(10, 2),
    InvoiceID INT,
    FOREIGN KEY (InvoiceID) REFERENCES invoice(InvoiceID),
    FOREIGN KEY (JobID) REFERENCES job(JobID)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/parts.csv.csv"
INTO TABLE parts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM parts;

-- Identify the top 5 customers who have spent the most on vehicle repairs and parts.
SELECT customer.CustomerID, customer.Name, SUM(invoice.Total) AS TotalSpent
FROM customer
INNER JOIN invoice
ON customer.CustomerID = invoice.CustomerID
GROUP BY customer.CustomerID, customer.Name
ORDER BY TotalSpent DESC
LIMIT 5;

-- Determine the average spending of customers on repairs and parts.
SELECT AVG(invoice.Total) AS AverageSpending
FROM customer
INNER JOIN Invoice
ON customer.CustomerID = invoice.CustomerID;

-- Analyze the frequency of customer visits and identify any patterns.
SELECT customer.Name, 
COUNT(invoice.InvoiceID) as VisitCount
FROM invoice 
JOIN customer  
ON invoice.CustomerID = customer.CustomerID
GROUP BY customer.Name
ORDER BY VisitCount DESC;

-- Calculate the average mileage of vehicles serviced.
SELECT AVG(Mileage) AS AverageMileage 
FROM Vehicle;

-- Identify the most common vehicle makes and models brought in for service.
SELECT vehicle.Make, vehicle.Model, COUNT(*) AS Count
FROM vehicle
JOIN job 
ON vehicle.VehicleID = job.VehicleID
GROUP BY vehicle.Make, vehicle.Model
ORDER BY Count DESC
LIMIT 5;

-- Analyze the distribution of vehicle ages and identify any trends 
-- in service requirements based on vehicle age.
SELECT Year, (2024 - Year) AS Age
FROM vehicle;

SELECT (2024 - Year) AS Age, COUNT(*) AS Frequency
FROM vehicle
GROUP BY Age
ORDER BY Age;

SELECT (2024 - vehicle.Year) AS Age, job.Description, COUNT(*) AS Frequency
FROM vehicle 
JOIN job  
ON vehicle.VehicleID = job.VehicleID
GROUP BY Age, job.Description
ORDER BY Age, Frequency DESC;

-- Determine the most common types of jobs performed and their frequency.
SELECT Description, COUNT(JobID) as Frequency
FROM job
GROUP BY Description
ORDER BY Frequency DESC;

-- Calculate the total revenue generated from each type of job.
SELECT Description, SUM(Amount) as TotalRevenue
FROM job
GROUP BY Description
ORDER BY TotalRevenue DESC;

-- Identify the jobs with the highest and lowest average costs.
SELECT Description, AVG(Amount) AS AverageCost
FROM job
GROUP BY Description
ORDER BY AverageCost DESC;

-- Job with the Highest average cost
SELECT Description, AVG(Amount) AS AverageCost
FROM job
GROUP BY Description
ORDER BY AverageCost DESC
LIMIT 1;

-- Job with the lowest average cost
SELECT Description, AVG(Amount) AS AverageCost
FROM job
GROUP BY Description
ORDER BY AverageCost ASC
LIMIT 1;

-- List the top 5 most frequently used parts and their total usage.
SELECT PartName, SUM(Quantity) AS TotalUsage
FROM parts
GROUP BY PartName
ORDER BY TotalUsage DESC
LIMIT 5;

-- Calculate the average cost of parts used in repairs.
SELECT AVG(UnitPrice) AS AveragePartCost FROM parts;

-- Determine the total revenue generated from parts sales.
SELECT SUM(Amount) AS TotalPartsRevenue FROM parts;

-- Calculate the total revenue generated from labor and parts for each month.
SELECT MONTH(invoice.InvoiceDate) AS Month,
	SUM(invoice.TotalLabour + invoice.TotalParts) AS TotalRevenue
FROM invoice
GROUP BY MONTH(invoice.InvoiceDate);

-- Determine the overall profitability of the repair shop.
SELECT SUM(invoice.Total - (invoice.TotalLabour + invoice.TotalParts)) AS Profit
FROM invoice;

-- Analyze the impact of sales tax on the total revenue.
SELECT SUM(invoice.SalesTax) AS TotalSalesTax,
SUM(invoice.Total) AS TotalRevenue,
(SUM(invoice.SalesTax) / SUM(invoice.Total)) * 100 AS SalesTaxPercentage
FROM invoice ;