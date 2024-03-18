Select *
From WORKK..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From WORKK..CovidVaccinations
--order by 3,4 

--SELECTS THE DATA THAT WE ARE GOING TO BE USING 

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
Select location, date, total_cases, total_deaths , (total_deaths/total_cases) * 100 as DeathPercentage
From WORKK..CovidDeaths
 -- WHERE location like '%africa%' (FINDS ALL INSTANCES IN THE LOCATION WHERE  '%WHATEVER WRITTEN%'  APPEARS)
order by 1,2 -- FOLLOWS THE ORDER OF THE ROW LOCATION ALPHABETICALLY

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
Select location, date , population , total_cases, (total_cases/population) * 100 as  PERCENTPOPULATIONINFECTION
from WORKK..CovidDeaths 
--where total_cases is not null
order by 2


--LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION


Select location , population , MAX(total_cases) as HighestinfectionCount, MAX ((total_cases/population))*100 as PERCENTPOPULATIONINFECTION
from WORKK..CovidDeaths
where continent is not null
Group by location , population
order by PERCENTPOPULATIONINFECTION desc

--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from WORKK..CovidDeaths
where continent is  null
Group by location , population
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

--SHOWING CONTINENTS WITH THE HIGHEST DEATHCOUNT PER POPULATION
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from WORKK..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--LOOKING AT TOTAL CASES VS TOTAL DEATHS(SCROLL UP)

-- GLOBAL NUMBERS

Select date,  SUM(new_cases) as Totalcases , SUM(cast(new_deaths as int)) as Totaldeath,SUM (Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From WORKK..CovidDeaths
-- WHERE location like '%states%'
where continent is not null
Group by date
order by 1,2 -- FOLLOWS THE ORDER OF THE LOCATION ALPHABETICALLY

--JOINING THE TWO TABLES TOGETHER

SELECT *
From WORKK..CovidDeaths dea
JOIN WORKK..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date

--LOOKING AT TOTAL POPULATION VS DEATHS

SELECT dea.continent, dea.date, dea.population, dea.location , dea.new_deaths
From WORKK..CovidDeaths dea
JOIN WORKK..CovidVaccinations vac
On dea.location =vac.location
where vac.new_vaccinations is not null
and dea.continent is not null
and dea.date = vac.date
order by 2

 -- LOOKING AT TOTAL POPULATION VS VACCINATION


SELECT dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date ) as ROLLINGPEOPLEVACCINATED

-- (ROLLINGCOUNTFORVACINATTEDPEOPLE/population) * 100 as PERCENTAGEOFvaccinatedpeople
--OTHER WAYS TO CONVERT TO INT
--SUM(CONVERT(int,vac.new_vaccinations))
--THIS SUM(CAST) HERE SUMS THE TOTAL VACINNES DISTRIBUTED TO A SPECIFIC LOCATION 
-- THE OVER (PARTITION BY SPLITS/DISTRIBUTES T
--ROLLINGCOUNTFORVACINATTEDPEOPLE WAS CREATED SO TO CALL IT OR GIVE IT A FUNCTION WE HAVE TO USE CTE
--OR A TEMPORARY TABLE
From WORKK..CovidDeaths dea
JOIN WORKK..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
--where vac.new_vaccinations is not null
where dea.continent is not null
--and vac.new_vaccinations is not null
-- and vac.location like '%nigeria%' --(NIGERIA GOT THEIR FIRST COVID VACCINATION (2021 04 01)4TH OF JANUARY 2021
order by 2,3

-- USE CTE

--FOR POPULATION VS VACCINATTION


--with pplation vs vaccine (the column labels we want) select are the labels wanted int the columns 
with PopvsVac (continent,location,date,population,new_Vaccinations,ROLLINGPEOPLEVACCINATED)
as
(
SELECT dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date ) as ROLLINGPEOPLEVACCINATED
--OTHER WAYS TO CONVERT TO INT
--SUM(CONVERT(int,vac.new_vaccinations))
--THIS SUM(CAST) HERE SUMS THE TOTAL VACINNES DISTRIBUTED TO A SPECIFIC LOCATION 
-- THE OVER (PARTITION BY SPLITS/DISTRIBUTES T

From WORKK..CovidDeaths dea
JOIN WORKK..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
--where vac.new_vaccinations is not null
where dea.continent is not null
--and vac.new_vaccinations is not null
-- and vac.location like '%nigeria%' --(NIGERIA GOT THEIR FIRST COVID VACCINATION (2021 04 01)4TH OF JANUARY 2021
--order by 2,3
)
select *, (ROLLINGPEOPLEVACCINATED/population) * 100 as PERCENTAGEOFvaccinatedpeople
From POPVSVAC

--CREATING A TEMPORARY TABLE
--we can also use a temporary table to insert values,in columns 
DROP Table if exists #PERCENTAGEPOPULATIONVACCINATED
Create Table #PERCENTAGEPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population numeric,
New_vaccination numeric,
ROLLINGPEOPLEVACCINATED numeric
)
Insert into #PERCENTAGEPOPULATIONVACCINATED
Select dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location ) as ROLLINGPEOPLEVACCINATED
--OTHER WAYS TO CONVERT TO INT
--SUM(CONVERT(int,vac.new_vaccinations))
--THIS SUM(CAST) HERE SUMS THE TOTAL VACINNES DISTRIBUTED TO A SPECIFIC LOCATION 
-- THE OVER (PARTITION BY SPLITS/DISTRIBUTES T

From WORKK..CovidDeaths dea
JOIN WORKK..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
--where vac.new_vaccinations is not null
where dea.continent is not null
--and vac.new_vaccinations is not null
-- and vac.location like '%nigeria%' --(NIGERIA GOT THEIR FIRST COVID VACCINATION (2021 04 01)4TH OF JANUARY 2021
select *, (ROLLINGPEOPLEVACCINATED/population) * 100 as PercentageOfVacinattedPeople
From #PERCENTAGEPOPULATIONVACCINATED
order by 2,3


--CREATING A VIEW TO STORE DATABASE FOR LATER VISUALIZATION

 CREATE View PERCENTPOPULATIONVACCINATED as
Select dea.continent, dea.location , dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by 2, 3 ) as ROLLINGPEOPLEVACCINATED
From WORKK..CovidDeaths dea
JOIN WORKK..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--RUN THIS CODE BELOW TO CREATE THE TABLE FOR THE CREATED VIEW (A FUNCTION PERCENTPOPULATIONVACCINATED WAS GIVEN TO CREAT THE VIEW

Select *
From PERCENTPOPULATIONVACCINATED