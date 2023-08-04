/*

COVID-19 in the year 2020–2021 Data Exploration

Skills used: Joins, CTE's, Temp tables, Window functions, Aggregriate Functions, Creating Views, Converting Data Types

*/

Select*
From Portfolio1..CovidDeaths
Where continent is not null
Order by 1,2


--Data exploration starting point

Select continent, date, population, new_cases, total_cases, total_deaths
From Portfolio1..CovidDeaths
Order by 1,2


--Possible risk of death when people get infected by COVID-19 in the selected country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..CovidDeaths
Where location like 'Philippines'
and continent is not null
Order by 1,2


--Percentage of the infected population with COVID-19

Select location, date, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio1..CovidDeaths
Order by 1,2


--Countries with the highest infection rate compared to their population

Select location, population, MAX(total_cases) as HighestInfectionRate, MAX(total_cases/population)*100 PercentPopulationInfected
From Portfolio1..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


--Countries with the highest death rate per population

Select location, MAX(Cast(total_deaths as int)) as TotalDeathRate
From Portfolio1..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathRate desc


--Breaking things down by Continent

--Countries with the highest death rate per population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathRate
From Portfolio1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathRate desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio1..CovidDeaths
Where continent is not null
Order by 1,2


--Percentage of the population received at least one COVID vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition  by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1, 2


--Using CTE to perform calculation on partition by in previous query

With PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVac


--Using temp table to perform calculation on partition by in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio1..CovidDeaths dea
Join Portfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null