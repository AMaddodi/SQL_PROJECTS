SELECT *
FROM PortFolioProject.dbo.CovidDeaths
ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortFolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortFolioProject.dbo.CovidDeaths
WHERE location LIKE '%KINGDOM%'
ORDER BY 1,2


-- Looking at Total cases vs Population
-- Percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM PortFolioProject.dbo.CovidDeaths
WHERE location LIKE '%KINGDOM%'
ORDER BY 1,2 


-- Highest Infection percentage of the countries

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM PortFolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- Highest Death count of the Countries

SELECT location, population, MAX(CAST(total_deaths AS bigint)) AS HighestDeathCount
FROM PortFolioProject.dbo.CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestDeathCount DESC


-- Highest death count in continent 

SELECT location, MAX(CAST(TOTAL_DEATHS AS BIGINT)) AS HighestDeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Highest death count accourding to countries in continent

SELECT continent,location, MAX(CAST(TOTAL_DEATHS AS BIGINT)) AS HighestDeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent = 'EUROPE'
GROUP BY location, continent
ORDER BY HighestDeathCount DESC


-- world wide numbers per day

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS BIGINT)) as Total_Deaths,  ((SUM(CAST(new_deaths AS BIGINT)))/(SUM(new_cases)))*100 AS DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- world wide numbers

SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS BIGINT)) AS TOTAL_DEATHS, (SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- Vaccination status

SELECT DT.continent, DT.location, DT.date, DT.population, VT.new_vaccinations
FROM PortFolioProject..CovidDeaths AS DT
JOIN PortFolioProject..CovidVaccinations AS VT
	ON DT.location = VT.location AND DT.date = VT.date
WHERE /* VT.new_vaccinations IS NOT NULL AND */ DT.continent IS NOT NULL
ORDER BY DT.location, DT.date


-- Vaccination percentage
-- using CTE

WITH TotalVaccination (Continent, Location, Date, Population, New_Vaccination, Total_Vaccination)
AS
(
SELECT DT.continent, DT.location, DT.date, DT.population, VT.new_vaccinations,
		SUM(CONVERT(INT, VT.new_vaccinations)) OVER (PARTITION BY DT.location ORDER BY DT.location, DT.date) AS Total_Vaccination
FROM PortFolioProject..CovidDeaths AS DT
JOIN PortFolioProject..CovidVaccinations AS VT
	ON DT.location = VT.location AND DT.date = VT.date
WHERE DT.continent IS NOT NULL
)
SELECT *, (Total_Vaccination/Population)*100 AS PercentVaccinated
FROM TotalVaccination


-- Using TEMP table to calculate percentage of population vaccinated

DROP TABLE IF EXISTS #PopulationVaccinated
CREATE TABLE #PopulationVaccinated
( Continent nvarchar(255),
  location nvarchar(225),
  date datetime,
  population numeric,
  new_vaccination numeric,
  total_vaccination numeric
)

INSERT INTO #PopulationVaccinated
SELECT DT.continent, DT.location, DT.date, DT.population, VT.new_vaccinations,
		SUM(CONVERT(INT, VT.new_vaccinations)) OVER (PARTITION BY DT.location ORDER BY DT.location, DT.date) AS Total_Vaccination
FROM PortFolioProject..CovidDeaths AS DT
JOIN PortFolioProject..CovidVaccinations AS VT
	ON DT.location = VT.location AND DT.date = VT.date
WHERE DT.continent IS NOT NULL

SELECT *, (total_vaccination/population)*100 AS PercentVaccinated
FROM #PopulationVaccinated


-- Creting view for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT DT.continent, DT.location, DT.date, DT.population, VT.new_vaccinations,
		SUM(CONVERT(INT, VT.new_vaccinations)) OVER (PARTITION BY DT.location ORDER BY DT.location, DT.date) AS Total_Vaccination
FROM PortFolioProject..CovidDeaths AS DT
JOIN PortFolioProject..CovidVaccinations AS VT
	ON DT.location = VT.location AND DT.date = VT.date
WHERE DT.continent IS NOT NULL



