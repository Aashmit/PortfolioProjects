use PortfolioProject
--Viewing the two tables:
SELECT * 
from CovidDeaths;
SELECT * 
from CovidVaccinations;

--Finding the date of the very first Case and death in each country:
select location, 
		 min(case when new_cases> 0 then date end ) as first_case_date
		,min(case when new_deaths>0 then date end) as first_death_date
from CovidDeaths
group by Location
order by 1;

--Calculatig Death % : 
select location, date, total_cases, total_deaths , round((total_deaths/total_cases) * 100,2) as DeathPercentage 
from CovidDeaths 
order by 1,2

--Calculating Case% in the United States:
select location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage 
from CovidDeaths
where location like '%states%'
order by 1,2;

--Countries with Highest Infection Rate in a day compared to Population
select location, population , max(total_cases) as HighestInfectionCount , max((total_cases/population)) * 100 as InfectedPercentage 
from CovidDeaths 
group by Location, population 
order by InfectedPercentage desc;

--Countries with Highest Death Percentage:
select location, max(total_deaths) as TotalDeathCount 
from CovidDeaths 
where continent is NOT null
group by Location
order by TotalDeathCount desc;


--Continents with Highest Death Percentage :
select location, max(total_deaths) as TotalDeathCount 
from CovidDeaths
where continent is NULL 
group by location
order by TotalDeathCount desc;

--Global Numbers:

select date, sum(new_cases)as total_cases,sum(new_deaths) as total_deaths,
case when sum(new_cases)>0 then sum(new_deaths)/sum(new_cases)*100 end as deathPercentage --sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from CovidDeaths 
where continent is not null 
group by date  
order by 1, 2

--Aggregated Global Numbers
select sum(new_cases)as total_cases,sum(new_deaths) as total_deaths,
case when sum(new_cases)>0 then sum(new_deaths)/sum(new_cases)*100 end as deathPercentage --sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from CovidDeaths 
where continent is not null  
order by 1, 2

--Total Population vs Vaccinations:

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date)
as cumulative_vaccinations_per_location
from CovidVaccinations v
join CovidDeaths d
on v.location=d.location and v.date=d.date
where d.continent is not null
order by 2,3

--USE CTE:
WITH PopuVsVac(continent, location,date, population,new_vacciantions,  cumulative_vaccinations_per_location)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date)
as cumulative_vaccinations_per_location
from CovidVaccinations v
join CovidDeaths d
on v.location=d.location and v.date=d.date
where d.continent is not null
)
select * ,cumulative_vaccinations_per_location/population*100  as VaccinatedPercent from PopuVsVac
where new_vacciantions is not null

--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (Partition by d.location order by d.location,d.date)
as cumulative_vaccinations_per_location
from CovidVaccinations v
join CovidDeaths d
on v.location=d.location and v.date=d.date
where d.continent is not null

select * from PercentPopulationVaccinated