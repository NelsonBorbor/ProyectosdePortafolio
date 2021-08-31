
/*
Covid 19 Data Exploration (Exploración de datos)
Habilidades Usadas: Joins, CTE's, Tablas temporales, Funciones ventana, Funciones agregadas, Creación de Vistas, Conversión de Tipos de Dato
*/

-- Seleccionamos la Data que vamos a usar para revisión previa.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject. . CovidDeaths
ORDER BY 1,2;

-- Número de Casos vs Total de Muertes
-- Muestra la probabilidad de muerte al contraer Covid en Perú.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PorcentajedeMuerte
FROM PortfolioProject. . CovidDeaths
WHERE location = 'Peru'
ORDER BY 1,2;

-- Muestra que porcentaje de la población en Perú contrajo Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject. . CovidDeaths
WHERE location = 'Peru'
ORDER BY 1,2;

-- Paises con un Alto Ratio de Infectados comparado a su población

SELECT location, population, MAX(total_cases) AS HightestInfectionCount, MAX((total_cases/population))*100 AS PorcentajedePoblacionInfectada
FROM PortfolioProject. . CovidDeaths
GROUP BY location, population
ORDER BY PorcentajedePoblacionInfectada DESC;

-- Paises con el Número más Alto de Muertes por Población

SELECT location, continent, MAX(cast(total_deaths AS int)) AS NumerodeMuertes
FROM PortfolioProject. . CovidDeaths
WHERE continent <> ''
GROUP BY location, continent
ORDER BY NumerodeMuertes DESC;

-- Continentes con el Número más Alto de Muertes por Población

SELECT continent, MAX(cast(total_deaths AS int)) AS NumerodeMuertes
FROM PortfolioProject. . CovidDeaths
WHERE continent != ''
GROUP BY continent
ORDER BY NumerodeMuertes DESC;


-- Población Total vs Vacunados
-- Muestra el Porcentaje de Población que ha recibido al menos una dosis de vacuna contra el covid, usando CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PersonasVacunadas)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS PersonasVacunadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)
SELECT *, (PersonasVacunadas/Population)*100
FROM PopvsVac;

-- Muestra el Porcentaje de Población que ha recibido a menos una dosis de vacuna contra el covid (El mismo del Query anterior), usando Tablas Temporales

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations FLOAT,
PersonasVacunadas NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT, (vac.new_vaccinations))) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS PersonasVacunadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (PersonasVacunadas/Population)*100
FROM #PercentPopulationVaccinated;


-- Creación de Vista para Almacenar Datos y Gestionar Visualizaciones en más adelante

CREATE VIEW PoblacionTotalvsVacunados AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS PersonasVacunadas
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

