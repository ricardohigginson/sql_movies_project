USE movies;

/* ============================================================
   Does a bigger budget produce more revenue?
   ============================================================ */
-- Overview of the number of movies, budget, revenue and ROI in our dataset 
SELECT
    COUNT(*) AS movies_count,
    AVG(budget) AS avg_budget,
    AVG(revenue) AS avg_revenue,
    MAX(budget) AS MAX_budget,
    MAX(revenue) AS MAX_revenue,
    MIN(budget) AS min_budget,
    MIN(revenue) AS min_revenue,
    AVG(revenue - budget) AS avg_profit,
    AVG((revenue - budget) / budget) AS avg_roi,
    MAX((revenue - budget) / budget) AS max_roi
FROM tmdb
LEFT JOIN ratings r on r.tconst = tmdb.imdb_id
WHERE budget > 1000
  AND revenue > 1000
  AND vote_count > 500
  and year(release_date) >= 2000
  AND r.numVotes > 0;
------------ 
-- Giving a look to one of the outliers
SELECT
*
FROM tmdb
WHERE tmdb.imdb_id = (SELECT tmdb.imdb_id from tmdb where revenue = 2068223624);
--------

SELECT
    CASE 
  WHEN budget <= 1000000 THEN 'Very Low'
  WHEN budget <= 25000000 THEN 'Low'
  WHEN budget <= 50000000 THEN 'Medium'
  WHEN budget <= 100000000 THEN 'High'
  ELSE 'Very High'
END AS budget_group,
    COUNT(*) AS movies,
    ROUND(AVG(budget), 2) AS avg_budget,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(revenue - budget), 2) AS avg_profit,
    ROUND(AVG((revenue - budget) / budget), 2) AS avg_roi
FROM tmdb
WHERE budget > 100000
  AND revenue > 0
  AND vote_count > 0
GROUP BY budget_group
ORDER BY avg_revenue DESC;

-- Looking at the metrics by budget grouping
SELECT
    CASE 
  WHEN budget <= 1000000 THEN 'Very Low'
  WHEN budget <= 25000000 THEN 'Low'
  WHEN budget <= 50000000 THEN 'Medium'
  WHEN budget <= 100000000 THEN 'High'
  ELSE 'Very High'
END AS budget_group,
    COUNT(*) AS movies,
    ROUND(AVG(budget), 2) AS avg_budget,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(revenue - budget), 2) AS avg_profit,
    ROUND(AVG((revenue - budget) / budget), 2) AS avg_roi
FROM tmdb
WHERE budget > 100000
  AND revenue > 0
  AND vote_count > 0
GROUP BY budget_group
ORDER BY avg_revenue DESC;


-- Zooming in to give a better look to the low-budget movies 
SELECT
   *,
   (revenue - budget) / budget as roi
FROM tmdb
WHERE budget > 100000
and budget <= 1000000  
  AND revenue > 1000
  AND vote_count > 500
  and year(release_date) >= 2000
  order by roi desc;
  
-- Checking the ROI by low budget movies to understand what kind of return we can get with the investment 

WITH LOW_BUDGET_MOVIES AS (
SELECT
   *,
   (revenue - budget) / budget as roi
FROM tmdb
WHERE budget > 100000
and budget <= 1000000  
  AND revenue > 1000
  AND vote_count > 500
  and year(release_date) >= 2000
  order by roi desc)
  
  SELECT 
  CASE 
  WHEN ROI < 0 THEN 'negative_roi'
  WHEN ROI < 5 THEN 'low_roi'
  WHEN ROI < 10 THEN 'medium_roi'
  WHEN ROI < 20 then 'high_roi'
  ELSE 'Extraordinary'
  END as ROI_GROUPING, 
  
  count(imdb_id) as number_of_movies,
  ROUND(
        COUNT(imdb_id) * 100.0 / SUM(COUNT(imdb_id)) OVER (),
        2
    ) AS share_pct
  FROM LOW_BUDGET_MOVIES
  GROUP BY 1
  ORDER BY 3 DESC;
  
-- Understanding the most profitable categories among the low budget movies

WITH LOW_BUDGET_MOVIES AS (
SELECT
   *,
   (revenue - budget) / budget as roi
FROM tmdb
WHERE budget > 100000
and budget <= 1000000  
  AND revenue > 1000
  AND vote_count > 500
  and year(release_date) >= 2000
  order by roi desc)
  
  
  SELECT 
	TRIM(SUBSTRING_INDEX(genres, ',', 1)) AS main_genre,
    COUNT(*) AS movies,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(revenue - budget), 2) AS avg_profit,
    ROUND(AVG((revenue - budget) / budget), 2) AS avg_roi
  FROM LOW_BUDGET_MOVIES
  GROUP BY 1
  ORDER BY 5 DESC;
  
-- Understanding the ratings values among the low-budget movies   

  WITH LOW_BUDGET_MOVIES AS (
SELECT
   *,
   (revenue - budget) / budget as roi
FROM tmdb
WHERE budget > 100000
and budget <= 1000000  
  AND revenue > 1000
  AND vote_count > 500
  and year(release_date) >= 2000
  order by roi desc)
  
  
  SELECT 
	CASE
    WHEN vote_average < 4 THEN 'Terrible'
    WHEN vote_average < 6  THEN 'Bad'
    WHEN vote_average < 7 THEN 'OK'
    WHEN vote_average < 8 THEN 'Good'
    ELSE 'Excellent'
	END AS rating_group,
    COUNT(*) AS movies,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(revenue - budget), 2) AS avg_profit,
    ROUND(AVG((revenue - budget) / budget), 2) AS avg_roi
  FROM LOW_BUDGET_MOVIES
  JOIN ratings on ratings.tconst = LOW_BUDGET_MOVIES.imdb_id 
  GROUP BY 1
  ORDER BY 5 DESC;

