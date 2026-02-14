# Energy Consumption & Emission Analysis (SQL Project)

## Project Overview

This project analyzes global energy consumption, production, emissions, GDP, and population data using SQL.

The goal is to understand how energy usage, economic growth, and population trends influence global carbon emissions and to identify country-level performance, efficiency patterns, and sustainability insights.

---

## Business Problem

Rising energy demand and carbon emissions make it difficult to balance economic growth with environmental sustainability.

Decision-makers often lack integrated analysis connecting:

- Energy Consumption
- Energy Production
- CO₂ Emissions
- GDP
- Population

This project provides structured SQL-based analysis to generate meaningful insights from multi-table datasets.

---

## Database Structure

The project consists of 6 relational tables:

1. **Country** – Master table containing unique country identifiers  
2. **Emission_3** – CO₂ emissions by country, year, and energy type  
3. **Consumption** – Energy consumption by country and year  
4. **Production** – Energy production by country and year  
5. **GDP_3** – Yearly GDP data  
6. **Population** – Yearly population data  

All tables are connected using **Country** as the primary linking attribute.  
Time-based analysis is performed using the **Year** column.

---

## Tools & Technologies

- MySQL (Version 8+)
- SQL (CTEs, Window Functions, Aggregations, Joins)
- Relational Database Design

---

## Key Analytical Areas

### 1️) General & Comparative Analysis
- Total emissions per country (latest year)
- Top 5 GDP countries
- Production vs Consumption comparison
- Energy types contributing most to emissions

### 2️) Trend Analysis
- Year-over-year global emission trends
- GDP growth trends by country
- Population vs emission patterns
- Per-capita emission changes over time

### 3️) Ratio & Per-Capita Analysis
- Emission-to-GDP ratio (carbon intensity)
- Energy consumption per capita
- Production per capita
- Energy intensity (consumption relative to GDP)

### 4️) Global Comparisons
- Top 10 countries by population & emissions
- Global emission share by country
- Global average GDP, emission & population trends
- Correlation between GDP growth and energy production growth

---

## Key Insights

- Emissions are heavily concentrated among a few major economies (China, USA, India).
- Fossil fuel-based energy sources dominate global CO₂ emissions.
- Larger populations contribute to higher total emissions, even when per-capita emissions are lower.
- Energy intensity (energy use per GDP) varies significantly across countries.
- Developed countries generally show higher per-capita energy usage compared to developing economies.
- Some countries demonstrate better economic output per unit of energy, indicating higher efficiency.

---

## Sample Business Interpretation

- Countries with higher energy consumption than production may depend on energy imports.
- High emission-to-GDP ratios indicate carbon-intensive economies.
- Per-capita metrics help differentiate between scale effects (population size) and development level.

---

## Project Highlights

- Designed normalized relational schema
- Implemented complex joins across multiple datasets
- Used CTEs and window functions (`LAG`, `AVG OVER`) for trend and growth analysis
- Calculated Pearson correlation using SQL
- Converted analytical outputs into business-level insights

---

## Assumptions & Notes

- Analysis performed using MySQL 8+ (required for CTEs and window functions)
- Emission values represent CO₂ emissions (kt CO₂)
- GDP values are expressed in USD (billions)
- Some insights are observational and not based on statistical regression

---

## Conclusion

Energy consumption and emissions are strongly linked to economic growth, industrialization, and population scale.

A small group of countries contributes a significant share of global emissions. Improving energy efficiency and accelerating renewable energy adoption remain critical for sustainable development.

---

## Author
Surya Teja  
SQL Data Analysis Project  
