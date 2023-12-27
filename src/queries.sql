-- 1. Find the top hosts based on the total number of listings they have.
SELECT h.id, h.name, h.host_total_listings_count
FROM host h
ORDER BY h.host_total_listings_count DESC
LIMIT 10;

-- 2. Number of reviews for each combination of 'property_id', 'host_id' and 'reviewer_id'.
SELECT
    property_id,
    host_id,
    reviewer_id,
    COUNT(*) AS review_count
FROM
    review
GROUP BY
    property_id, host_id, reviewer_id WITH ROLLUP;

-- 3. Listings with the Most Reviews in Each Neighbourhood
WITH RankedListings AS (
    SELECT
        listing_id,
        l.location_id as location_id,
        row_number() over (partition by l.location_id order by count(*) desc) as _rank
    FROM
        review r
        JOIN listing l ON r.listing_id = l.id
    GROUP BY
        l.location_id, listing_id
)
SELECT
    listing_id,
    location_id,
    _rank
FROM
    RankedListings
WHERE
    _rank = 1;

-- 4. Ranking Listings by Review Scores Within Each Neighbourhood
WITH RankedListings AS (
    SELECT
        l.id AS listing_id,
        l.review_scores_rating,
        n.neighbourhood,
        RANK() OVER (PARTITION BY n.id ORDER BY l.review_scores_rating DESC) AS ranking
    FROM
        listing l
    JOIN
        location loc ON l.location_id = loc.id
    JOIN
        neighbourhood n ON loc.neighbourhood_id = n.id
)

SELECT
    listing_id,
    review_scores_rating,
    neighbourhood,
    ranking
FROM
    RankedListings
ORDER BY
    neighbourhood, ranking;

-- 5. Identifying Listings with Prices Above the Neighbourhood Average
SELECT
    l.id,
    price,
    nbls.price_average  AS avg_neighbourhood_price,
    CASE
        WHEN price > nbls.price_average THEN 'Above Average'
        ELSE 'Below or Equal to Average'
    END AS price_category
FROM
    listing l
    JOIN location loc ON l.location_id = loc.id
    JOIN neighbourhood_based_listing_statistics nbls ON nbls.neighbourhood_id = loc.neighbourhood_id 
ORDER BY
    loc.neighbourhood_id, l.id;

-- 6. Analyze host response rates and their impact on listing popularity.
SELECT
    h.id,
    h.name,
    h.host_response_rate,
    COUNT(*) AS listing_count
FROM
    host h
JOIN
    listing l ON h.id = l.host_id
GROUP BY
    h.id
ORDER BY
    listing_count DESC;

-- 7. Analyze monthly review trends for each city, with subtotals for each year, city, state and a grand total.
SELECT
    co.country,
    s.state,
    c.city,
    d.year_number,
    d.month_name,
    COUNT(*) AS review_count
FROM
    review r
JOIN
    date d ON r.date_id = d.id
JOIN
    listing l ON r.listing_id = l.id
JOIN
    location loc ON l.location_id = loc.id
JOIN
    neighbourhood n ON loc.neighbourhood_id = n.id
JOIN
    city c ON n.city_id = c.id
JOIN
    state s ON c.state_id = s.id
JOIN
    country co ON s.country_id = co.id
GROUP BY
    co.country, s.state, c.city, d.year_number, d.month_name WITH ROLLUP;

-- 8. Explore the geographical distribution of listings across cities and countries.
SELECT co.country, c.city, COUNT(*) AS listing_count
FROM country co
JOIN state s ON co.id = s.country_id
JOIN city c ON s.id = c.state_id
JOIN neighbourhood n ON c.id = n.city_id
JOIN location l ON n.id = l.neighbourhood_id
JOIN listing li ON l.id = li.location_id
GROUP BY co.country, c.city
ORDER BY listing_count DESC;

-- 9. Query to identify the top individual amenities, considering each amenity as a separate entity in the list.
SELECT
    REPLACE(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(amenities, ',', n.n), ',', -1)), "[", ""), "]", "") AS amenity,
    COUNT(*) AS listing_count
FROM
    property,
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
WHERE
    LENGTH(amenities) - LENGTH(REPLACE(amenities, ',', '')) >= n.n - 1
GROUP BY
    amenity
ORDER BY
    listing_count DESC
LIMIT 10;

-- 10. Query to calculate the average accommodates for listings based on combinations of amenities.
SELECT
    amenity_combination,
    AVG(accommodates) AS avg_accommodates
FROM (
    SELECT
        GROUP_CONCAT(DISTINCT REPLACE(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(amenities, ',', n.n), ',', -1)), "[", ""), "]", "") ORDER BY REPLACE(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(amenities, ',', n.n), ',', -1)), "[", ""), "]", "")) AS amenity_combination,
        accommodates
    FROM
        property,
        (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
    WHERE
        LENGTH(amenities) - LENGTH(REPLACE(amenities, ',', '')) >= n.n - 1
    GROUP BY
        accommodates
) AS amenity_combination_subquery
GROUP BY
    amenity_combination
ORDER BY
    avg_accommodates DESC
LIMIT 10;

-- 11. Query to identify hosts whose listings consistently receive high review scores.
SELECT
    h.id AS host_id,
    h.name AS host_name,
    AVG(l.review_scores_rating) AS avg_review_score
FROM
    host h
JOIN
    listing l ON h.id = l.host_id
LEFT JOIN
    review r ON l.id = r.listing_id
GROUP BY
    h.id, h.name
HAVING
    COUNT(*) >= 100 AND MIN(l.review_scores_rating) >= 4.75
ORDER BY
    avg_review_score DESC;