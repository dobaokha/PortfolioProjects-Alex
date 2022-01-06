--Original Dataset
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2
 
 --Total cases vs total deaths
 -- Show the likelihood of dying if you contract COVID in your counry
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population*100) as infection_percentage
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT 
	location, 
	population,
	MAX(total_cases) as highest_total_cases,
	MAX((total_cases)/population)*100 as highest_infection_rate	
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY 
	location,
	population 
ORDER BY highest_infection_rate desc

--Showing countries with the highest death rate
SELECT
	location, 
	population,
	MAX(CAST(total_deaths as int)) as highest_total_deaths,
	MAX(CAST(total_deaths as int)/population*100) as highest_death_rate
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY 
	location,
	population
ORDER BY 
	highest_total_deaths desc

--Showing countries with Highest Death Count per population
SELECT 
	location,
	max(cast(total_deaths as int)) as maximum_total_deaths
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	location
ORDER BY 
	maximum_total_deaths DESC

--Showing continents with Highest Death Count
SELECT 
	continent,
	max(cast(total_deaths as int)) as maximum_total_deaths
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY 
	continent
ORDER BY 
	maximum_total_deaths DESC

--GLOBAL NUMBERS
SELECT  
	sum(new_cases) as total_new_cases,
	sum(cast(new_deaths as int)) as total_new_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS (creating 
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vacinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vacinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, RollingPeopleVaccinated/Population*100
FROM PopvsVac