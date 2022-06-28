--select * from PortfolioProject..CovidDeaths
--order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

-- Selecting data tp be used 

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- Finding the death percent due to covid cases for every country for each date
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as 'DeathPercent'
from PortfolioProject..CovidDeaths
order by 1,2

-- Finding the death percent due to covid cases for India for each date
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as 'DeathPercent'
from PortfolioProject..CovidDeaths
Where location = 'INDIA'
order by 1,2

-- Finding the dates where the death percent was the highest in USA due to covid cases
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as 'Death Percent'
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 5 desc

-- Finding the percent of populatation infected due to covid for every country for each date
select location,date,total_cases,population, (total_cases/population)*100 as 'CovidPercent'
from PortfolioProject..CovidDeaths
order by 1,2

-- Finding the percent of populatation infected due to covid for India for each date

select location,date,total_cases,population, (total_cases/population)*100 as 'CovidPercent'
from PortfolioProject..CovidDeaths
where location = 'INDIA'
order by 1,2

-- Finding the highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectedCount , max((total_cases/population))*100 as 'CovidPercent'
from PortfolioProject..CovidDeaths
group by location,population
order by CovidPercent desc

-- Finding the highest death rate due to covid per population
select location,population,max(CAST (total_deaths AS INT)) as HighestDeathCount , max((total_deaths/population))*100 as 'CovidDeaths'
from PortfolioProject..CovidDeaths
group by location,population
order by CovidDeaths desc

-- Total death count by continents 
select continent,max(CAST (total_deaths AS INT)) as TotalDeathCount  
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Death percentage globally on daily basis

select date,sum(new_cases) as TotalCases,sum(cast (new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1

--Overall Death percentage globally
select sum(new_cases) as TotalCases,sum(cast (new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
order by 1


-- Join CovidDeaths table and Covid Vaccinations table

select * from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccination cv
on cd.location = cv.location and cd.date = cv.date


-- Total number of people in the world who is vaccinated
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccination cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- adding new vaccinations by date for every country
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccination cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Finding the vaccination rate per population for every country for all dates 

-- using CTE

with popvsvac (Continent,location,date,population,new_vaccinations,AddbyDatenLoc)
as
(
 select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccination cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
)
select *, (AddbyDatenLoc/population)*100 as VaccinationRate from popvsvac


-- using ##
Drop table if exists ##VaccinatedPopulation
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
into ##VaccinatedPopulation
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccination cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 

select *, (AddbyDatenLoc/population)*100 as VaccinationRate from ##VaccinatedPopulation
order by 2,3


-- Creating Views

Create view VaccinatedPopulation as
 select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as AddbyDatenLoc
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccination cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null


select * from VaccinatedPopulation
