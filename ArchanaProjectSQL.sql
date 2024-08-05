--select data from PortfolioProject database, coviddeaths table using order 3,4
Select *
From PortfolioProject..CovidDeaths
order by 3,4

--select data from PortfolioProject database, covidVaccinations table using order 3,4
Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--select date, location and other infromation from PortfolioProject database, coviddeaths table 
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs Total deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
Where location Like'%India%'
order by 1,2


--looking at total cases vs population

Select location, date, total_cases,Population, (total_cases/population)*100 as PercentagePoluationInfected
From PortfolioProject..CovidDeaths
Where location Like'%India%'
order by 1,2

--looking at countries wiht highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePoluationInfected
From PortfolioProject..CovidDeaths
Where location Like'%India%'
Group by location, population
order by PercentagePoluationInfected desc

--showing countries with highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is NOT NULL
Group by continent
order by TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases),SUM(cast(new_deaths as int)) as total_deaths, SUM(New_Cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
Where Continent is NOT NULL
Group By date
order by 1,2

---Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int, new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is NOT NULL
order by 2,3

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int, new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is NOT NULL
)
select*, (RollingVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(25),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int, new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


select*, (RollingVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visualisations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int, new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is NOT NULL

