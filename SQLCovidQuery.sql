Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select * 
--From PortfolioProject..CovidVaccinations

-- Selecting the data from the table

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total cases Vs Total deaths
-- It shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location Like '%canada%'
and continent is not null
Order by 1,2



-- Looking at the total cases Vs Population
-- Shows what percentage of population got Covid
Select location, date,  population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location Like '%canada%'
Order by 1,2

-- Looking at highest infection rate countries compared to population

Select location,  population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location Like '%canada%'
Group by location,population
Order by PercentagePopulationInfected Desc


-- Showing Countries with highest death count per Population

Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location Like '%canada%'
Where continent is not null
Group by location
Order by TotalDeathCount Desc

-- Let's Do it by Continents

Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location Like '%canada%'
Where continent is null
and Location not like '%income%'
and Location not like '%Union%'
Group by location
Order by TotalDeathCount Desc

-- Showing continents with the highest death count per population
-- Ideally the following query should have considered for getting death count,
-- but, it is telling only one country in that continent with highest death count

-- So, individual country Death count and continent query as follows -
Select continent, location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location Like '%canada%'
Where continent is not null
Group by continent, Location
Order by TotalDeathCount Desc

-- Global Numbers
Select Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(cast(new_cases as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location Like '%canada%'
Where continent is not null
and new_cases not like '%0%'
--Group by date
Order by 1,2





Select *
From PortfolioProject.dbo.covidvaccinations
Order by 3,4

-- Let's look at total population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
From #PercentPopulationVaccinated
Where continent is not null
order by 2,3



-- Creating view to store data for visualisation


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated