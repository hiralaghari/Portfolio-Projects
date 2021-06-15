Select * from PortfolioProject..Covid_Deaths$
order by 3,4

--Select * from PortfolioProject..Covid_Vaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths$
order by 1,2

-- Total Cases vs Total Deaths: shows likelihood of death by COVID-19 in the United Arab Emirates
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from PortfolioProject..Covid_Deaths$
where location like '%emirates%'
order by 1,2

-- Total Cases vs Population: shows what percentage of the population got infected with COVID-19
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..Covid_Deaths$
where location like '%emirates%'
order by 1,2

-- Countries with highest infection rates compared to population
Select Location, MAX(total_cases) as CasesToDate, population, MAX((total_cases/population))*100 as PopulationInfectedPercentage
from PortfolioProject..Covid_Deaths$
group by population, location
order by PopulationInfectedPercentage desc

-- Countries with highest death count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Continent with highest death count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths$
where continent is null
group by location
order by TotalDeathCount desc


-- World deaths percentage by date
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as PercentageDeath
from PortfolioProject..Covid_Deaths$
where continent is not null
group by date
order by 1,2

-- World deaths percentage total
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as PercentageDeath
from PortfolioProject..Covid_Deaths$
where continent is not null
order by 1,2

-- Joining the two tables
Select *
from PortfolioProject..Covid_Deaths$ as death
join PortfolioProject..Covid_Vaccinations$ as vax
    on death.location = vax.location
	and death.date = vax.date

-- Total population vs Vaccinations
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
from PortfolioProject..Covid_Deaths$ as death
join PortfolioProject..Covid_Vaccinations$ as vax
    on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
order by 2,3

-- Total population vs aggregate of vaccinations
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, sum(convert(int,vax.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingVaccinations
from PortfolioProject..Covid_Deaths$ as death
join PortfolioProject..Covid_Vaccinations$ as vax
    on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
order by 2,3

With PopvsVax (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, sum(convert(int,vax.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingVaccinations
from PortfolioProject..Covid_Deaths$ as death
join PortfolioProject..Covid_Vaccinations$ as vax
    on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
)
Select *, (RollingVaccinations/Population)*100
from PopvsVax


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as int)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject..Covid_Deaths$ death
Join PortfolioProject..Covid_Vaccinations$ vax
	On death.location = vax.location
	and death.date = vax.date


Select *, (RollingVaccinations/Population)*100
From #PercentPopulationVaccinated



Create view PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, sum(convert(int,vax.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as RollingVaccinations
from PortfolioProject..Covid_Deaths$ as death
join PortfolioProject..Covid_Vaccinations$ as vax
    on death.location = vax.location
	and death.date = vax.date
where death.continent is not null

Select *
from PercentPopulationVaccinated
