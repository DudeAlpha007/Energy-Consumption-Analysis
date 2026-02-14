CREATE DATABASE energy;
USE energy;

-- 1. country table
CREATE TABLE country (
CID VARCHAR(10) PRIMARY KEY,
Country VARCHAR(100) UNIQUE
);
SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
country VARCHAR(100),
energy_type VARCHAR(50),
year INT,
emission INT,
per_capita_emission DOUBLE,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
countries VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (countries) REFERENCES country(Country)
);
SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
production INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
Country VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (Country) REFERENCES country(Country)
);
SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
country VARCHAR(100),
energy VARCHAR(50),
year INT,
consumption INT,
FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM CONSUMPTION;

-- 1) General & Comparative Analysis

-- What is the total emission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;

-- What are the top 5 countries by GDP in the most recent year?
select country, value as GDP
from GDP_3
where year = (select max(year) from GDP_3)
order by GDP desc
limit 5;

-- Compare energy production and consumption by country and year.
SELECT
    pr.country,
    pr.year,
    SUM(pr.production) AS total_production,
    SUM(c.consumption) AS total_consumption
FROM production pr
JOIN consumption c
    ON pr.country = c.country
   AND pr.year = c.year
GROUP BY pr.country, pr.year
ORDER BY pr.country, pr.year;


-- Which energy types contribute most to emissions across all countries?
SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;


-- 2) Trend Analysis Over Time
-- How have global emissions changed year over year?
select * from emission_3;

SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- What is the trend in GDP for each country over the given years?
SELECT Country, year, Value AS gdp_value
FROM gdp_3
ORDER BY Country, year;

-- How has population growth affected total emissions in each country?
select 
	p.countries,
	p.year,
	p.value as population,
	sum(e.emission) as total_emission
from population as p
inner join emission_3 as e
on p.countries = e.country and p.year = e.year
group by p.countries, p.year, population
order by countries, year;

-- Has energy consumption increased or decreased over the years for major economies?
WITH major_economies AS (
    SELECT Country
    FROM gdp_3
    WHERE year = (SELECT MAX(year) FROM gdp_3)
    ORDER BY Value DESC
    LIMIT 5
)
SELECT
    c.country,
    c.year,
    SUM(c.consumption) AS total_consumption
FROM consumption c
INNER JOIN major_economies m
    ON c.country = m.Country
GROUP BY c.country, c.year
ORDER BY c.country, c.year;

-- What is the average yearly change in emissions per capita for each country?
WITH total_emission AS (
    SELECT
        country,
        year,
        SUM(emission) AS total_emission
    FROM emission_3
    GROUP BY country, year
),

per_capita AS (
    SELECT
        e.country,
        e.year,
        e.total_emission / p.value AS pc_emission
    FROM total_emission e
    JOIN population p
        ON e.country = p.countries
       AND e.year = p.year
),

changes AS (
    SELECT
        country,
        year,
        pc_emission -
        LAG(pc_emission) OVER (PARTITION BY country ORDER BY year) AS yearly_change
    FROM per_capita
)

SELECT
    country,
    ROUND(AVG(yearly_change),6) AS avg_yearly_change_per_capita
FROM changes
WHERE yearly_change IS NOT NULL
GROUP BY country
ORDER BY avg_yearly_change_per_capita DESC;




-- 3) Ratio & Per Capita Analysis
-- What is the emission-to-GDP ratio for each country by year?
SELECT
    e.country,
    e.year,
    SUM(e.emission) / g.Value AS emission_to_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
    ON e.country = g.Country
   AND e.year = g.year
GROUP BY e.country, e.year, g.Value
ORDER BY e.country, e.year;

-- What is the energy consumption per capita for each country over the last decade?
WITH recent_years AS (
    SELECT MAX(year) AS max_year FROM consumption
)
SELECT
    c.country,
    c.year,
    SUM(c.consumption) / p.Value AS consumption_per_capita
FROM consumption c
JOIN population p
    ON c.country = p.countries
   AND c.year = p.year
JOIN recent_years r
    ON c.year BETWEEN r.max_year - 9 AND r.max_year
GROUP BY c.country, c.year, p.Value
ORDER BY c.country, c.year;

-- How does energy production per capita vary across countries?
SELECT
    pr.country,
    pr.year,
    SUM(pr.production) / p.Value AS production_per_capita
FROM production pr
JOIN population p
    ON pr.country = p.countries
   AND pr.year = p.year
GROUP BY pr.country, pr.year, p.Value
ORDER BY production_per_capita DESC;

-- Which countries have the highest energy consumption relative to GDP?
SELECT
    c.country,
    c.year,
    SUM(c.consumption) / g.Value AS consumption_to_gdp_ratio
FROM consumption c
JOIN gdp_3 g
    ON c.country = g.Country
   AND c.year = g.year
GROUP BY c.country, c.year, g.Value
ORDER BY consumption_to_gdp_ratio DESC;

-- What is the correlation between GDP growth and energy production growth?
WITH gdp_growth AS (
    SELECT
        Country AS country,
        year,
        Value - LAG(Value) OVER (PARTITION BY Country ORDER BY year) AS gdp_growth
    FROM gdp_3
),
production_growth AS (
    SELECT
        country,
        year,
        SUM(production) -
        LAG(SUM(production)) OVER (PARTITION BY country ORDER BY year) AS prod_growth
    FROM production
    GROUP BY country, year
),
combined AS (
    SELECT
        g.country,
        g.year,
        g.gdp_growth,
        p.prod_growth,
        AVG(g.gdp_growth) OVER (PARTITION BY g.country) AS avg_gdp_growth,
        AVG(p.prod_growth) OVER (PARTITION BY p.country) AS avg_prod_growth
    FROM gdp_growth g
    JOIN production_growth p
        ON g.country = p.country
       AND g.year = p.year
    WHERE g.gdp_growth IS NOT NULL
      AND p.prod_growth IS NOT NULL
)
SELECT
    country,
    ROUND(
        SUM((gdp_growth - avg_gdp_growth) * (prod_growth - avg_prod_growth)) /
        SQRT(
            SUM(POW(gdp_growth - avg_gdp_growth, 2)) *
            SUM(POW(prod_growth - avg_prod_growth, 2))
        ),
        4
    ) AS gdp_production_correlation
FROM combined
GROUP BY country
HAVING gdp_production_correlation IS NOT NULL
ORDER BY gdp_production_correlation DESC;



-- 4) Global Comparisons
-- What are the top 10 countries by population and how do their emissions compare?
WITH latest_population_year AS (
    SELECT MAX(year) AS pop_year FROM population
),
latest_emission_year AS (
    SELECT MAX(year) AS emis_year FROM emission_3
),
top_population AS (
    SELECT
        p.countries AS country,
        p.Value AS population
    FROM population p
    JOIN latest_population_year lp
        ON p.year = lp.pop_year
    ORDER BY p.Value DESC
    LIMIT 10
)
SELECT
    t.country,
    t.population,
    SUM(e.emission) AS total_emission
FROM top_population t
LEFT JOIN emission_3 e
    ON t.country = e.country
   AND e.year = (SELECT emis_year FROM latest_emission_year)
GROUP BY t.country, t.population
ORDER BY total_emission DESC;

-- Which countries have improved (reduced) their per capita emissions the most over the last decade?
WITH year_bounds AS (
    SELECT MAX(year) AS max_year FROM emission_3
),
last_decade_data AS (
    SELECT
        e.country,
        e.year,
        e.per_capita_emission
    FROM emission_3 e
    JOIN year_bounds y
      ON e.year BETWEEN y.max_year - 9 AND y.max_year
),
country_bounds AS (
    SELECT
        country,
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM last_decade_data
    GROUP BY country
),
per_capita_change AS (
    SELECT
        c.country,
        MAX(CASE WHEN d.year = c.first_year THEN d.per_capita_emission END) AS past_value,
        MAX(CASE WHEN d.year = c.last_year THEN d.per_capita_emission END) AS recent_value
    FROM country_bounds c
    JOIN last_decade_data d
      ON c.country = d.country
    GROUP BY c.country
)
SELECT
    country,
    ROUND(past_value - recent_value, 4) AS per_capita_reduction
FROM per_capita_change
WHERE past_value IS NOT NULL
  AND recent_value IS NOT NULL
ORDER BY per_capita_reduction DESC;

-- What is the global share (%) of emissions by country?
SELECT
    country,
    ROUND(
        SUM(emission) * 100.0 /
        (SELECT SUM(emission) FROM emission_3),
        2
    ) AS global_emission_share_percent
FROM emission_3
GROUP BY country
ORDER BY global_emission_share_percent DESC;

-- What is the global average GDP, emission, and population by year?
SELECT
    g.year,
    AVG(g.Value) AS avg_gdp,
    AVG(e.emission) AS avg_emission,
    AVG(p.Value) AS avg_population
FROM gdp_3 g
JOIN emission_3 e
    ON g.Country = e.country
   AND g.year = e.year
JOIN population p
    ON g.Country = p.countries
   AND g.year = p.year
GROUP BY g.year
ORDER BY g.year;
