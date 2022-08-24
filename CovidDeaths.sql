Select *
From CovidDeaths
where continent is not null
order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths 
order by 1,2 

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%rope'
order by 1,2 

-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as TotalCasePercentage
from CovidDeaths 
where location like '%rkey'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared Population
Select location, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths 
group by location
order by PercentPopulationInfected desc

--Showing Countries Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- Showing continents with the highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
where continent is null
group by location
order by TotalDeaths desc

-- Global Numbers
Select date, sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc

Select  sum(new_cases) as total_case, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by DeathPercentage desc

--USE CTE
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as(
--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
join CovidVaccinations vac
   on dea.location =vac.location
   and dea.date=vac.date
where dea.continent is not null)
--order by 2,3)
 
 Select *, (RollingPeopleVaccinated/population)*100
 from PopvsVac
 order by 2,3

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
join CovidVaccinations vac
   on dea.location =vac.location
   and dea.date=vac.date
where dea.continent is not null

select* , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
join CovidVaccinations vac
   on dea.location =vac.location
   and dea.date=vac.date
where dea.continent is not null