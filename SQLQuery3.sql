SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select Data to be used
SELECT
location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--looking at the total cases vs total deaths **

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0
ORDER BY 1,2

--looking at the total cases vs total deaths**
--shows likelihood of dying if you contract covid in your country**

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0
ORDER BY 1,2



--looking at total cases vs total deaths for a particular location
SELECT
location,
date,
total_cases,
Total_deaths,
(total_deaths/total_cases) * 100 AS TotalDeathpercent
From PortfolioProject..CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1,2 

--looking at total cases vs population
--shows what percentage of population got covid
SELECT
location,
date,
total_cases,
population,
(total_cases/population) * 100 AS percentagePopulationInfected
From PortfolioProject..CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1,2 

--looking at countries with Highest infection Rate compared to population
SELECT
location,
population,
MAX(total_cases) As HighestInfectionCount,
MAX(total_cases/population)* 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%States%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--showing countries with the highest death count per population

SELECT
location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--To get the accurate figures
SELECT
location,
MAX(CAST(total_deaths AS int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continent with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT 
date,
SUM(new_cases) AS totalcases,
SUM(CAST(new_deaths AS int)) AS totaldeaths,
SUM(CAST(new_deaths AS int))/ SUM(New_cases)* 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%States%'
where new_cases <> 0
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS
-- Removing the date will give us the total cases
SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS int)) AS totaldeaths,
SUM(CAST(new_deaths AS int))/ SUM(New_cases)* 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%States%'
where new_cases <> 0
--GROUP BY date
ORDER BY 1,2

--to join the two covid tables

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--looking at total population vs vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

-- Rolling count of new vaccinations per location
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


-- USE CTE 

with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS (

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac

-- RollingPeopleVaccinated Vs Population
with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS (

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentagePopulationVaccinated
FROM PopvsVac

--Use Temp Table

DROP TABLE if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
INSERT INTO #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) 
OVER(PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

--, (RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentpopulationVaccinated

DROP TABLE if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
INSERT INTO #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) 
OVER(PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

--, (RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentpopulationVaccinated

-- creating view to store data for visualizations
create view 
PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated