-- Select *
-- From PortfolioProject..CovidDeaths
-- Order by 3,4

-- Select *
-- From PortfolioProject..CovidVaccinations
-- Order by 3,4 

Select LOCATION, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Order by 1,2 

--Looking at Total Cases vs Total Deaths 
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, total_cases, population, (cast(total_cases as float)/cast( population as float))*100 as Precentage_of_Infected
From PortfolioProject..CovidDeaths
-- where location like '%India%'
order by 1,2

-- Looking at Countries with Highest Infection Rate Compare to Population 

Select Location, population, Max(total_Cases) as HighestInfectionCount, Max(cast(total_cases as float)/cast( population as float))*100 as InfectionRate
From PortfolioProject..CovidDeaths
-- where location like '%India%' 
where continent is not null 
Group by location,population
order by InfectionRate desc


Select location, Max(cast(total_Cases as int)) as HighestInfectionCount --Max(cast(total_cases as float)/cast( population as float))*100 as InfectionRate
From PortfolioProject..CovidDeaths
-- where location like '%India%' 
where continent is  null 
Group by location
order by HighestInfectionCount desc


 
-- Global Numbers by date 


Select date, Sum(cast(total_Cases as float)) as TotalNumberOfCases, Sum(cast(new_deaths as float)) as TotalDeath,
Sum(cast(new_deaths as float))/Sum(cast(total_Cases as float))*100 as DeathPercent --Max(cast(total_cases as float)/cast( population as float))*100 as InfectionRate
From PortfolioProject..CovidDeaths
 
where continent is not null 
Group by date 
order by 1,2 


-- Looking at total Population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--* Use of Parititon by 
SUM (CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as New_Vaccinations_Daily
from PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     on dea.location =vac.[location] 
     and dea.date =vac.date
where dea.continent is not null 
order by 2,3



-- Use CTE 

With PopvsVac ( continent, location, date, Population, new_vaccinations, New_Vaccinations_Daily)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--* Use of Parititon by 
SUM (CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as New_Vaccinations_Daily
from PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     on dea.location =vac.[location] 
     and dea.date =vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (New_Vaccinations_Daily/Population)*100
From PopvsVac 




-- Temp Table 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(50),
    location nvarchar(50),
    Date date,
    population NVARCHAR(50),
    new_vaccinations NVARCHAR(50),
    New_Vaccinations_Daily NVARCHAR(50) 
      
)

Insert into #PercentPopulationVaccinated
--* Use of Parititon by 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as New_Vaccinations_Daily
from PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     on dea.location =vac.[location] 
     and dea.date =vac.date
where dea.continent is not null 
--order by 2,3

Select *, convert(float,(convert(float,New_Vaccinations_Daily)/convert(float,Population)))*100 as Vaccination_Percentage_Daily
From #PercentPopulationVaccinated 















 -- Creating view to store data for later visulization 

Create view PercentPeopleVacccinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as New_Vaccinations_Daily
from PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac 
     on dea.location =vac.[location] 
     and dea.date =vac.date
where dea.continent is not null 
--order by 2,3



 