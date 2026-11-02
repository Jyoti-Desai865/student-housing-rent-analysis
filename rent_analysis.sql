
-- PROJECT: Pune Student Housing Rent Analysis
-- DATABASE: SQLite
-- TABLE: rent_clean

-- Q1. Average rent by locality
SELECT
    locality,
    COUNT(*) AS total_listings,
    ROUND(AVG(rent), 2) AS average_rent
FROM rent_clean
WHERE rent > 0
GROUP BY locality
HAVING COUNT(*) >= 30
ORDER BY average_rent DESC;


-- Q2. Average rent per square foot by locality
-- Using RANK() window function

WITH locality_rates AS (
    SELECT
        locality,
        COUNT(*) AS total_listings,
        ROUND(AVG(rent * 1.0 / NULLIF(area_sqft, 0)), 2)
            AS avg_rent_per_sqft
    FROM rent_clean
    WHERE rent > 0
      AND area_sqft >= 100
    GROUP BY locality
    HAVING COUNT(*) >= 30
)
SELECT
    locality,
    total_listings,
    avg_rent_per_sqft,
    RANK() OVER (
        ORDER BY avg_rent_per_sqft DESC
    ) AS locality_rank
FROM locality_rates
ORDER BY locality_rank;


-- Q3. Furnished vs unfurnished rent comparison

SELECT
    furnishing,
    COUNT(*) AS total_listings,
    ROUND(AVG(rent), 2) AS average_rent
FROM rent_clean
WHERE rent > 0
GROUP BY furnishing
ORDER BY average_rent DESC;


-- Q4. Top 5 cheapest localities for 1-bedroom properties

SELECT
    locality,
    COUNT(*) AS total_listings,
    ROUND(AVG(rent), 2) AS average_rent
FROM rent_clean
WHERE bedroom = 1
  AND rent > 0
GROUP BY locality
HAVING COUNT(*) >= 30
ORDER BY average_rent ASC
LIMIT 5;


-- Q5. Compare each locality's average rent
-- with the overall city average using AVG() OVER()

WITH rent_comparison AS (
    SELECT
        locality,
        rent,
        AVG(rent) OVER () AS city_average_rent
    FROM rent_clean
    WHERE rent > 0
)
SELECT
    locality,
    COUNT(*) AS total_listings,
    ROUND(AVG(rent), 2) AS locality_average_rent,
    ROUND(MAX(city_average_rent), 2) AS city_average_rent,
    ROUND(
        AVG(rent) - MAX(city_average_rent), 2
    ) AS rent_difference
FROM rent_comparison
GROUP BY locality
HAVING COUNT(*) >= 30
ORDER BY locality_average_rent DESC;


-- DATA QUALITY CHECKS

-- Check missing values
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN locality IS NULL OR TRIM(locality) = ''
        THEN 1 ELSE 0 END) AS missing_locality,
    SUM(CASE WHEN rent IS NULL THEN 1 ELSE 0 END)
        AS missing_rent,
    SUM(CASE WHEN area_sqft IS NULL THEN 1 ELSE 0 END)
        AS missing_area
FROM rent_clean;

-- Check duplicate records
SELECT
    locality,
    rent,
    bedroom,
    area_sqft,
    COUNT(*) AS duplicate_count
FROM rent_clean
GROUP BY locality, rent, bedroom, area_sqft
HAVING COUNT(*) > 1;
