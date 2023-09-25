
SELECT *	
FROM PortfolioProject..CovidDeaths$

ORDER BY 3,4


SELECT * 
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

--SELECT DATA 

SELECT location , date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 1,2

--Looking at the total cases vs total deaths

SELECT location , date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeatPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 1,2

-- Shows likelihood of dying if you contract Covid on your Country


SELECT location , date, total_cases, population ,total_deaths,(total_deaths/total_cases)*100 as DeatPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%turkey%' and  continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows What Percentage of Population got Covid

SELECT location , date,population , total_cases, (total_cases/population)*100 as TotalcasePercentage
FROM PortfolioProject..CovidDeaths$
where location like '%turkey%'and continent is not null
Order By 1,2

-- Which country have a highest  infection rates compared to  population 

SELECT  location , population , MAX(total_cases) AS HighestİnfectionCount, max((total_cases/population))*100 as TotalcasePercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location,population
Order By TotalcasePercentage desc

 -- Showing the countries with highest Death  Count per Population

 SELECT  location , MAX(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location
Order By TotalDeathCount desc


-- Break data  down by continent

 SELECT  location , MAX(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is  null
Group by location
Order By TotalDeathCount desc
 
--Break data  down by continent second way

  SELECT  continent , MAX(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order By TotalDeathCount desc

--Global numbers
 
SELECT date, sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeatPercentage --, total_deaths,(total_deaths/total_cases)*100 as DeatPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null-- and location like '&turkey&'
group by date 
ORDER BY 1,2


-- Global Total case and total deat and totaldeath/totalcase

SELECT  sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeatPercentage --, total_deaths,(total_deaths/total_cases)*100 as DeatPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null-- and location like '&turkey&'


-- Looking at total population vs vaccation 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with  PopvsVac (Continent,Location,Date,Population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null -- and dea.new_vaccinations is not null
--order by 2,3

)
select * ,(rollingpeoplevaccinated/Population)*100
from PopvsVac


-- use temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location= vac.location
and dea.date= vac.date
--where dea.continent is not null
--order by 1,2 

--note for reader
-- if your ms management studio is older than 2016 you cant use DROP TABLE IF EXISTS Tablename;
-- you should use 
-- IF OBJECT_ID('Tablename', 'U') IS NOT NULL
-- DROP TABLE Tablename;



select * ,(rollingpeoplevaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 1,2 