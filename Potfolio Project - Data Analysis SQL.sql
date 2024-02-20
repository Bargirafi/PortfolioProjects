-- Data analysis of the Corona disease data
-- All the data here is From 01/01/2020 Until 30/04/2021
-- A presentation of our two tables
select *
from PortfolioProject..CovidDeaths
order by 3,4 

select *
from PortfolioProject..CovidVaccinations
order by 3,4 

-- Select Data that we are going to using

select Location , Date , total_cases , new_cases , total_deaths ,population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- Show likelihood of dying if you are contract covid in your country
select Location , Date , total_cases  , total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%israel%'
order by 1,2

-- Looking at Total Cases VS Population
-- Show what percentage of population got Covid
select Location , Date , population, total_cases  , (total_cases/population)*100 AS PercentPopulationIndected
from PortfolioProject..CovidDeaths
Where location like '%israel%'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to population 

select Location  , population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationIndected
from PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationIndected desc

-- Showing countries with the highest Death Count per Population 

select Location, max(cast(total_deaths as int)) AS HighestDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null -- Get read of the rows that Got Continents on the Location Column
group by location
order by HighestDeathCount desc

-- Lets Break things Down By Continent
-- Showing continents with the highest Death Count per Population 

select continent, max(cast(total_deaths as int)) AS HighestDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null -- Get read of the rows that Got Continents on the Location Column
group by continent
order by HighestDeathCount desc

-- Global Numbers

select Date , sum(new_cases) as TotalCases , sum(cast(new_deaths as int)) as TotalDeaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by Date
order by 1,2


-- Looking at total Population VS Vaccinations
-- Using Join 
select dea.continent , 	dea.location , dea.date , dea.population , vac.new_vaccinations
from PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Scheme of the number of vaccinated per day throughout the period

select dea.continent , 	dea.location , dea.date , dea.population , 
vac.new_vaccinations, SUM(CONVERT(int , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Percentages of vaccinated per day according to the population
-- We will show it by 2 methods - CTE and Temp Table
-- Use CTE

with PopVsVac ( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent , 	dea.location , dea.date , dea.population , 
vac.new_vaccinations, SUM(CONVERT(int , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select * , (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime ,
Population numeric ,
new_vaccinations numeric ,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent , 	dea.location , dea.date , dea.population , 
vac.new_vaccinations, SUM(CONVERT(int , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations .

Create View PercentPopulationVaccinated as 
select dea.continent , 	dea.location , dea.date , dea.population , 
vac.new_vaccinations, SUM(CONVERT(int , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated

