USE healthcare;

CREATE TABLE staging (
	encounter_id VARCHAR(25),
    patient_id VARCHAR(25),
    race VARCHAR(25),
    gender VARCHAR(7),
    age VARCHAR(10),
    admission_type_id TINYINT UNSIGNED,
    discharge_disposition_id TINYINT UNSIGNED,
    discharge_cleaned SMALLINT UNSIGNED,
    admission_source_id TINYINT UNSIGNED,
    time_in_hospital TINYINT UNSIGNED,
    medical_specialty VARCHAR(50),
    num_lab_procedures SMALLINT UNSIGNED,
    num_procedures SMALLINT UNSIGNED,
    num_medications SMALLINT UNSIGNED,
    number_outpatient TINYINT UNSIGNED,
    number_emergency TINYINT UNSIGNED,
    number_inpatient TINYINT UNSIGNED,
    diag_1 VARCHAR(10),
    diag_2 VARCHAR(10),
    diag_3 VARCHAR(10),
    number_diagnoses TINYINT UNSIGNED,
    metformin VARCHAR(10), 
    repaglinide VARCHAR(10),
    nateglinide VARCHAR(10),
    chlorpropamide VARCHAR(10),
    glimepiride VARCHAR(10),
    acetohexamide VARCHAR(10),
    glipizide VARCHAR(10),
    glyburide VARCHAR(10),
    tolbutamide VARCHAR(10),
    pioglitazone VARCHAR(10),
    rosiglitazone VARCHAR(10),
    acarbose VARCHAR(10),
    troglitazone VARCHAR(10),
    tolazamide VARCHAR(10),
    insulin VARCHAR(10),
    `change` VARCHAR(12),
    diabetesMed VARCHAR(5),
    readmitted VARCHAR(5),
    readmitted2 VARCHAR(5)
);

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:\\Users\\dwill\\sql\\diabeticdata.csv'
INTO TABLE staging
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(encounter_id, patient_id, race, gender, age, admission_type_id, discharge_disposition_id, discharge_cleaned, admission_source_id, time_in_hospital,
 medical_specialty, num_lab_procedures, num_procedures, num_medications, number_outpatient, number_emergency, number_inpatient, diag_1, diag_2,
 diag_3, number_diagnoses, metformin, repaglinide, nateglinide, chlorpropamide, glimepiride, acetohexamide, glipizide, glyburide, tolbutamide,
pioglitazone, rosiglitazone, acarbose, troglitazone, tolazamide, insulin, `change`, diabetesMed, readmitted, readmitted2);

SELECT * FROM staging;
SET GLOBAL local_infile = 0;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

CREATE TABLE diabetic_data LIKE staging;
INSERT INTO diabetic_data SELECT * FROM staging;
SELECT * FROM diabetic_data LIMIT 10;

ALTER TABLE diabetic_data
DROP COLUMN readmitted2;

SELECT * FROM diabetic_data LIMIT 10;

-- Calculate the total number of patient encounters in the healthcare dataset --
SELECT COUNT(encounter_id) FROM diabetic_data;
SELECT COUNT(DISTINCT encounter_id) FROM diabetic_data;

SELECT COUNT(patient_id) FROM diabetic_data;
SELECT COUNT(DISTINCT patient_id) FROM diabetic_data;

-- Identify the top 10 most frequent diagnoses in the dataset --
SELECT 
	diag_1, 
    COUNT(*) AS Diagnosis_Count
FROM diabetic_data
GROUP BY diag_1
ORDER BY Diagnosis_Count DESC
LIMIT 10;

-- Calculate the average length of hospital stay for each admission type --
SELECT 
	admission_type_id AS Admission_Type, 
    ROUND(AVG(time_in_hospital)) AS Average_Days
FROM diabetic_data
GROUP BY admission_type_id
ORDER BY Admission_Type DESC;

-- Determine the number of readmitted patients and the percentage of total encounters that they represent --
SELECT 
    readmitted AS Readmitted,
    COUNT(DISTINCT patient_id) AS Number_of_Patients,
    COUNT(encounter_id) AS Total_Encounters,
    (COUNT(encounter_id) * 100.0 / (SELECT COUNT(*) FROM diabetic_data)) AS Perent_Of_All_Encounters
FROM diabetic_data
GROUP BY Readmitted;

-- Identify the age distribution of patients --
SELECT
	DISTINCT(age),
    COUNT(DISTINCT patient_id) AS Patients
FROM diabetic_data
GROUP BY age;

-- Identify the average number of procedures for patients aged 20-30 -- 
SELECT 
	AVG(num_procedures) AS Average_Procedures
FROM diabetic_data
WHERE age IN ('20-30');

-- Calculate the average number of medications prescribed for patients in each age group --
SELECT 
	DISTINCT(age) AS Age_Groups,
    ROUND(AVG(num_medications)) AS Average_Num_Of_Medications
FROM diabetic_data
GROUP BY age;

-- Identify the distribution of readmission rates across different races --

-- Raw Numbers Distribution -- 
SELECT
	race,
       SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS No_Readmission,
       SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS Within_30_Days,
       SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END) AS After_30_Days,
       COUNT(*) AS Total_Encounters
FROM diabetic_data
GROUP BY race
ORDER BY Total_Encounters DESC;

-- Percentage Distribution -- 
SELECT race,
	ROUND(SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS No_Readmission,
	ROUND(SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Within_30_Days,
	ROUND(SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS After_30_days
FROM diabetic_data
GROUP BY race
ORDER BY race;

-- Identify the distribution of discharge dispositions -- 

SELECT 
    ROUND(SUM(CASE WHEN discharge_cleaned = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Discharged_To_Home,
    ROUND(SUM(CASE WHEN discharge_cleaned = '2' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Discharged_To_Hospital,
    ROUND(SUM(CASE WHEN discharge_cleaned = '3' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Expired,
    ROUND(SUM(CASE WHEN discharge_cleaned = '999' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS No_Data
FROM diabetic_data;

SELECT
count(patient_id)
FROM diabetic_data;

SELECT
count(patient_id)
FROM staging;