-- DATABASE SETUP
CREATE DATABASE IF NOT EXISTS employee;
USE employee;


-- TABLE SETUP
CREATE TABLE IF NOT EXISTS proj_table (
    PROJECT_ID VARCHAR(10) PRIMARY KEY,
    PROJ_NAME VARCHAR(100),
    DOMAIN VARCHAR(50),
    START_DATE VARCHAR(20),
    CLOSURE_DATE VARCHAR(20),
    DEV_QTR VARCHAR(10),
    STATUS VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS emp_record_table (
    EMP_ID VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    `ROLE` VARCHAR(100),
    DEPT VARCHAR(50),
    EXP INT,
    COUNTRY VARCHAR(50),
    CONTINENT VARCHAR(50),
    SALARY DECIMAL(10,2),
    EMP_RATING INT,
    MANAGER_ID VARCHAR(10),
    PROJ_ID VARCHAR(10),
    CONSTRAINT fk_emp_project
        FOREIGN KEY (PROJ_ID) REFERENCES proj_table(PROJECT_ID)
);

CREATE TABLE IF NOT EXISTS data_science_team (
    EMP_ID VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    `ROLE` VARCHAR(100),
    DEPT VARCHAR(50),
    EXP INT,
    COUNTRY VARCHAR(50),
    CONTINENT VARCHAR(50),
    CONSTRAINT fk_ds_employee
        FOREIGN KEY (EMP_ID) REFERENCES emp_record_table(EMP_ID)
);


-- Q1. Show employee ID, name, gender, and department.
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    DEPT AS DEPARTMENT
FROM emp_record_table;


-- Q2. Show employees with ratings below 2, above 4, and from 2 to 4.

-- Rating below 2
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER,
       DEPT AS DEPARTMENT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING < 2;

-- Rating above 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER,
       DEPT AS DEPARTMENT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING > 4;

-- Rating from 2 to 4, including both endpoints
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER,
       DEPT AS DEPARTMENT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING BETWEEN 2 AND 4;


-- Q3. Show the full names of employees in Finance.
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME
FROM emp_record_table
WHERE DEPT = 'Finance';


-- Q4. Show employees who are Managers, Presidents, or CEOs.
SELECT EMP_ID, FIRST_NAME, `ROLE`, DEPT AS DEPARTMENT
FROM emp_record_table
WHERE `ROLE` IN ('Manager', 'President', 'CEO');


-- Q5. Show employees in Healthcare or Finance.
SELECT *
FROM emp_record_table
WHERE DEPT = 'Healthcare'

UNION ALL

SELECT *
FROM emp_record_table
WHERE DEPT = 'Finance';


-- Q6. Show each employee's rating and the maximum rating in their department.
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    `ROLE`,
    DEPT AS DEPARTMENT,
    EMP_RATING,
    MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_DEPT_RATING
FROM emp_record_table
ORDER BY DEPT, EMP_ID;


-- Q7. Show the minimum and maximum salary for each role.
SELECT
    `ROLE`,
    MIN(SALARY) AS MIN_SALARY,
    MAX(SALARY) AS MAX_SALARY
FROM emp_record_table
GROUP BY `ROLE`
ORDER BY `ROLE`;


-- Q8. Rank employees by experience, from highest to lowest.
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    RANK() OVER (ORDER BY EXP DESC) AS EXPERIENCE_RANK
FROM emp_record_table
ORDER BY EXP DESC;


-- Q9. Create and display a view of employees earning over 6000.
CREATE OR REPLACE VIEW high_salary_country_employees AS
SELECT EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY, SALARY
FROM emp_record_table
WHERE SALARY > 6000;

SELECT *
FROM high_salary_country_employees;


-- Q10. Show employees with more than 10 years of experience.
SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP
FROM (
    SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP
    FROM emp_record_table
    WHERE EXP > 10
) AS experienced_employees;


-- Q11. Check whether each data science team member has the expected role.
DROP FUNCTION IF EXISTS expected_ds_role;

CREATE FUNCTION expected_ds_role(p_exp INT)
RETURNS VARCHAR(50)
DETERMINISTIC
RETURN CASE
    WHEN p_exp <= 2  THEN 'JUNIOR DATA SCIENTIST'
    WHEN p_exp <= 5  THEN 'ASSOCIATE DATA SCIENTIST'
    WHEN p_exp <= 10 THEN 'SENIOR DATA SCIENTIST'
    WHEN p_exp <= 12 THEN 'LEAD DATA SCIENTIST'
    WHEN p_exp <= 16 THEN 'MANAGER'
    ELSE 'OUT OF RANGE'
END;

SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    `ROLE` AS ASSIGNED_ROLE,
    expected_ds_role(EXP) AS EXPECTED_ROLE,
    CASE
        WHEN UPPER(TRIM(`ROLE`)) = expected_ds_role(EXP) THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS ROLE_CHECK
FROM data_science_team
ORDER BY EMP_ID;


-- Q12. Calculate each employee's bonus as 5% of salary times rating.
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    SALARY,
    EMP_RATING,
    ROUND(SALARY * 0.05 * EMP_RATING, 2) AS BONUS
FROM emp_record_table
ORDER BY EMP_ID;


-- Q13. Show average salary by continent and country.
SELECT
    CONTINENT,
    COUNTRY,
    ROUND(AVG(SALARY), 2) AS AVG_SALARY
FROM emp_record_table
GROUP BY CONTINENT, COUNTRY
ORDER BY CONTINENT, COUNTRY;