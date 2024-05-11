-- These sql queries analyze the COVID-19 data, including cases, deaths, and vaccination rates across different regions.

-- Retrieving all columns from the 'covid_deaths' table and ordering the results by date and location.
-- This query helps in understanding the chronological distribution of COVID-19 deaths.
SELECT *
FROM covid_deaths
ORDER BY location, date;

-- Retrieving all columns from the 'covid_vaccination' table and ordering the results by date and location.
-- This query provides insights into the vaccination progress over time and across regions.
SELECT *
FROM covid_vaccination
ORDER BY location, date;

-- Analyzing the total number of cases and deaths per country.
-- This query summarizes COVID-19 cases and deaths, providing an overview of the global situation.
SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_cases DESC;
  
-- Focusing on specific countries to analyze their COVID-19 statistics.
-- This query narrows down the analysis to selected countries of interest.
SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths 
FROM covid_deaths
WHERE continent IS NOT NULL AND
(location = 'Nigeria' OR location LIKE '%Kingdom%')
GROUP BY location
ORDER BY total_cases DESC;

-- Summarizing COVID-19 cases and deaths by continent.
-- This query provides insights into COVID-19 trends at a continental level.
SELECT continent, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC;

-- Calculating the worldwide death percentage.
-- This query computes the percentage of deaths compared to total cases globally.
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, CAST(SUM(new_deaths) AS float) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentageWorldwide
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Calculating the death percentage compared to cases recorded for each country.
-- This query calculates the mortality rate for each country.
SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM covid_deaths
GROUP BY location
ORDER BY location;

-- Analyzing total deaths vs population to understand the impact of COVID-19 on different countries.
-- This query computes the death rate compared to the population for each country.
SELECT location, population, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / population) * 100 AS DeathPercentageByPopulation
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentageByPopulation DESC;

-- Analyzing total cases vs population to understand the infection rate.
-- This query computes the infection rate relative to the population for each country.
SELECT location, population, SUM(new_cases) AS total_cases, (SUM(new_cases) / population) * 100 AS InfectionRate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate DESC;

-- Analyzing the cumulative count of people vaccinated by location and date, and calculating the percentage of people vaccinated.
-- This query tracks the progress of vaccination efforts and calculates the vaccination rate using a cte so as to query off newly created columns
WITH cte (location, date, population, new_vaccinations, RollingCountOfPeopleVaccinated) AS (
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingCountOfPeopleVaccinated
FROM covid_deaths AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND
d.date = v.date 
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingCountOfPeopleVaccinated / population)*100 AS PercentageOfPeopleVaccinated
FROM cte;

-- Altering the covid_vaccination table to drop specific columns not required for further analysis.
ALTER TABLE covid_vaccination
DROP COLUMN total_cases, new_cases;

-- Creating a temporary table to analyze vaccination rate trends and its relationship with GDP per capita.
-- This temporary table helps in studying vaccination trends alongside economic indicators.
CREATE TABLE #Trend_in_vaccination_rate (
location nvarchar(255),
date datetime, 
VaccinationRate float, 
gdp_per_capita int
);
INSERT INTO #Trend_in_vaccination_rate
SELECT d.location, d.date, (SUM(CONVERT(bigint, v.new_vaccinations)) / MAX(d.population))*100 AS VaccinationRate, d.gdp_per_capita
FROM covid_deaths d
JOIN covid_vaccination v
ON d.location = v.location AND
d.date = v.date 
WHERE d.continent IS NOT NULL
GROUP BY d.location, d.date, d.gdp_per_capita;

-- Dropping the temporary table after analysis.
DROP TABLE IF EXISTS #Trend_in_vaccination_rate;

-- Creating views to store aggregated data for later analysis.
CREATE VIEW death_and_infection_rate AS 
SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location;

CREATE VIEW global_numbers AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, CAST(SUM(new_deaths) AS float) / CAST(SUM(new_cases) AS float) * 100 AS DeathPercentageWorldwide
FROM covid_deaths
WHERE continent IS NOT NULL;

CREATE VIEW CTE AS
WITH cte (location, date, population, new_vaccinations, RollingCountOfPeopleVaccinated) AS (
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.date) AS RollingCountOfPeopleVaccinated
FROM covid_deaths AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND
d.date = v.date 
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingCountOfPeopleVaccinated / population)*100 AS PercentageOfPeopleVaccinated
FROM cte;
