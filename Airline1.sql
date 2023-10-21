CREATE DATABASE AIRLINE1;
USE AIRLINE1;

-- Data Import preparation 
CREATE TABLE airlinedata (
passenger_id VARCHAR (255),
first_name VARCHAR (255),
last_name  VARCHAR (255),
gender VARCHAR (255),
age VARCHAR (255),
nationality VARCHAR (255),
airport_name VARCHAR (255),
airport_country_code VARCHAR (255),
country_name VARCHAR (255),
airport_continent VARCHAR (255),
continents VARCHAR (255),
departure_date VARCHAR (255),
arrival_airport VARCHAR (255),
pilot_name VARCHAR (255),
flight_status VARCHAR (255)
);

LOAD DATA LOCAL INFILE 'C:/Users/denve/Downloads/archive (3)/Airline Dataset Updated - v1.csv'
INTO TABLE airlinedata
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';

-------------------------------------------------------------------------------------------------
-- Data Cleaning process
-- Describing the table will give the field type and to determine its key
DESCRIBE airlinedata
SELECT * FROM airlinedata

-- Add a field as primary key 
ALTER TABLE airlinedata
ADD COLUMN row_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

-- Set the appropriate field type for each column 
ALTER TABLE airlinedata
MODIFY age INT;

UPDATE airlinedata
SET departure_date = date_format(str_to_date(departure_date, '%d/%m/%Y'), '%Y-%m-%d');

ALTER TABLE airlinedata
MODIFY departure_date DATE;

-- Removing dublicates
-- Determine if there are any duplicate in the data
SELECT passenger_id, COUNT(passenger_id)
FROM airlinedata
GROUP BY passenger_id
HAVING COUNT(passenger_id) > 1;

SET AUTOCOMMIT = OFF;
COMMIT;

-- Deleting duplicates
DELETE FROM airlinedata
WHERE row_id IN (
SELECT row_id 
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY passenger_id) AS rn
FROM airlinedata) AS x
WHERE x.rn > 1);


-----------------------------------------------------------------------------------------------------------
-- Data Exploration

-- Total number of passengers
SELECT COUNT(passenger_id)
FROM airlinedata

# COUNT(passenger_id)
98617


-- Total number of passengers by gender
SELECT gender, COUNT(gender) as Total_passenger
FROM airlinedata
GROUP BY gender

# gender	Total_passenger
Female	49020
Male	49597


-- Distribution of passengers accross genders

SELECT gender,
	COUNT(gender)/98617 * 100 as Gender_percentage
FROM airlinedata
GROUP BY gender

# gender	Gender_percentage
Female	49.7075
Male	50.2925



-- Total number of passengers by airport continent
SELECT continents,
	COUNT(passenger_id) as Total_passenger
FROM airlinedata
GROUP BY continents
ORDER BY COUNT(passenger_id) DESC

# continents	Total_passenger
North America	32033
Asia			18636
Oceania			13866
Europe			12335
Africa			11029
South America	10718


-- Top 10 airports with the largest passenger count
SELECT airport_name,
	COUNT(passenger_id) as Total_passenger
FROM airlinedata
GROUP BY airport_name
ORDER BY Total_passenger DESC
LIMIT 10;

# airport_name	Total_passenger
San Pedro Airport		43
Santa Maria Airport		38
BÃ¶blingen Flugfeld		36
Santa Ana Airport		35
Maliana airport			32
San Fernando Airport	31
Mae Hong Son Airport	29
Cochrane Airport		28
Santa Rosa Airport		28
Capital City Airport	28


--  The percentage of passengers by flight status
SELECT flight_status,
	COUNT(passenger_id)/98617 * 100 as flightstatus_percentage
FROM airlinedata
GROUP BY flight_status
ORDER BY flightstatus_percentage

# flight_status	flightstatus_percentage
Delayed 	33.2914
On Time 	33.3066
Cancelled 	33.4019


-- Top 10 AIRPORT COUNTRIES with most passengers
SELECT country_name,
	COUNT(passenger_id) as total_passenger
FROM airlinedata
GROUP BY country_name
ORDER BY COUNT(passenger_id) DESC
LIMIT 10;

# country_name	total_passenger
United States		22104
Australia			6370
Canada				5424
Brazil				4504
Papua New Guinea	4081
China				2779
Indonesia			2357
Russian Federation	2247
Colombia			1643
India				1486


-- Total number of passengers by age
SELECT age, 
	COUNT(passenger_id) as total_passenger
FROM airlinedata
GROUP BY age
ORDER BY total_passenger DESC
LIMIT 5;

# age	total_passenger
29	1170
27	1164
39	1155
46	1151
6	1148


-- Average age of the passengers
SELECT AVG(age)
FROM airlinedata

# AVG(age)
45.5047

SELECT MIN(age) as Minimum_age,
	MAX(age) as Maximum_age
FROM airlinedata

# Minimum_age	Maximum_age
1	90



-- Distribution of passengers accross nationality
SELECT nationality,
	COUNT(passenger_id)/98617 * 100 AS Percentage
FROM airlinedata
GROUP BY nationality
ORDER BY Percentage DESC
LIMIT 5;

# nationality	Percentage
China		18.5739
Indonesia	10.7071
Russia		5.7728
Philippines	5.3125
Brazil		3.8442

-- Flight departure over time
SELECT departure_date, COUNT(flight_status) as Number_of_flights
FROM airlinedata
GROUP BY departure_date
ORDER BY departure_date

-- Determine the top 3 months of the year has the lowest number of passenger
SELECT
	EXTRACT(MONTH FROM departure_date) AS MONTH_,
	COUNT(passenger_id) AS total_passengers
FROM airlinedata
GROUP BY MONTH_
ORDER BY total_passengers
LIMIT 3;

# MONTH_	total_passengers
FEB	7653
DEC	7924
APR	7958

-- Determine the top 3 months of the year has the highest number of passenger
SELECT
	EXTRACT(MONTH FROM departure_date) AS MONTH_,
	COUNT(passenger_id) AS total_passengers
FROM airlinedata
GROUP BY MONTH_
ORDER BY total_passengers DESC
LIMIT 3;

# MONTH_	total_passengers
AUG	8543
MAY	8496
JUL	8451

