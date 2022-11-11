--SELECT * FROM dbo.CovidVaccinations
-- selecting the columns and rows to be used

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Covid19Project1.dbo.CovidDeaths
ORDER BY 1,2

-- Total Cases Vs Total Deaths Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 Death_percentage
FROM Covid19Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases Vs Population
-- Percentage of Population With Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 Population_percentage
FROM Covid19Project1.dbo.CovidDeaths
WHERE location LIKE '%KENYA%'
ORDER BY 1,2

-- Maximum number of cases recorded in a day in 
-- Countries with Highest Infection Rate
SELECT location, population ,MAX((total_cases/population))*100 AS Population_percentage_affected,
			MAX(total_deaths) Max_death
FROM Covid19Project1.dbo.CovidDeaths
GROUP BY location, population
ORDER BY Population_percentage_affected DESC

--Countries with the highest Death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_death_count
FROM Covid19Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC

-- Continents with highest Death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_death_count
FROM Covid19Project1.dbo.CovidDeaths
WHERE continent IS NULL --AND location NOT IN ('World')
GROUP BY location
ORDER BY Total_death_count DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_death_count
FROM Covid19Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC

-- global numbers
SELECT date,
	SUM(new_cases) as daily_new_cases, 
	SUM(CAST(new_deaths as int)) daily_new_deaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Covid19Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

-- total world cases
-- global numbers
SELECT --date,
	SUM(new_cases) as daily_new_cases, 
	SUM(CAST(new_deaths as int)) daily_new_deaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Covid19Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

-- total population vs vaccinations
WITH popVac as(
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,  
	SUM(CAST(vac.new_vaccinations AS INT))
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
			as rolling_total_vaccinations
FROM Covid19Project1..CovidDeaths dea
JOIN Covid19Project1.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND
	dea.date = vac.date
)
SELECT *, (rolling_total_vaccinations/population)*100 as percentage_vaccinated
FROM popVac
order by 2,3

-- using TEMP     table
DROP TABLE IF EXISTS percentpopulationvaccinated
CREATE table percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinated numeric
)
insert into percentpopulationvaccinated
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,  
	SUM(CAST(vac.new_vaccinations AS INT))
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
			as rolling_total_vaccinations
FROM Covid19Project1..CovidDeaths dea
JOIN Covid19Project1.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND
	dea.date = vac.date
select *
from percentpopulationvaccinated

