USE movies;

-- Hypothesis : Directors with a history of Oscar-recognized directing (nominations or wins) are more likely to direct financially successful movies.

-- Create a view with all the nominees and winners for the Directing category in the last 25 years
CREATE VIEW directing_nominees AS
SELECT
Year,
tmdb.title as Film,
Nominees,
Winner
FROM oscars
left join tmdb on tmdb.imdb_id = oscars.FilmId
WHERE Category = 'DIRECTING'
AND Year BETWEEN 2000 AND 2026;


-- Create a view by joining the nominees to the movie financials in the tmdb table
CREATE VIEW directing_financials AS
SELECT
directing_nominees.Nominees,
directing_nominees.Film,
directing_nominees.Winner,
tmdb.budget,
tmdb.revenue,
tmdb.release_date,
((tmdb.revenue - tmdb.budget) / tmdb.budget) * 100 AS roi_percentage
FROM directing_nominees
JOIN tmdb
ON directing_nominees.Film = tmdb.title
WHERE tmdb.budget > 10000 
AND YEAR(tmdb.release_date) BETWEEN 2000 AND 2026 
AND tmdb.revenue > 0;

-- Check: Count = 111
SELECT *
FROM directing_financials
ORDER BY budget DESC;

-- Which nominated directors have the highest average ROI?
SELECT
Nominees,
COUNT(*) AS movies,
ROUND(AVG(((revenue - budget) / budget) * 100), 2) AS avg_roi
FROM directing_financials
GROUP BY Nominees
ORDER BY avg_roi DESC;


-- Investigate movies with unusally high ROI
SELECT
Nominees,
Film,
budget,
revenue,
ROUND(((revenue - budget) / budget) * 100, 2) AS roi
FROM directing_financials
ORDER BY roi DESC;


-- Check which directors have more than 1 nomination/win: These are the top 10 to recommend.
SELECT
Nominees,
COUNT(*) AS movies,
ROUND(AVG(((revenue - budget) / budget) * 100), 2) AS avg_roi,
ROUND(AVG(budget),2) AS avg_budget
FROM directing_financials
GROUP BY Nominees
HAVING COUNT(*) >= 2
ORDER BY avg_roi DESC
LIMIT 10;

-- What is the average budget amount you need ff you want an Oscar-nominated director? $50m
SELECT 
AVG(avg_budget)
FROM
(SELECT
Nominees,
COUNT(*) AS movies,
ROUND(AVG(((revenue - budget) / budget) * 100), 2) AS avg_roi,
ROUND(AVG(budget),2) AS avg_budget
FROM directing_financials
GROUP BY Nominees
HAVING COUNT(*) >= 2
ORDER BY avg_roi DESC) AS main;

-- Which genres win Oscars? Drama, by far.
SELECT
    TRIM(SUBSTRING_INDEX(genres, ',', 1)) AS main_genre,
    COUNT(distinct o.FilmId) AS movies
FROM oscars o
JOIN tmdb t on t.imdb_id = o.FilmId
WHERE 
  revenue > 1000
  AND vote_count > 500
  AND year(release_date) >= 2000
  AND genres IS NOT NULL AND genres != ''
GROUP BY main_genre
ORDER BY 2 DESC;

-- What ratings are associated with Oscar nominated movies? 97% of Oscar nominated movies score 7 and Up on ratings
SELECT
r.averageRating,
o.film
FROM ratings AS r
JOIN oscars AS o
ON r.tconst = o.FilmId
WHERE Year BETWEEN 2000 AND 2026;


SELECT
CASE
    WHEN r.averageRating < 4 THEN 'Terrible'
    WHEN r.averageRating < 6  THEN 'Bad'
    WHEN r.averageRating < 7 THEN 'OK'
    WHEN r.averageRating < 8 THEN 'Good'
ELSE 'Excellent'
END AS rating_group,
COUNT(distinct o.FilmId) AS movies,
    ROUND(COUNT(distinct o.FilmId) * 100.0 / SUM(COUNT(distinct o.FilmId)) OVER (), 2) AS share_pct
FROM oscars AS o
JOIN ratings AS r
ON r.tconst = o.FilmId
WHERE CanonicalCategory = 'DIRECTING' AND Year BETWEEN 2000 AND 2026
GROUP BY rating_group;
