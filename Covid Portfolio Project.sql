/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

-- Selecting data to be used 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Finding the death percent due to covid cases for every country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Finding the death percent due to covid cases for India

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'INDIA'
and continent is not null 
order by 1,2


-- Finding the dates when the death percent was the highest in USA due to covid cases
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as 'Death Percent'
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 5 desc

-- Finding the percent of populatation infected due to covid for every country for each date
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Finding the percent of populatation infected due to covid for India for each date

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2

-- Finding the highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Finding the highest death rate due to covid per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Total death count by continents 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Death percentage globally on daily basis


Select Date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
group by date
order by 1,2



--Overall Death percentage globally
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2


-- Join CovidDeaths table and Covid Vaccinations table

Select * From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccination cv
on cd.Location = cv.Location and cd.Date = cv.Date


-- Total number of people in the world who is vaccinated
Select cd.Continent, cd.Location,cd.Date, cd.Population,cv.New_vaccinations from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccination cv
On cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null
Order by 2,3


-- adding new vaccinations by date for every country
Select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
Sum(cast(cv.new_vaccinations as bigint)) Over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccination cv
On cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null
Order by 2,3

-- Finding the vaccination rate per population for every country for all dates 

-- using CTE

With PopVsVac (Continent,location,date,population,new_vaccinations,AddbyDatenLoc)
As
(
Select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
Sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccination cv
On cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null
)
Select *, (AddbyDatenLoc/population)*100 as VaccinationRate from PopVsVac


-- using ##
Drop table if exists ##VaccinatedPopulation
Select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
Sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
Into ##VaccinatedPopulation
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccination cv
On cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null 

Select *, (AddbyDatenLoc/population)*100 as VaccinationRate from ##VaccinatedPopulation
Order by 2,3


-- Creating Views

Create View VaccinatedPopulation as
Select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
Sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccination cv
On cd.location = cv.location and cd.date = cv.date
Where cd.continent is not null
