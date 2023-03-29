SELECT * 
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM portfolio_project..CovidDeaths
--ORDER BY 3,4

--Select data that were going to be using


SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at the total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) AS deaths_percentage
FROM portfolio_project..CovidDeaths
WHERE location LIKE 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--looking at total cases VS population
--shows what percentage of population got covid

SELECT location,date,population,total_cases,ROUND((total_cases/population)*100,2) AS covid_percentage
FROM portfolio_project..CovidDeaths
--WHERE location LIKE 'India'
ORDER BY 1,2

--looking at countries with heigest Infection rate compared to population

SELECT location,population,MAX(total_cases) AS heigest_infection_count ,ROUND(MAX((total_cases/population)*100),2) AS 
percentage_population_infected
FROM portfolio_project..CovidDeaths
GROUP BY location,population
--WHERE location LIKE 'India'
ORDER BY percentage_population_infected DESC

--Showing countries with heigest death count per population

SELECT location,MAX(CAST(total_deaths AS int)) AS total_death_count
FROM portfolio_project..CovidDeaths
--WHERE location LIKE 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing continets with heigest death count per population

SELECT continent,MAX(CAST(total_deaths AS int)) AS total_death_count
FROM portfolio_project..CovidDeaths
--WHERE location LIKE 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


--Global Numbers

SELECT date,SUM(new_cases)AS New_cases,SUM(CAST(new_deaths AS int)) AS New_deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases)AS New_cases,SUM(CAST(new_deaths AS int)) AS New_deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM portfolio_project..CovidDeaths
ORDER BY 1,2 
WHERE continent IS NOT NULL

 --Looking at total population vs vaccination (Joining two tables) and adding up total vaccination using windows function
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location order by dea.location,dea.date) AS People_Vaccinated
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE

WITH pop_vs_vac (Continent,Location,Date,Population,New_vaccination,People_Vaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location order by dea.location,dea.date) AS People_Vaccinated
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,ROUND((People_Vaccinated/Population)*100,3)
FROM  pop_vs_vac


--TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(	continent nvarchar(255),
	Location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	People_Vaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location order by dea.location,dea.date) AS People_Vaccinated
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *,ROUND((People_Vaccinated/Population)*100,3)
FROM  PercentPopulationVaccinated


--Creating VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated_ AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location order by dea.location,dea.date) AS People_Vaccinated
FROM portfolio_project..CovidDeaths dea
JOIN portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



SELECT * 
FROM PercentPopulationVaccinated_

