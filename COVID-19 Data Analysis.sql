SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3, 4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/CONVERT(float, total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (CONVERT(float, total_cases)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(CONVERT(int, total_cases)) AS HighestInfectionCount, MAX((CONVERT(float, total_cases)/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highet Death Count Per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT/Showing continents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
CASE 
	 WHEN SUM(new_cases) = 0 THEN NULL
	 ELSE (SUM(new_deaths)/SUM(new_cases))*100
END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations(CTE)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac
ORDER BY 2, 3

-- Looking at Total Population vs Vaccinations(TEMP TABLE)
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2, 3




SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
CASE 
	 WHEN SUM(new_cases) = 0 THEN NULL
	 ELSE (SUM(new_deaths)/SUM(new_cases))*100
END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Creating View to store data for later visualization
Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated
