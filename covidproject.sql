-- order by 1,2 refers to column 1 and column 2 as given in select statement
create database covid;
use covid;

select * from `coviddeaths` ;
set sql_safe_updates=0;
UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = '';
-- select * from `covidvaccinations` order by 3,4;
select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths;

-- looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from coviddeaths 
where location like 'egy%'
order by 1,2;

-- looking at total cases vs population
-- shows what percentage of population got covid
select location,date,total_cases,population,(total_deaths/population)*100 as deathPercentage
from coviddeaths 
where location like 'egy%'
order by 1,2;

-- looking at countries with highest infection rate compared to population
SELECT location, 
       population, 
       MAX(total_cases) AS max_total_cases, 
       (SUM(total_deaths) / population) * 100 AS deathPercentage
FROM coviddeaths
-- where location like 'egy%'
GROUP BY location, population
ORDER BY deathPercentage desc;

-- showing countries with highest death count per population
-- convert is to use to convert the decimal values into signed integer value
SELECT location, 
       max(convert(total_deaths , signed)) as TotalDeathCount
FROM coviddeaths
-- where location like 'egy%'
GROUP BY location
ORDER BY TotalDeathCount desc;

-- let's break things down by continent
SELECT continent, 
       max(convert(total_deaths , signed)) as TotalDeathCount
FROM coviddeaths
-- where location like 'egy%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- showing continents with the highjest death count
SELECT continent, 
       max(convert(total_deaths , signed)) as TotalDeathCount
FROM coviddeaths
-- where location like 'egy%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- global numbers
select sum(new_cases) as totalcases,sum(convert(new_deaths,signed)) as totaldeaths,
sum(convert(new_deaths,signed))/sum(new_cases)*100 as deathpercentage
 -- ,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from coviddeaths 
-- where location like 'egy%'
where continent is not null
-- group by date
order by 1,2;

-- another table
select * from covidvaccinations;

-- looking at total population vs vaccinations
update covidvaccinations
set new_vaccinations='null'
where new_vaccinations='';
-- select new_vaccinations from covidvaccinations;
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(vac.new_vaccinations,signed))over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from coviddeaths as dea
join covidvaccinations as vac
    on dea.location=vac.location 
    and dea.date=vac.date
where dea.continent is not null
order by 2,3;

-- use cte
with PopvsVac(Continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(vac.new_vaccinations,signed))over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
from coviddeaths as dea
join covidvaccinations as vac
    on dea.location=vac.location 
    and dea.date=vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac;

-- temp table
create table 