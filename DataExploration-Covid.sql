SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid per country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Kingdom%'
ORDER BY 1,2

--Looking at Total cases vs Population
--Shows what percentage of the population got covid.
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100, 2) as PopulationPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%United Kingdom%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing countries where highest death count per population
SELECT location, MAX(cast(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Looking at breaking it down to continent
--Showing continents with highest death count.
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers
--Replace NULL values with 0
UPDATE PortfolioProject..covidDeaths SET new_cases=0 WHERE new_cases IS NULL;
UPDATE PortfolioProject..covidDeaths SET new_deaths=0 WHERE new_deaths IS NULL;

--Show Total worldwide cases vs  Total worldwide deaths
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL AND new_cases >0 and new_deaths >0
ORDER BY 1,2 

--Looking at Total Population vs Vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVacs vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
SELECT *, ROUND((RollingVaccinations/population)*100, 2) as PercentagePopulation
FROM PopvsVac

--Create view to store date for later visualisations
--Create a view showing death count by continent.
CREATE VIEW ContinentDeathCount
 as
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

--Create a view showing population vs vaccine counts.
CREATE VIEW PopulationVsVaccine
as
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVacs vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
SELECT *, ROUND((RollingVaccinations/population)*100, 2) as PercentagePopulation
FROM PopvsVac

--Create a view showing world wide cases
CREATE VIEW WorldWideCases
AS
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL AND new_cases >0 and new_deaths >0
--GROUP BY date

--Create a view showing cases vs deaths.
CREATE VIEW CasesVsDeaths
AS
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL

--Create a view showing total cases vs population for each country
CREATE VIEW TotalCasesVsPop
AS
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100, 2) as PopulationPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL

--Create view showing infection rate vs population for each country
CREATE VIEW InfectionRateVsPopulation
AS
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population

--Create view showing the Covid Death Rate by Country
CREATE VIEW DeathRateByCountry
AS
SELECT location, MAX(cast(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location

