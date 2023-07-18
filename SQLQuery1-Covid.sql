select * from CovidDeaths
order by 3,4

--select * from CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Total cases vs Total deaths-This shows the percentage that died of covid
select location,date,total_cases,total_deaths,round((total_deaths/total_cases*100),2)as DeathPercentage
from CovidDeaths
where location like '%Africa%'
order by 1,2

--Total Cases vs Population-This shows the population that got covid
select location,date,total_cases,population,round((total_cases/population*100),2) as CasePercentage
from CovidDeaths
--where location like '%Africa%'
order by 1,2

--Countries with highest infection rate
select Location, Population, max(total_cases) as HighestInfectionCount,max(round((total_cases/population*100),2)) as InfectionRate
from CovidDeaths
--where location like '%Africa%' 
group by location,population
order by 4 desc

--Death Rate by Country
select Location, max(cast(total_deaths as int)) as HighestDeathCount,max(round((total_deaths/population*100),2)) as DeathRate
from CovidDeaths
--where location like '%Africa%' 
where continent is null
group by location
order by 2 desc

--By Continent
select Continent, max(cast(total_deaths as int)) as HighestDeathCount,max(round((total_deaths/population*100),2)) as DeathRate
from CovidDeaths
--where location like '%Africa%' 
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS
select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
round(sum(cast(new_deaths as int))/sum(new_cases) * 100,2) as DeathPercentage
from CovidDeaths
where Continent is not null
group by date
order by 1,2

--HOW TO CREATE A TABLE USING AN EXISTING TABLE
select distinct * into CovidVaccination from CovidVaccinations
select * from CovidVaccination

--Total Population vs Vaccination
select dea.Continent,dea.Location,dea.Date, Population, vac.New_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeDailyVaccination,
max(CumulativeDailyVaccination)/population * 100 as PercentageVaccinated
from CovidDeaths dea
join CovidVaccination vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USING A CTE- because we cant use a newly created alias column
with PopVsVac (Continent,Location, Date, Population, New_Vaccinations, CumulativeDailyVaccination) 
as
(select dea.Continent,dea.Location,dea.Date, dea.Population, vac.New_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeDailyVaccination
--max(CumulativeDailyVaccination)/population * 100 as PercentageVaccinated
from CovidDeaths dea
join CovidVaccination vac 
 on dea.location = vac.location 
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, round((CumulativeDailyVaccination/population * 100),2) as PercentageVaccinated
from PopVsVac

--TEMP TABLE
create table #PercentagePopulationVaccinated (
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
CumulativeDailyVaccination numeric)
insert into #PercentagePopulationVaccinated
select dea.Continent,dea.Location,dea.Date, dea.Population, vac.New_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeDailyVaccination
--max(CumulativeDailyVaccination)/population * 100 as PercentageVaccinated
from CovidDeaths dea
join CovidVaccination vac 
 on dea.location = vac.location 
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, round((CumulativeDailyVaccination/population * 100),2) as PercentageVaccinated
from #PercentagePopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
create view PrecentagePopulationVaccinated as
select dea.Continent,dea.Location,dea.Date, dea.Population, vac.New_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as CumulativeDailyVaccination
--max(CumulativeDailyVaccination)/population * 100 as PercentageVaccinated
from CovidDeaths dea
join CovidVaccination vac 
 on dea.location = vac.location 
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * from #PercentagePopulationVaccinated

create view InfectionRateByCountry as
select Location, Population, max(total_cases) as HighestInfectionCount,max(round((total_cases/population*100),2)) as InfectionRate
from CovidDeaths
--where location like '%Africa%' 
group by location,population
order by 4 desc



