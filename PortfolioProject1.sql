SELECT*
FROM CovidDeaths
ORDER BY 1, 2

SELECT Location, date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--SHOWING TOTAL CASES AGAINST TOTAL DEATHS
SELECT location,date,total_cases,total_deaths,(CONVERT(FLOAT,total_deaths)
/NULLIF(CONVERT(FLOAT,Total_cases),0)) *100 AS DeathPercentage 
FROM CovidDeaths
ORDER BY 1,2

--SHOWING TOTAL CASES VS POPULATION
SELECT location,date,total_cases,population,(total_cases/population)*100 AS RateOfInfection
FROM CovidDeaths
WHERE location like 'Canada%'
ORDER BY 1,2

--SHOWING COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO THEIR POPULATION
SELECT location,population,MAX(Cast(Total_cases as int)) AS HighestInfectionCount,(MAX(Total_cases)/population)*100 AS RatteOfInfection
FROM CovidDeaths
GROUP BY location,population
ORDER BY 1,2

--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT location,MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

--SHOWING EACH COUNTRY AND THEIR DEATH COUNT IN NORTH AMERICA
SELECT continent,location, MAX(total_deaths) AS TotalDeathPerCountry
FROM CovidDeaths
WHERE continent='north america'
GROUP BY continent,location
ORDER BY TotalDeathPerCountry DESC

--SHOWING GLOBAL NUMBERS
SELECT Date,SUM(new_cases)AS TotalCases, SUM(Cast(New_deaths as int)) AS TotalDeaths,
SUM(Cast(New_deaths as int))/NULLIF(SUM(New_cases),0)*100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

CREATE VIEW GlobalNumbers AS 
SELECT Date,SUM(new_cases)AS TotalCases, SUM(Cast(New_deaths as int)) AS TotalDeaths,
SUM(Cast(New_deaths as int))/NULLIF(SUM(New_cases),0)*100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date

--SHOWING TOTAL CASES, DEATHS AND OVERALL PERCENTAGE
SELECT SUM(new_cases)AS TotalCases, SUM(Cast(New_deaths as int)) AS TotalDeaths,
SUM(Cast(New_deaths as int))/NULLIF(SUM(New_cases),0)*100 AS OverallDeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--SHOWING TOTAL POPULATION AGAINST VACCINATIONS
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location=Vac.location and Dea.date=vac.date
WHERE Dea.continent is not null
ORDER BY 1,2,3

--SHOWING TOTAL POPULATION AGAINST TOTAL VACCINATIONS PER LOCATION
SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.Location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date
WHERE Dea.continent is not null
Order by 2,3

--SHOWING PERCENTAGE OF POPULATION VACCINATEDD PER LOCATION
WITH PopVsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.Location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date
WHERE Dea.continent is not null
)

SELECT*,(RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.Location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date
--WHERE Dea.continent is not null
--Order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS
Create View PercentPopulationVaccinated AS
SELECT Dea.continent,Dea.location,Dea.date,Dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER(PARTITION BY Dea.Location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date
WHERE Dea.continent is not null