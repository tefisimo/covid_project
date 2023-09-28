

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