--1 Admission, BedOccupancy and Staffing table check
Select * 
From Admissions;

Select * 
From BedOccupancy;

Select * 
From Staffing;

--2) Counting number of rows in each table
SELECT 'Admissions' AS TableName, COUNT(*) AS NumberOfRows
FROM Admissions

UNION ALL

SELECT 'BedOccupancy', COUNT(*)
FROM BedOccupancy

UNION ALL

SELECT 'Staffing', COUNT(*)
FROM Staffing;

--3) Checking Data Types
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('Admissions', 'BedOccupancy', 'Staffing')
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
--4) Dropping Checks Calculated columns from Power Query in admissions table
    ALTER TABLE Admissions
DROP COLUMN DATE_CHECK,
            LOS_HOURS_CALCULATED,
            LOS_CHECK;

---5) Dropping Checks Calculated columns from Power Query in BedOccupancy Table
ALTER TABLE BedOccupancy
DROP COLUMN Occupancy,
            Staffing_Capacity,
            Closed_beds_observation;
--6) Changing Data Type of length_of_stay_hours to Decimal
ALTER TABLE Admissions
ALTER COLUMN length_of_stay_hours DECIMAL(10,2) NOT NULL;

--7) Final Columns
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('Admissions', 'BedOccupancy', 'Staffing')
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
---8) Null checks in admissions table
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS NullPatientID,
    SUM(CASE WHEN admission_id IS NULL THEN 1 ELSE 0 END) AS NullAdmissionID,
    SUM(CASE WHEN admission_datetime IS NULL THEN 1 ELSE 0 END) AS NullAdmissionDate,
    SUM(CASE WHEN discharge_datetime IS NULL THEN 1 ELSE 0 END) AS NullDischargeDate,
    SUM(CASE WHEN admission_type IS NULL THEN 1 ELSE 0 END) AS NullAdmissionType,
    SUM(CASE WHEN admission_source IS NULL THEN 1 ELSE 0 END) AS NullAdmissionSource,
    SUM(CASE WHEN specialty IS NULL THEN 1 ELSE 0 END) AS NullSpecialty,
    SUM(CASE WHEN ward IS NULL THEN 1 ELSE 0 END) AS NullWard,
    SUM(CASE WHEN bed_type IS NULL THEN 1 ELSE 0 END) AS NullBedType,
    SUM(CASE WHEN length_of_stay_hours IS NULL THEN 1 ELSE 0 END) AS NullLOS,
    SUM(CASE WHEN discharge_destination IS NULL THEN 1 ELSE 0 END) AS NullDischargeDestination,
    SUM(CASE WHEN hospital IS NULL THEN 1 ELSE 0 END) AS NullHospital
FROM Admissions;

--9) Null checks in BedOccupancy Table

SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN datetime IS NULL THEN 1 ELSE 0 END) AS NullDateTime,
    SUM(CASE WHEN hospital IS NULL THEN 1 ELSE 0 END) AS NullHospital,
    SUM(CASE WHEN ward IS NULL THEN 1 ELSE 0 END) AS NullWard,
    SUM(CASE WHEN bed_type IS NULL THEN 1 ELSE 0 END) AS NullBedType,
    SUM(CASE WHEN total_beds IS NULL THEN 1 ELSE 0 END) AS NullTotalBeds,
    SUM(CASE WHEN staffed_beds IS NULL THEN 1 ELSE 0 END) AS NullStaffedBeds,
    SUM(CASE WHEN occupied_beds IS NULL THEN 1 ELSE 0 END) AS NullOccupiedBeds,
    SUM(CASE WHEN closed_beds IS NULL THEN 1 ELSE 0 END) AS NullClosedBeds
FROM BedOccupancy;

--10) Nulls checks in Staffing Table

SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS NullDate,
    SUM(CASE WHEN hospital IS NULL THEN 1 ELSE 0 END) AS NullHospital,
    SUM(CASE WHEN ward IS NULL THEN 1 ELSE 0 END) AS NullWard,
    SUM(CASE WHEN staff_role IS NULL THEN 1 ELSE 0 END) AS NullStaffRole,
    SUM(CASE WHEN planned_staff IS NULL THEN 1 ELSE 0 END) AS NullPlannedStaff,
    SUM(CASE WHEN actual_staff IS NULL THEN 1 ELSE 0 END) AS NullActualStaff,
    SUM(CASE WHEN safe_ratio_met IS NULL THEN 1 ELSE 0 END) AS NullSafeRatio
FROM Staffing;

--11) Duplicates in Admission Table
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT admission_id) AS DistinctAdmissionIDs
FROM Admissions;

--12) Chcecking BedOccupancy Uniqueness- if the combination appear more than once
SELECT
    datetime,
    hospital,
    ward,
    bed_type,
    COUNT(*) AS NumberOfRecords
FROM BedOccupancy
GROUP BY
    datetime,
    hospital,
    ward,
    bed_type
HAVING COUNT(*) > 1;

--13) Staffing Grain/ duplicates check

SELECT
    date,
    hospital,
    ward,
    staff_role,
    COUNT(*) AS NumberOfRecords
FROM Staffing
GROUP BY
    date,
    hospital,
    ward,
    staff_role
HAVING COUNT(*) > 1;


--- 14)  Number of hospitals

SELECT
    COUNT(DISTINCT hospital) AS NumberOfHospitals
FROM Admissions;

--15) Number of Admissions each hospital have

SELECT
    hospital,
    COUNT(*) AS TotalAdmissions
FROM Admissions
GROUP BY hospital
ORDER BY TotalAdmissions DESC;

--16 Admissions and Admission types
SELECT
    admission_type,
    COUNT(*) AS TotalAdmissions
FROM Admissions
GROUP BY admission_type
ORDER BY TotalAdmissions DESC;

--17 Admissions by Specialities 

SELECT
    specialty,
    COUNT(*) AS TotalAdmissions
FROM Admissions
GROUP BY specialty
ORDER BY TotalAdmissions DESC;

--18 Admission by Admission Source

SELECT 
       admission_source,
       Count(*) AS Total_admission_source
FROM Admissions
GROUP BY admission_source
ORDER BY Total_admission_source DESC;

--19 Average Lenght of Stay by Speciality

SELECT
    specialty,
    COUNT(*) AS TotalAdmissions,
    AVG(length_of_stay_hours) AS AverageLOSHours
FROM Admissions
GROUP BY specialty
ORDER BY AverageLOSHours DESC;

--20 Admissions by Discharge Destination

SELECT
    discharge_destination,
    COUNT(*) AS TotalDischarges
FROM Admissions
GROUP BY discharge_destination
ORDER BY TotalDischarges DESC;

--21 Hospital with longest avaerage lenght of stay
SELECT
    hospital,
    AVG(length_of_stay_hours) AS AverageLOSHours
FROM Admissions
GROUP BY hospital
ORDER BY AverageLOSHours DESC;

--22 Ward with longest avaerage lenght of stay

SELECT
    ward,
    AVG(length_of_stay_hours) AS AverageLOSHours
FROM Admissions
GROUP BY ward
ORDER BY AverageLOSHours DESC;

--23 Dates with high admission demand

SELECT
    CAST(admission_datetime AS DATE) AS AdmissionDate,
    COUNT(*) AS TotalAdmissions
FROM Admissions
GROUP BY CAST(admission_datetime AS DATE)
ORDER BY AdmissionDate;

--24 Months that have most admissions

SELECT
    YEAR(admission_datetime) AS AdmissionYear,
    MONTH(admission_datetime) AS AdmissionMonth,
    COUNT(*) AS TotalAdmissions
FROM Admissions
GROUP BY
    YEAR(admission_datetime),
    MONTH(admission_datetime)
ORDER BY
    AdmissionYear,
    AdmissionMonth;

--25 capacity breach check

SELECT
    hospital,
    ward,
    bed_type,
    datetime,
    staffed_beds,
    occupied_beds
FROM BedOccupancy
WHERE occupied_beds > staffed_beds
ORDER BY datetime;

--26 occupancy pressure occurence

SELECT
    hospital,
    ward,
    bed_type,
    AVG(
        CAST(occupied_beds AS DECIMAL(10,2))
        / NULLIF(staffed_beds, 0)
    ) * 100 AS AverageOccupancyPercent
FROM BedOccupancy
GROUP BY
    hospital,
    ward,
    bed_type
ORDER BY AverageOccupancyPercent DESC;

--27 Top 20 highest occupancy

SELECT TOP 20
    hospital,
    ward,
    bed_type,
    datetime,
    staffed_beds,
    occupied_beds,
    CAST(occupied_beds AS DECIMAL(10,2))
        / NULLIF(staffed_beds, 0) * 100 AS OccupancyPercent
FROM BedOccupancy
WHERE staffed_beds > 0
ORDER BY OccupancyPercent DESC;

--28 Least 20 occupancy 
SELECT TOP 20
    hospital,
    ward,
    bed_type,
    datetime,
    staffed_beds,
    occupied_beds,
    CAST(occupied_beds AS DECIMAL(10,2))
        / NULLIF(staffed_beds, 0) * 100 AS OccupancyPercent
FROM BedOccupancy
WHERE staffed_beds > 0
ORDER BY OccupancyPercent ASC;

--29 Average spare beds

SELECT
    hospital,
    ward,
    bed_type,
    AVG(staffed_beds - occupied_beds) AS AverageSpareBeds
FROM BedOccupancy
GROUP BY
    hospital,
    ward,
    bed_type
ORDER BY AverageSpareBeds DESC;

--30 Closed bed space
SELECT
    hospital,
    ward,
    bed_type,
    MAX(closed_beds) AS ClosedBeds
FROM BedOccupancy
GROUP BY
    hospital,
    ward,
    bed_type
ORDER BY ClosedBeds DESC;

--- 31 How many bed spaces in the hospital
SELECT count(Distinct Hospital) as Total_hospitals, sum (staffed_beds) as Total_beds
From BedOccupancy
Order by Total_beds;



--- 31 How many bed spaces in the hospital
SELECT
    COUNT(DISTINCT hospital) AS Total_Hospitals,
    SUM(StaffedBeds) AS Total_Staffed_Beds
FROM (
    SELECT
        hospital,
        ward,
        bed_type,
        MAX(staffed_beds) AS StaffedBeds
    FROM BedOccupancy
    GROUP BY
        hospital,
        ward,
        bed_type
) AS BedCapacity;


--32 Planned versus Actual Staffing

SELECT
    hospital,
    ward,
    staff_role,
    AVG(planned_staff) AS AveragePlannedStaff,
    AVG(actual_staff) AS AverageActualStaff
FROM Staffing
GROUP BY
    hospital,
    ward,
    staff_role
ORDER BY AverageActualStaff ASC;

--33 Staffing Gap (shortages )

SELECT
    hospital,
    ward,
    staff_role,
    planned_staff,
    actual_staff,
    planned_staff - actual_staff AS StaffingGap
FROM Staffing
WHERE actual_staff < planned_staff
ORDER BY StaffingGap DESC;

--34 Staffng

SELECT
    hospital,
    ward,
    staff_role,
    COUNT(*) AS StaffingRecords
FROM Staffing
GROUP BY
    hospital,
    ward,
    staff_role
ORDER BY StaffingRecords DESC;

---Hospital Mapping

SELECT
    hospital AS HospitalCode,
    'Hospital ' + CHAR(64 + ROW_NUMBER() OVER (ORDER BY hospital)) AS HospitalLabel
FROM (
    SELECT DISTINCT hospital
    FROM Admissions
) AS Hospitals
ORDER BY hospital;

---Mapping view
CREATE VIEW HospitalMapping AS
SELECT
    hospital AS HospitalCode,
    'Hospital ' + CAST(
        ROW_NUMBER() OVER (ORDER BY hospital)
        AS varchar(2)
    ) AS HospitalLabel
FROM (
    SELECT DISTINCT hospital
    FROM Admissions
) AS Hospitals;

---Checking Mapping View
SELECT *
FROM HospitalMapping
ORDER BY HospitalCode;
