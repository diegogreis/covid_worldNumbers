SELECT *
FROM covid_project.covid_deaths 
WHERE continent is not null
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_project.covid_deaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from Covid in your country

SELECT location, date, total_cases, total_deaths, 
ROUND ((total_deaths / total_cases) * 100, 2) AS death_percentage
FROM covid_project.covid_deaths
WHERE location = 'Brazil'
ORDER BY 1, 2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases,
ROUND ((total_cases / population) * 100, 2) AS totalCases_population
FROM covid_project.covid_deaths
WHERE location = 'Brazil'
ORDER BY 1, 2;

-- Looking at the country with the highest infection rate by population

SELECT location, population, 
MAX(total_cases) AS total_infected,
ROUND((MAX(total_cases) / population * 100), 2) AS total_percentage
FROM covid_project.covid_deaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Looking at the country with the highest death rate by populatoin

SELECT location, population, 
MAX(total_deaths) AS total_deaths,
ROUND((MAX(total_deaths) / population * 100), 2) AS total_deathPercentage
FROM covid_project.covid_deaths
GROUP BY location, population
ORDER BY 4 DESC;


-- Breaking it down by continent

SELECT location, continent, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM covid_project.covid_deaths
WHERE continent <> ''
GROUP BY location, continent 
ORDER BY total_deaths DESC;

-- Deaths count by continents

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM covid_project.covid_deaths
WHERE continent = ''
GROUP BY location
ORDER BY total_deaths DESC;

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2) as death_percentage
FROM covid_project.covid_deaths
GROUP BY date
ORDER BY date;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2) as death_percentage
FROM covid_project.covid_deaths;

-- Looking Total Population vs Vaccionation 

SELECT *
FROM covid_project.covid_deaths dea
JOIN covid_project.covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM covid_project.covid_deaths dea
JOIN covid_project.covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> '' 
AND vac.new_vaccinations <> 0
ORDER BY 2, 3;

-- Use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vaccinated
FROM covid_project.covid_deaths dea
JOIN covid_project.covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent <> '' 
AND vac.new_vaccinations <> 0
-- ORDER BY 2, 3 )
)

SELECT *, ROUND((people_vaccinated / population), 4) * 100 AS percentage_of_vaccinated
FROM PopVsVac;

-- Tableau 

Select SUM(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths, 
ROUND(SUM(new_deaths)/SUM(New_Cases)*100, 3) as DeathPercentage
FROM covid_project.covid_deaths
where continent <> '' 
order by 1,2;

Select location, 
SUM(new_deaths) as TotalDeathCount
FROM covid_project.covid_deaths
WHERE continent = ''
AND location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  
ROUND(Max((total_cases/population))*100, 3) as PercentPopulationInfected
FROM covid_project.covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc;

Select Location, Population,date, 
MAX(total_cases) as HighestInfectionCount,  
ROUND(Max((total_cases/population))*100, 3) as PercentPopulationInfected
FROM covid_project.covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc
