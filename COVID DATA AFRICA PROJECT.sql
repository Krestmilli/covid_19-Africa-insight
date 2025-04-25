--COVID_19 cases in Africa
SELECT * FROM covid_deaths
WHERE continent LIKE 'Africa';



--COVID_19 vaccination in Africa

SELECT * FROM covid_vaccinations
WHERE continent = 'Africa';


--Showing total death by countries
SELECT 
continent, location, 
SUM(total_cases) AS total_cases,
SUM(total_deaths) AS total_deaths,
SUM(total_cases) - SUM(total_deaths) AS cases_minus_deaths
FROM covid_deaths
WHERE continent LIKE 'Africa'
GROUP BY  continent, location
ORDER BY location;



--showing total deaths by countries and date
SELECT 
date, continent, location, 
SUM(total_cases) AS total_cases,
SUM(total_deaths) AS total_deaths,
SUM(total_cases) - SUM(total_deaths) AS cases_minus_deaths
FROM covid_deaths
WHERE continent LIKE 'Africa'
GROUP BY date, continent, location
ORDER BY location;


--Total death & cases in Africa
SELECT continent,
SUM (total_cases) AS total_cases,
SUM (total_deaths) AS total_death
FROM covid_deaths
WHERE continent = 'Africa'
GROUP BY continent;






--Showing Cases and Vaccinations

SELECT cd.date, cd.location, total_cases, total_deaths, total_tests, total_vaccinations, 
people_vaccinated
 FROM covid_deaths cd
 JOIN 
 	covid_vaccinations cv
	 ON cd.location = cv.location
	 AND cd.date = cv.date
	  WHERE cd.continent  = 'Africa'
ORDER BY total_deaths desc;



--showing total cases, death, vaccinations, people vaccinated and the total death ratio
--of African Countries

SELECT 
    cd.location,
    SUM(cd.total_cases) AS total_cases,
    SUM(cd.total_deaths) AS total_deaths,
    SUM(cv.total_vaccinations) AS total_vaccinations,
    SUM(cv.people_vaccinated) AS people_vaccinated,
    ROUND(SUM(cv.total_vaccinations)::numeric / NULLIF(SUM(cd.total_deaths), 0), 2) AS total_death_vaccination_ratio
FROM covid_deaths cd
JOIN covid_vaccinations cv 
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE cd.continent = 'Africa'
GROUP BY cd.location
ORDER BY cd.location 




--Showing Countries with the largest death 
SELECT location,
MAX(total_cases) AS maximum_cases,
MAX (total_deaths) AS maximum_deaths
FROM covid_deaths
where continent = 'Africa' 
GROUP BY location 
ORDER BY 3 desc

--MAIN ANALYSIS
--Show percentage of deaths per case (case fatality rate)
SELECT location,
       MAX(total_cases) AS maximum_cases,
       MAX(total_deaths) AS maximum_deaths,
       ROUND(MAX(total_deaths)::numeric / NULLIF(MAX(total_cases), 0) * 100, 2) AS death_rate_percent
FROM covid_deaths
WHERE continent = 'Africa'
GROUP BY location
ORDER BY maximum_deaths DESC;


--Track trends over time (e.g., peak dates)
SELECT location, date, total_deaths
FROM covid_deaths
WHERE continent = 'Africa'
  AND total_deaths IS NOT NULL
  AND (location, total_deaths) IN (
      SELECT location, MAX(total_deaths)
      FROM covid_deaths
      WHERE continent = 'Africa'
      GROUP BY location
  );


--Compare new cases vs. new deaths (daily impact)
SELECT location, 
       AVG(new_cases) AS avg_daily_cases,
       AVG(new_deaths) AS avg_daily_deaths
FROM covid_deaths
WHERE continent = 'Africa'
GROUP BY location
ORDER BY avg_daily_deaths DESC;


--Rank by population impact (cases/deaths per million)
SELECT location,
       MAX(total_cases) AS total_cases,
       MAX(total_deaths) AS total_deaths,
       population,
       ROUND(MAX(total_cases)::numeric / population * 1000000, 2) AS cases_per_million,
       ROUND(MAX(total_deaths)::numeric / population * 1000000, 2) AS deaths_per_million
FROM covid_deaths
WHERE continent = 'Africa' AND population IS NOT NULL
GROUP BY location, population
ORDER BY deaths_per_million DESC;










--Comparative Performance
SELECT 
    cd.location,
    SUM(cd.total_cases) AS total_cases,
    SUM(cd.total_deaths) AS total_deaths,
    SUM(cv.people_vaccinated) AS people_vaccinated,
    ROUND(SUM(cv.people_vaccinated)::numeric / NULLIF(SUM(cd.total_cases), 0) * 100, 2) AS vaccination_percent,
    ROUND(SUM(cd.total_deaths)::numeric / NULLIF(SUM(cd.total_cases), 0) * 100, 2) AS death_rate_percent,
    CASE 
        WHEN (SUM(cv.people_vaccinated)::numeric / NULLIF(SUM(cd.total_cases), 0) * 100) > 50 
             AND (SUM(cd.total_deaths)::numeric / NULLIF(SUM(cd.total_cases), 0) * 100) < 2 
            THEN 'Effective Response'
        WHEN (SUM(cv.people_vaccinated)::numeric / NULLIF(SUM(cd.total_cases), 0) * 100) < 20 
             AND (SUM(cd.total_deaths)::numeric / NULLIF(SUM(cd.total_cases), 0) * 100) > 5 
            THEN 'High Risk'
        ELSE 'Moderate'
    END AS response_category
FROM covid_deaths cd
JOIN covid_vaccinations cv 
    ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent = 'Africa'
GROUP BY cd.location
ORDER BY response_category;
	 