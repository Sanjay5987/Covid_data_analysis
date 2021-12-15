Select * 
from portfolioproject..coviddeaths
where continent is not null
order by date
--select *
--from portfolioproject..covidvaccination
--order by date

--select the data that we are going to use
Select Location,date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

--looking at total cases Vs total Deaths
--shows the liklihood dying if you contact covid in your country
Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..coviddeaths
where Location = 'India'
order by 1,2

--looking at the total cases V/s the population
--shows what percentage of population got covid

Select Location,date,  population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from portfolioproject..coviddeaths
where Location = 'India' 

order by 1,2

--looking at counrty-wise infection rate

Select Location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..coviddeaths
where continent is not null
group by Location, population
order by percentpopulationinfected Desc


--LET'S BREAK THINGS BY CONTINENTS


--looking at continent-wise Death count

Select continent,  max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
where continent is not null
group by  continent
order by totaldeathcount Desc

--Global Numbers

Select date, sum(new_cases) as totalcasesworldwide--, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..coviddeaths
--where Location = 'India'
where new_cases is not null 
group by date
order by date

--total death and cases worldwide as on date
Select date, sum(new_cases) as totalcasesworldwide, sum(cast(new_deaths as int)) as totaldeathsworldwide, (sum(cast(new_deaths as int))/sum(new_cases))*100 as totaldeathpercent
from portfolioproject..coviddeaths
--where Location = 'India'
where continent is not null
group by date
order by date

--looking at totalcases, totaldeath and totaldeathpercent in the world till now

Select  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as totaldeathpercent
from portfolioproject..coviddeaths
where continent is not null

--Looking at total population Vs Vaccination

select dth.continent, dth.location, dth.date, dth.population,  vcn.new_vaccinations
from portfolioproject..coviddeaths dth
JOIN portfolioproject..covidvaccination vcn
 on dth.location = vcn.location
 and dth.date = vcn.date
where dth.continent is not null
order by 1,2,3

select dth.continent, dth.location, dth.date, dth.population,  vcn.new_vaccinations
,sum(convert(bigint,vcn.new_vaccinations)) OVER (partition by dth.Location order by dth.Location, 
 dth.Date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dth
JOIN portfolioproject..covidvaccination vcn
 on dth.location = vcn.location
 and dth.date = vcn.date
where dth.continent is not null
order by 1,2,3

--USE CTE

with PopvsVac (Continent,Location, Date,Population,new_vaccinations, rollingpeoplevaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population,  vcn.new_vaccinations
,sum(convert(bigint,vcn.new_vaccinations)) OVER (partition by dth.Location order by dth.Location, 
 dth.Date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dth
JOIN portfolioproject..covidvaccination vcn
 on dth.location = vcn.location
 and dth.date = vcn.date
where dth.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

--Looking at total population Vs Vaccination on bsis of countries

select dth.location, dth.population, sum(dth.new_cases) as cases, sum(cast(dth.new_deaths as int)) as Deaths, sum(convert(bigint,vcn.new_vaccinations)) as vaccination
from portfolioproject..coviddeaths dth
JOIN portfolioproject..covidvaccination vcn
 on dth.location = vcn.location
 and dth.date = vcn.date
where dth.continent is not null 
group by dth.location,dth.population
order by 1,2,3

--TEMP TABLE

CREATE TABLE #percentpopulationvaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dth.continent, dth.location, dth.date, dth.population,  vcn.new_vaccinations
,sum(convert(bigint,vcn.new_vaccinations)) OVER (partition by dth.Location order by dth.Location, 
 dth.Date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dth
JOIN portfolioproject..covidvaccination vcn
 on dth.location = vcn.location
 and dth.date = vcn.date
where dth.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--Creating View to store data for later visualizations

Create View APercentPeopleVacinated as
select dth.continent, dth.location, dth.date, dth.population,  vcn.new_vaccinations
,sum(convert(bigint,vcn.new_vaccinations)) OVER (partition by dth.Location order by dth.Location, 
 dth.Date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dth
JOIN portfolioproject..covidvaccination vcn
 on dth.location = vcn.location
 and dth.date = vcn.date
where dth.continent is not null

select * 
from APercentPeopleVacinated;

