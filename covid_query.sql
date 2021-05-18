select *
from portfolioproject..covid_deaths
where continent is not null
order by 3,4

--select *
--from portfolioproject..covid_vaccinations
--order by 3,4

-- Select Data that we will be using

select Location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..covid_deaths
where continent is not null
order by 1,2


-- Looking @ total cases vs total deaths
-- This shows likelihood of death from covid-19 in the U.S.
select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..covid_deaths
Where location like '%states%' and continent is not null
order by 1,2

-- Looking @ total cases vs population
-- What % of population got covid
select Location, date, total_cases, population,(total_cases/population)*100 as PercentPopulatuonInfected
from portfolioproject..covid_deaths
Where location like '%states%' and continent is not null
order by 1,2

-- Looking @ countries w/ highest infection rate compares to pop. 
select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulatuonInfected
from portfolioproject..covid_deaths
where continent is not null
Group by Location, population
order by PercentPopulatuonInfected desc

-- Looking @ continents w/ highest death toll for population
select Location, MAX(cast(total_deaths as int)) as TotalDeathToll
from portfolioproject..covid_deaths
where continent is null
Group by location 
order by TotalDeathToll desc


-- Looking @ countries w/ highest death toll for population
select Location, MAX(cast(total_deaths as int)) as TotalDeathToll
from portfolioproject..covid_deaths
where continent is not null
Group by Location 
order by TotalDeathToll desc

-- Global look
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100  as deathpercentage
from portfolioproject..covid_deaths
Where continent is not null
--group by date 
order by 1,2


-- looking @ total pop vs. vaccinations
--Use CTE
With popvsvac (continent, location, date, population, new_vaccinations, total_ppl_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.date) as total_ppl_vaccinated
from portfolioproject..covid_deaths dea
join portfolioproject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (total_ppl_vaccinated/population)*100
From popvsvac

-- TEMP Table
drop table if exists #percentpopvac
create table #percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_ppl_vaccinated numeric
)

Insert into #percentpopvac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.date) as total_ppl_vaccinated
from portfolioproject..covid_deaths dea
join portfolioproject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (total_ppl_vaccinated/population)*100
From #percentpopvac

-- create a view to store for visualizations

create view percentpopvac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.date) as total_ppl_vaccinated
from portfolioproject..covid_deaths dea
join portfolioproject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopvac