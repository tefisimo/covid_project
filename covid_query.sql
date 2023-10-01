

SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4


-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases Vs. Total Deaths in Venezuela

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%ezuela%'
ORDER BY 1,2


-- Looking at Total Cases Vs. Population
-- This shows what percentage of population got covid around the world

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM CovidProject..CovidDeaths
--WHERE location like '%ezuela%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectedPercentage
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Showing Countries with Highest Death Count

SELECT location, MAX(total_deaths) AS DeathCount
FROM CovidProject..CovidDeaths
GROUP BY location
ORDER BY DeathCount DESC
-- As we can see, we got a issue with total_deaths. This column is nvarchar type.


-- Fixing Total_Death column issue

SELECT location, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC 


-- Ok, lets break things down by continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null 
GROUP by continent
ORDER by TotalDeathCount desc


-- Lets see global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- Lest join my tables
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinated



-- Editing my Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null