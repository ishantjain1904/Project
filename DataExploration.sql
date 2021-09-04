SELECT * FROM SQL_PROJECT..CovidDeath
ORDER BY 3,4

--SELECT * FROM SQL_PROJECT..CovidVaccination
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population FROM SQL_PROJECT..CovidDeath
ORDER BY 1,2



--total cases vs total deaths per country
--Shows death percentage of covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage FROM SQL_PROJECT..CovidDeath
WHERE location LIKE '%India%'
ORDER BY 1,2

--total cases vs population
--shows what percentage of population affected by covid
SELECT location,date,population,total_cases,(total_cases/population)*100 AS CovidaAffectPercentage  FROM SQL_PROJECT..CovidDeath
WHERE location LIKE '%India%'
ORDER BY 1,2




--look at countries with highest infction rate compared with population
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 AS MaxPercentagePopulationInfected  
FROM SQL_PROJECT..CovidDeath
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY MaxPercentagePopulationInfected DESC

--shows countries with highest death per population 
SELECT location,MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM SQL_PROJECT..CovidDeath  
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

----by CONTINENT
SELECT location,MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM SQL_PROJECT..CovidDeath  
--WHERE location LIKE '%India%'
WHERE continent IS NOT  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--continents with highest death
SELECT location,MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM SQL_PROJECT..CovidDeath  
--WHERE location LIKE '%India%'
WHERE continent IS   NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--global numbers per date
SELECT date,SUM(new_cases) AS TOTALCASES,SUM(CAST(new_deaths AS INT)) AS TOTALDEATHS,
(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage 
FROM SQL_PROJECT..CovidDeath
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--TOTAL POPULATION VS VACCINATION
SELECT D.continent,D.location,D.date,D.population,
V.new_vaccinations
FROM SQL_PROJECT..CovidDeath AS D
JOIN SQL_PROJECT..CovidVaccination AS V
ON D.location=V.location  AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

--TOTAL VACCINATION ADDED TO TOTAL
SELECT D.continent,D.location,D.date,D.population,
V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS INT)) 
OVER(PARTITION BY D.location ORDER BY D.location,D.date) 
AS ROLLINGVACCINATION,
FROM SQL_PROJECT..CovidDeath AS D
JOIN SQL_PROJECT..CovidVaccination AS V
ON D.location=V.location  AND D.date = V.date
WHERE D.continent IS NOT NULL
--AND D.location='India'
ORDER BY 2,3

--USING CTE
WITH PopulationvsVaccination (Continent,Location,Date,Population,New_vaccination,RollingPeopleVaccinated)
AS (
SELECT D.continent,D.location,D.date,D.population,
V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS INT)) 
OVER(PARTITION BY D.location ORDER BY D.location,D.date) 
AS ROLLINGVACCINATION
FROM SQL_PROJECT..CovidDeath AS D
JOIN SQL_PROJECT..CovidVaccination AS V
ON D.location=V.location  AND D.date = V.date
WHERE D.continent IS NOT NULL
--AND D.location='India'
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM PopulationvsVaccination
--WHERE Location='India'



--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent,D.location,D.date,D.population,
V.new_vaccinations,
SUM(CAST(V.new_vaccinations AS INT)) 
OVER(PARTITION BY D.location ORDER BY D.location,D.date) 
AS RollingPeopleVaccinated
FROM SQL_PROJECT..CovidDeath AS D
JOIN SQL_PROJECT..CovidVaccination AS V
ON D.location=V.location  AND D.date = V.date
WHERE D.continent IS NOT NULL
--AND D.location='India'
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated



