---DATA ASSESSMENT

USE greentech;
SELECT* FROM line_downtime;
SELECT* FROM products;
SELECT* FROM line_productivity_batches;
SELECT* FROM downtime_factors;

---ROWS COUNTING

SELECT COUNT(*) AS NUMROWS_LINEDOWNTIME FROM line_downtime;
SELECT COUNT(*) AS NUMROWS_DOWNTIMEFACTORS  FROM downtime_factors; 
SELECT COUNT(*) AS NUMROWS_LINEPRODUCTIVITY FROM line_productivity_batches;
SELECT COUNT(*) AS NUMROWS_PRODUCTS FROM products

---NULL COUNTS

SELECT COUNT(*) AS FACTOR_1_NULL FROM line_downtime
WHERE Factor_1 IS NULL;

---TO SELECT ALL THE NULLS IN FACTORS 1 TO 13

SELECT COUNT(*) AS ALL_FACTORS_NULL FROM line_downtime
WHERE COALESCE (Factor_1, Factor_2, Factor_3, Factor_4, Factor_5, Factor_6, Factor_7, 
Factor_8, Factor_9, Factor_10, Factor_11, Factor_12, Factor_13) IS NULL;

---Start date repetition in date and start time columns

with start_dates AS (
SELECT Date, CAST(Start_Time AS Date) As Start_Date
FROM line_productivity_batches) 
SELECT* FROM start_dates
where Date != Start_Date;

with start_dates AS (
SELECT Date, CAST(Start_Time AS Date) As Start_Date
FROM line_productivity_batches) 
SELECT* FROM start_dates
where Date = Start_Date;

---Data Cleaning and Transformation
---Unpivot table and make column names consistent
Create VIEW downtimes AS
SELECT Batch_ID, Replace( Factor, 'Factor_', '') AS Factor_ID, Minutes
FROM line_downtime
Unpivot(Minutes FOR Factor IN (Factor_1, Factor_2, Factor_3, Factor_4, Factor_5, Factor_6, Factor_7, 
Factor_8, Factor_9, Factor_10, Factor_11, Factor_12, Factor_13)) AS unpivot_downtimes;

select* from downtimes
order by Batch_ID asc;

CREATE VIEW Batch_pd AS
Select Date, Product_ID, Batch_ID, Operator,Cast( End_Time AS Date) As End_Date,Cast( End_Time AS Time) As End_Time,
Cast( Start_Time AS Time) As Start_Time, Planned_Min_Batch_Hours, Datediff(hour,Start_Time, End_Time) AS Actual_Duration,
Datediff(hour,Start_Time, End_Time) - Planned_Min_Batch_Hours AS Extra_Time_Hours FROM line_productivity_batches;

ALTER VIEW Batch_pd AS
SELECT 
    [Date] AS [START DATE],
    Product_ID,
    Batch_ID,
    Operator,
    CAST(End_Time AS DATE) AS End_Date,
    CAST(End_Time AS TIME) AS End_Time,
    CAST(Start_Time AS TIME) AS Start_Time,
    Planned_Min_Batch_Hours,
    DATEDIFF(HOUR, Start_Time, End_Time) AS Actual_Duration,
    DATEDIFF(HOUR, Start_Time, End_Time) - Planned_Min_Batch_Hours AS Extra_Time_Hours
FROM line_productivity_batches;

Select* from Batch_pd;

---Validating downtime minutes against planned production time and reported start/end time

SELECT Batch_pd.Batch_ID, SUM(Minutes) AS Accounted_Delay_Minutes, Extra_Time_Hours
FROM downtimes
JOIN Batch_pd
ON downtimes.Batch_ID = Batch_pd.Batch_ID
GROUP BY Batch_pd.Batch_ID, Extra_Time_Hours;


---ANALYSIS
---DOWNTIME KEY FACTORS FOR BATCHES

SELECT* FROM downtimes;

SELECT* FROM downtime_factors;

SELECT Factor_Name, COUNT(Batch_ID) AS FREQUENCY, SUM(MINUTES) AS Delay_Mins
FROM downtimes
JOIN downtime_factors
ON downtimes.Factor_ID = downtime_factors.Factor_ID
Group by Factor_Name
ORDER BY Delay_Mins DESC

---- Operator versus Non-Opeartor Errors

SELECT CASE operator_error
		WHEN 1 Then 'Yes'
		WHEN 0 Then 'No'
		End As operator_error,
		Count (Batch_Id) AS Frequency, SUM(Minutes) AS Delay_Mins From downtimes
		Join downtime_factors
		ON  downtimes.Factor_Id= Downtime_Factors.Factor_ID
		Group by Operator_Error;


---- Operator Error downtime

SELECT Factor_Name, Description, Count (Batch_Id) AS Frequency, SUM(Minutes) AS Delay_Mins From downtimes
		Join downtime_factors
		ON  downtimes.Factor_Id= Downtime_Factors.Factor_ID
		WHERE Operator_Error = 1
		GROUP BY Factor_Name, Description
		ORDER BY SUM(Minutes) DESC;

---- Non operator downtime error

SELECT Factor_Name, Description, Count (Batch_Id) AS Frequency, SUM(Minutes) AS Delay_Mins From downtimes
		Join downtime_factors
		ON  downtimes.Factor_Id= Downtime_Factors.Factor_ID
		WHERE Operator_Error = 0
		GROUP BY Factor_Name, Description
		ORDER BY SUM(Minutes) DESC;

---- Products downtime frequency and delay (IN MINUTES)

SELECT * FROM products;
SELECT * FROM downtimes;
SELECT * FROM  Batch_pd;

SELECT Batch_pd.Product_ID, Product_Name, Count (downtimes.Batch_Id) AS Frequency, SUM(Minutes) AS Delay_Mins
From Batch_pd
JOIN downtimes 
ON Batch_pd. Batch_ID = downtimes.Batch_ID
JOIN Products
ON Batch_pd.Product_ID = Products.Product_ID
Group by Batch_pd.Product_ID, Product_Name;


---- How many factors are involved in each product downtime?

SELECT * FROM products;
SELECT * FROM downtimes;
SELECT * FROM  Batch_pd;

SELECT Batch_pd.Product_ID, Product_Name, Count (DISTINCT FACTOR_ID) AS DISTINCT_FACTORS_COUNTS
From Batch_pd
JOIN downtimes 
ON Batch_pd. Batch_ID = downtimes.Batch_ID
JOIN Products
ON Batch_pd.Product_ID = Products.Product_ID
Group by Batch_pd.Product_ID, Product_Name;


------

SELECT * FROM downtimes;
SELECT * FROM  Batch_pd;
SELECT* FROM downtime_factors;

----Top 5 factors for product 1 downtimes

SELECT TOP 5 Factor_Name, SUM(MINUTES) AS PRD001_DELAY_MINS
FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_factors.Factor_ID
JOIN Batch_pd
ON downtimes.Batch_ID = Batch_pd.Batch_ID
WHERE Product_ID = 'PRD001'
GROUP BY Factor_Name
ORDER BY SUM(MINUTES) DESC;

----Top 5 factors for product 2 downtimes

SELECT TOP 5 Factor_Name, SUM(MINUTES) AS PRD002_DELAY_MINS
FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_factors.Factor_ID
JOIN Batch_pd
ON downtimes.Batch_ID = Batch_pd.Batch_ID
WHERE Product_ID = 'PRD002'
GROUP BY Factor_Name
ORDER BY SUM(MINUTES) DESC;

----Top 5 factors for product 3 downtimes
SELECT TOP 5 Factor_Name, SUM(MINUTES) AS PRD003_DELAY_MINS
FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_factors.Factor_ID
JOIN Batch_pd
ON downtimes.Batch_ID = Batch_pd.Batch_ID
WHERE Product_ID = 'PRD003'
GROUP BY Factor_Name
ORDER BY SUM(MINUTES) DESC;

----Top 5 factors for product 4 downtimes

SELECT TOP 5 Factor_Name, SUM(MINUTES) AS PRD004_DELAY_MINS
FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_factors.Factor_ID
JOIN Batch_pd
ON downtimes.Batch_ID = Batch_pd.Batch_ID
WHERE Product_ID = 'PRD004'
GROUP BY Factor_Name
ORDER BY SUM(MINUTES) DESC;


----Production lead operators
SELECT Operator, COUNT(Batch_ID) AS Number_of_Batches,COUNT(DISTINCT Product_ID) AS Number_of_Products
FROM Batch_pd
GROUP BY Operator
ORDER BY Number_of_Batches DESC;

---Production Lead Operator, Downtime Duration and Percentage Delayed Batches

SELECT Operator, 
COUNT(DISTINCT Batch_pd.Batch_ID) AS Total_Batches,
COUNT (DISTINCT downtimes.Batch_ID) AS Number_of_Delayed_Batches,
COUNT(downtimes.Batch_ID) AS Number_of_Downtimes,
SUM(MINUTES) AS Delay_Minutes,
CAST((COUNT (DISTINCT downtimes.Batch_ID)*100.0)/ (COUNT(DISTINCT Batch_pd.Batch_ID)) AS DECIMAL (10,2))
AS Percentage_delayed_batches
FROM Batch_pd
Left Join downtimes
ON Batch_pd.Batch_ID = downtimes.Batch_ID
Group By Operator
ORDER BY Percentage_delayed_batches DESC;

----- Factors resulting into downtime and most delayed duration for top 3 lead operators
--1) Paul
SELECT Factor_Name, SUM(MINUTES) AS Delay_Mins FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_Factors.Factor_ID
JOIN batch_pd
ON downtimes.Batch_ID = batch_pd.Batch_ID
WHERE OPERATOR = 'PAUL'
GROUP BY Factor_Name
ORDER BY SUM(Minutes) DESC;

--2) James

SELECT Factor_Name, SUM(MINUTES) AS Delay_Mins FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_Factors.Factor_ID
JOIN batch_pd
ON downtimes.Batch_ID = batch_pd.Batch_ID
WHERE OPERATOR = 'JAMES'
GROUP BY Factor_Name
ORDER BY SUM(Minutes) DESC;

---3) EMILY

SELECT Factor_Name, SUM(MINUTES) AS Delay_Mins FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_Factors.Factor_ID
JOIN batch_pd
ON downtimes.Batch_ID = batch_pd.Batch_ID
WHERE OPERATOR = 'EMILY'
GROUP BY Factor_Name
ORDER BY SUM(Minutes) DESC;

----- Factors resulting into downtime for 3 least operators with the highest percentage of batches delay

--1 LINDA
SELECT Factor_Name, SUM(MINUTES) AS Delay_Mins FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_Factors.Factor_ID
JOIN batch_pd
ON downtimes.Batch_ID = batch_pd.Batch_ID
WHERE OPERATOR = 'LINDA'
GROUP BY Factor_Name
ORDER BY SUM(Minutes) DESC;

--2 SOPHIA
SELECT Factor_Name, SUM(MINUTES) AS Delay_Mins FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_Factors.Factor_ID
JOIN batch_pd
ON downtimes.Batch_ID = batch_pd.Batch_ID
WHERE OPERATOR = 'SOPHIA'

--3 RITA

SELECT Factor_Name, SUM(MINUTES) AS Delay_Mins FROM downtimes
JOIN downtime_Factors
ON downtimes.Factor_ID = downtime_Factors.Factor_ID
JOIN batch_pd
ON downtimes.Batch_ID = batch_pd.Batch_ID
WHERE OPERATOR = 'RITA'
GROUP BY Factor_Name
ORDER BY SUM(Minutes) DESC;
 