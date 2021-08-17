SELECT *
FROM dbo.CovidDeaths
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2


--Calculating the death percentage in the US
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Calculating the percentage of infected population in the US
SELECT location, date, population, total_cases, ((total_cases/population)*100) AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Calculating the percentage of infected population in the world
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Calculating total death in the world order by location
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC


--Calculating total death in the world order by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Calculating percentage of death compared with total infected cases
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


--Total population vs vaccinations
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationCountbyLocation)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationCountbyLocation
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (VaccinationCountbyLocation / Population)*100 AS VaccinationPercentperPopulation
FROM PopvsVac



CREATE VIEW VaccinationCountbyLocation AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationCountbyLocation
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM VaccinationCountbyLocation