CREATE DATABASE BritConnectDB;

USE BritConnectDB;
 

 SELECT *
FROM Fact_Outage_Incident
WHERE Incident_ID IS NULL
   OR Site_ID IS NULL
   OR Root_Cause_ID IS NULL
   OR Incident_Start_Time IS NULL
   OR Incident_End_Time IS NULL
   OR Duration_Minutes IS NULL
   OR Severity_Level IS NULL;


Select* 
FROM dim_customer_segment;

Select* 
FROM dim_date;

Select* 
FROM dim_root_cause;

Select* 
FROM dim_site;

Select* 
FROM dim_vendor;

Select* 
FROM fact_alarm_log;

Select* 
FROM fact_customer_complaint;

select*
FROM fact_maintenance;

select*
FROM fact_outage_incident;


select*
FROM fact_sla_performance;

SELECT TOP (20)
    Date_ID,
    Full_Date
FROM Dim_Date;
 
 SELECT *
FROM Dim_Date
WHERE CAST(Date_ID AS DATE) = Full_Date;

SELECT *
FROM Dim_Date
WHERE Date_ID = Full_Date;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Dim_Date';


 -- 1. How many outage incidents are there?

 SELECT COUNT (*) AS TOTAL_OUTAGES
FROM fact_outage_incident;

--2. Root causes of the outage

SELECT COUNT (*) AS TOTAL_ROOTCAUSE
FROM dim_root_cause;

--3. How much total downtime occured (Total Service Disruptions)

SELECT SUM(Duration_Minutes) AS Total_Downtime
FROM fact_outage_incident;

--4 What is the average duration of service disruption?

SELECT AVG(Duration_Minutes) AS Average_Disruption_Duration
FROM fact_outage_incident;


--5 THE REGIONS WHERE OUTAGES OCCURED

SELECT Distinct region
FROM dim_site;

--6 WHICH REGION HAVE THE MOST OUTAGES

SELECT s.region, COUNT(*) AS Total_Outages
FROM fact_outage_incident f
JOIN dim_site s
ON f.Site_ID = s.Site_ID
GROUP BY s.region
ORDER BY Total_Outages DESC;

--7 WHICH TECHNOLOGIES HAD MORE OUTAGES

SELECT s.Technology, COUNT(*) AS Total_Outages
FROM fact_outage_incident f
JOIN dim_site s
ON f.Site_ID = s.Site_ID
GROUP BY s.Technology
ORDER BY Total_Outages DESC;

--8 WHICH VENDORS HAD MORE OUTAGES

SELECT v. Vendor_Name, COUNT(*) AS Vendor_Outages
FROM fact_outage_incident f
JOIN dim_vendor v
ON f.vendor_ID = v.vendor_ID
GROUP BY v. Vendor_Name
ORDER BY Vendor_Outages DESC;

--9 WHICH SITES HAVE THE MOST OUTAGES

SELECT s.Site_Name, COUNT(*) AS Total_Site_Outages
FROM fact_outage_incident f
JOIN dim_site s
ON f.site_ID = s. site_ID
GROUP BY s.Site_Name
ORDER BY Total_Site_Outages DESC;

-- 10 The site with repeated incidents 

SELECT
    s.Site_Name,
    COUNT(*) AS Total_Site_Outages
FROM Fact_Outage_Incident f
JOIN Dim_Site s
    ON f.Site_ID = s.Site_ID
GROUP BY s.Site_Name
HAVING COUNT(*) > 1
ORDER BY Total_Site_Outages DESC;


--11 Site type
SELECT s.Site_Type, COUNT(*) AS Total_Site_Outages
FROM fact_outage_incident f
JOIN dim_site s
ON f.site_ID = s. site_ID
GROUP BY s.Site_Type
ORDER BY Total_Site_Outages DESC;


--12 Which root-causes occur most often

SELECT r.Root_Cause_Category, COUNT(*) AS Total_Outages
FROM fact_outage_incident f
JOIN dim_root_cause r
ON f.root_cause_ID = r. root_cause_ID
GROUP BY r.Root_Cause_Category
ORDER BY Total_Outages DESC;

--- 13 Top 5 root causes of outages
SELECT TOP (5)
    r.Root_Cause_Category, r.responsible_Team,
    COUNT(*) AS Total_Outages, SUM (f.Customers_affected) AS Total_Customers_Affected
FROM Fact_Outage_Incident f
LEFT JOIN Dim_Root_Cause r
    ON f.Root_Cause_ID = r.Root_Cause_ID
GROUP BY r.Root_Cause_Category, r.responsible_Team
ORDER BY Total_Outages DESC;

--14 Which root-causes create the longest outages

SELECT r.Root_Cause_Category, AVG(f.Duration_Minutes) AS Total_Outages
FROM fact_outage_incident f
JOIN dim_root_cause r
ON f.root_cause_ID = r. root_cause_ID
GROUP BY r.Root_Cause_Category
ORDER BY Total_Outages DESC;

--15 How many customers were affected

SELECT SUM (CUSTOMERS_AFFECTED) AS TOTAL_CUSTOMERS_AFFECTED
FROM fact_outage_incident;

--16 Top 10 customers affected
SELECT TOP (10)
    Incident_ID,
    Customers_Affected, Element_Type
FROM Fact_Outage_Incident
ORDER BY Customers_Affected DESC;

--17 Customers affected by incidents

SELECT Incident_ID, customers_affected,Element_Type, severity_level, Duration_Minutes
FROM  fact_outage_incident
ORDER BY Customers_Affected DESC;

--18 Top 5 customers affected by incident

SELECT TOP (5) Incident_ID, customers_affected,Element_Type, severity_level, Duration_Minutes
FROM  fact_outage_incident
ORDER BY Customers_Affected DESC;

--19 Top 5 highest customer_impact outages and SLA compliance
SELECT TOP (5) f.Incident_ID, f.customers_affected, f.Element_Type, f.severity_level, f.Duration_Minutes,s.SLA_Target_Minutes, s.SLA_Complied, s.Violation_Reason
FROM  fact_outage_incident f
LEFT JOIN fact_sla_performance s
ON f.Incident_ID = s.Incident_ID
ORDER BY Customers_Affected DESC;

--20 Top 10 highest customer_impact outages and SLA compliance
SELECT TOP (10) f.Incident_ID, f.customers_affected, f.Element_Type, f.severity_level, f.Duration_Minutes,s.SLA_Target_Minutes, s.SLA_Complied, s.Violation_Reason
FROM  fact_outage_incident f
LEFT JOIN fact_sla_performance s
ON f.Incident_ID = s.Incident_ID
ORDER BY Customers_Affected DESC;

--21 Top 10 Outage Duration Compared with SLA Targets
SELECT TOP (10) f.Incident_ID, f.customers_affected, f.Element_Type, f.severity_level, f.Duration_Minutes,s.SLA_Target_Minutes, s.SLA_Complied, s.Violation_Reason
FROM  fact_outage_incident f
LEFT JOIN fact_sla_performance s
ON f.Incident_ID = s.Incident_ID
ORDER BY Duration_Minutes DESC;

--22 Number of Customers affected categorised by the root causes of outage

SELECT
    r.Root_Cause_Category,
    SUM(f.Customers_Affected) AS Total_Customers_Affected
FROM Fact_Outage_Incident f
JOIN Dim_Root_Cause r
    ON f.Root_Cause_ID = r.Root_Cause_ID
GROUP BY r.Root_Cause_Category
ORDER BY Total_Customers_Affected DESC;

--23 Customer Segment affected

SELECT
    cs.Customer_Segment,
    COUNT(*) AS Total_Outages
FROM Fact_Customer_Complaint cc
JOIN Dim_Customer_Segment cs
    ON cc.Customer_ID = cs.Customer_ID
GROUP BY cs.Customer_Segment
ORDER BY Total_Outages DESC;


---SLA BREACHES
--24 Outages that breached the SLA

SELECT COUNT(*) AS SLA_Breaches
FROM fact_sla_performance
WHERE SLA_ComplIed = 0;



--25 Regions with most SLA breaches
SELECT
    s.Region,
    COUNT(*) AS SLA_Breaches
FROM Fact_Outage_Incident f
JOIN Dim_Site s
    ON f.Site_ID = s.Site_ID
WHERE f.SLA_Breached = 1
GROUP BY s.Region
ORDER BY SLA_Breaches DESC;


--26 Root causes that gave most SLA breaches
SELECT
    r.Root_Cause_Category,
    COUNT(*) AS SLA_Breaches
FROM Fact_Outage_Incident f
JOIN Dim_Root_Cause r
    ON f.Root_Cause_ID = r.Root_Cause_ID
WHERE f.SLA_Breached = 1
GROUP BY r.Root_Cause_Category
ORDER BY SLA_Breaches DESC;

--27 Which vendor had most SLA breaches

SELECT
    v.Vendor_Name,
    COUNT(*) AS SLA_Breaches
FROM Fact_Outage_Incident f
JOIN Dim_Site s
    ON f.Site_ID = s.Site_ID
JOIN Dim_Vendor v
    ON s.Vendor = v.Vendor_Name
WHERE f.SLA_Breached = 1
GROUP BY v.Vendor_Name
ORDER BY SLA_Breaches DESC;

--- or this
SELECT
    s.Vendor,
    COUNT(*) AS SLA_Breaches
FROM Fact_Outage_Incident f
JOIN Dim_Site s
    ON f.Site_ID = s.Site_ID
WHERE f.SLA_Breached = 1
GROUP BY s.Vendor
ORDER BY SLA_Breaches DESC;

---MTTR (Mean Time to Repair)

--28 Mean Time To Repair Outage

SELECT
    AVG(Duration_Minutes) AS MTTR_Minutes
FROM Fact_Outage_Incident;

--29 Mean Time To Repair outage categorised by root cause

SELECT
    r.Root_Cause_Category,Duration_Minutes AS MTTR_Minutes
FROM Fact_Outage_Incident f
JOIN Dim_Root_Cause r
    ON f.Root_Cause_ID = r.Root_Cause_ID
ORDER BY MTTR_Minutes DESC;

--30 Mean Time To Repair outage categorised by Region and Vendor

SELECT
    s.Region,s.Vendor, Duration_Minutes AS MTTR_Minutes
FROM Fact_Outage_Incident f
JOIN dim_site s
    ON f.Site_ID = s.Site_ID
ORDER BY MTTR_Minutes DESC;

---- Views

--31 Create view from fact_outage_incident table to spearate dtaetime to date and time 
CREATE VIEW Outage_incident_vw AS
SELECT incident_ID, Site_ID, Element_ID, Element_Type, Vendor_ID, Root_cause_ID, CAST(Incident_Start_Time AS Date) AS Start_Date, 
CAST (Incident_Start_Time AS TIME) AS Start_Time,
CAST(Incident_End_Time AS Date) AS End_Date, CAST (Incident_End_Time AS Time) AS End_Time, 
Duration_Minutes, Severity_Level, Customers_Affected, SLA_Breached,Alarm_Count, Is_Resolved_Within_SLA, Business_Impact_Score
FROM fact_outage_incident;

-- 32 Create view from Alarm_log table to spearate dtaetime to date and time 

CREATE VIEW Alarm_Time_vw AS
SELECT Alarm_ID, incident_ID, Site_ID, Element_ID, CAST(Alarm_Time AS Date) AS Alarm_Date, 
CAST (Alarm_Time AS Time) AS Alarm_Time, Alarm_Severity Auto_Resolved
FROM fact_alarm_log

--33 CORRECTED MISTAENLY OMMITED COMMA BETWEEN ALARM SEVRITY AND ALARM RESOLVED

ALTER VIEW Alarm_Time_vw AS
SELECT
    Alarm_ID,
    Incident_ID,
    Site_ID,
    Element_ID,
    CAST(Alarm_Time AS DATE) AS Alarm_Date,
    CAST(Alarm_Time AS TIME) AS Alarm_Time,
    Alarm_Severity,
    Auto_Resolved
FROM Fact_Alarm_Log;

--34 Create view for Complaint_Time table to spearate dtaetime to date and time 

CREATE VIEW Complaint_Time_vw AS
SELECT Complaint_ID, incident_ID, Customer_ID, CAST(Complaint_Time AS Date) AS Complaint_Date, 
CAST (Complaint_Time AS Time) AS Complaint_Time, Complaint_Channel, Complaint_Severity, Is_Resolved, Compensation_Amount
From fact_customer_complaint;

--MTTD
--35  Mean Time To Detect the Outage

SELECT
    ROUND(AVG(DATEDIFF(MINUTE,
        f.Start_Time,
        a.Alarm_Time)), 1) AS MTTD_Minutes
FROM Outage_Incident_vw f
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID;

--36 MTTD categorised by severity level
SELECT
    f.Severity_Level,
    ROUND(AVG(DATEDIFF(MINUTE,
        f.Start_Time,
        a.Alarm_Time)),1) AS Average_MTTD_Minutes
FROM Outage_Incident_vw f
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID
GROUP BY f.Severity_Level
ORDER BY Average_MTTD_Minutes;

--37 Top 10 incidents that took the longest time to detect in comparison to the detection delay, outage duration and SLA targets.

SELECT TOP (10)
    f.Incident_ID, f.Element_Type,
    f.Start_Time,
    a.Alarm_Time,f.Duration_Minutes, s.SLA_Target_Minutes,
    DATEDIFF(MINUTE,
        f.Start_Time,
        a.Alarm_Time) AS Detection_Minutes
FROM Outage_Incident_vw f
JOIN fact_sla_performance s
ON f.Incident_ID = s.Incident_ID
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID
ORDER BY Detection_Minutes DESC;

--38 Root cause with longest detection
SELECT
    r.Root_Cause_Category,
    ROUND(AVG(DATEDIFF(MINUTE,
        f.Start_Time,
        a.Alarm_Time)),1) AS Average_MTTD
FROM Outage_Incident_vw f
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID
JOIN Dim_Root_Cause r
    ON f.Root_Cause_ID = r.Root_Cause_ID
GROUP BY r.Root_Cause_Category
ORDER BY Average_MTTD DESC;

--39 Slowest outage detection by site

SELECT
    s.Site_Name,
    ROUND(AVG(DATEDIFF(MINUTE,
        f.Start_Time,
        a.Alarm_Time)),1) AS Average_MTTD
FROM Outage_Incident_vw f
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID
JOIN Dim_Site s
    ON f.Site_ID = s.Site_ID
GROUP BY s.Site_Name
ORDER BY Average_MTTD DESC;

--40 Slowest outage detection by region and Vendor

SELECT
    s.Region, s.Vendor,
    ROUND(AVG(DATEDIFF(MINUTE,
        f.Start_Time,
        a.Alarm_Time)),1) AS Average_MTTD
FROM Outage_Incident_vw f
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID
JOIN Dim_Site s
    ON f.Site_ID = s.Site_ID
GROUP BY s.Region, s.Vendor
ORDER BY Average_MTTD DESC;

---MTTD VIEW

CREATE VIEW MTTD_vw AS
SELECT
    f.Incident_ID,
    DATEDIFF(
        MINUTE,
        f.Incident_Start_Time,
        a.Alarm_Time
    ) AS Detection_Minutes
FROM fact_outage_incident f
JOIN fact_alarm_log a
    ON f.Incident_ID = a.Incident_ID;

    ALTER VIEW MTTD_vw AS
SELECT
    f.Incident_ID,
    CAST(f.Incident_Start_Time AS DATE) AS Incident_Date,
    DATEDIFF(
        MINUTE,
        f.Incident_Start_Time,
        a.Alarm_Time
    ) AS Detection_Minutes
FROM fact_outage_incident f
JOIN fact_alarm_log a
    ON f.Incident_ID = a.Incident_ID;

SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN SLA_Complied = 1 THEN 1 ELSE 0 END) AS Complied,
    SUM(CASE WHEN SLA_Complied = 0 THEN 1 ELSE 0 END) AS Breached
FROM fact_sla_performance;

SELECT f.Incident_ID
FROM fact_outage_incident f
LEFT JOIN fact_sla_performance s
    ON f.Incident_ID = s.Incident_ID
WHERE s.Incident_ID IS NULL;


SELECT TOP 10 *
FROM MTTD_vw;

SELECT TOP 20
    f.Incident_ID,
    f.Start_Time,
    a.Alarm_Time,
    DATEDIFF(MINUTE, f.Start_Time, a.Alarm_Time) AS Detection_Minutes
FROM Outage_Incident_vw f
JOIN Alarm_Time_vw a
    ON f.Incident_ID = a.Incident_ID
WHERE DATEDIFF(MINUTE, f.Start_Time, a.Alarm_Time) < 0
ORDER BY Detection_Minutes;


SELECT TOP 5
    Start_Time
FROM Outage_Incident_vw;

SELECT TOP 5
    Alarm_Time
FROM Alarm_Time_vw;






   

    




