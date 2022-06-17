

--Select *
--From MyPortfolioProject..CovidDeaths
--order by 3,4

--Select *
--From MyPortfolioProject..CovidVaccinations
--order by 3,4

--Select Data needed for analyses

Select location, date, total_cases, new_cases, total_deaths, population
From MyPortfolioProject..CovidDeaths
order by 1,2

--Total cases V total deaths (likelihood of dying if you contract covid)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentatge
From MyPortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2


-- total cases V population (percentation of population with Covid)

Select location, date, population, total_cases, (total_cases/population)*100 as percentatge_population_with_covid
From MyPortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2


--Countries with highest infection rate

Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases)/population)*100 as percentatge_population_with_covid
From MyPortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by percentatge_population_with_covid desc

--Countries with highest deaths per population

Select location, population, MAX(cast(total_deaths as int)) as total_death_count
From MyPortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by  total_death_count desc

---Continents Analyses

Select location, MAX(cast(total_deaths as int)) as total_death_count
From MyPortfolioProject..CovidDeaths
where continent is null
Group by location
order by  total_death_count desc


Select continent, MAX(cast(total_deaths as int)) as total_death_count
From MyPortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by  total_death_count desc


--Global Figures

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From MyPortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


--Join Covid_Deaths and Covid_Vaccinations

Select *
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Total Vac by population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as cummulative_people_vaccinated
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE

With PopByVac (continent, location, date, population, new_vaccinations, cummulative_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as cummulative_people_vaccinated
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (cummulative_people_vaccinated/population)*100 as percentage_population_vaccinate
From PopByVac
order by 2,3


With PopByVac (continent, location, population, new_vaccinations, cummulative_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location) as cummulative_people_vaccinated
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (cummulative_people_vaccinated/population)*100 as percentage_population_vaccinated
From PopByVac
order by 2,3


--Using Temp Table (did not work)

Drop Table if exists #PopByVac
Create Table #PopByVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cummulative_people_vaccinated numeric
)

Insert into #PopByVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as cummulative_people_vaccinated
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (cummulative_people_vaccinated/population)*100 as percentage_population_vaccinated
From #PopByVac




--Creating View for Visualizations
Drop View if exists PopByVac
Create View PopByVac 
AS ( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as cummulative_people_vaccinated
From MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)


Select *
From PopByVac
order by 2,3