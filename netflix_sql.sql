-- SCHEMAS of Netflix

create database netflix_db;

use netflix_db;

CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1;



-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        "type" AS show_type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY "type", rating
),
RankedRatings AS (
    SELECT 
        show_type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY show_type ORDER BY rating_count DESC) AS rating_rank
    FROM RatingCounts
)
SELECT 
    show_type AS type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rating_rank = 1;



-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020 ;



-- 4. Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;



-- 5. Identify the longest movie

SELECT 
    title,
    duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;



-- 6. Find content added in the last 5 years

SELECT 
    *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
  
  
  
  -- 9. Count the number of content items in each genre
  
SELECT listed_in, COUNT(*) AS total_content
FROM netflix
GROUP BY listed_in
ORDER BY total_content DESC;



-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100,
        2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;



-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';



-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;



-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 ;
    
    

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT casts, COUNT(*) AS total_movies
FROM netflix
WHERE country = 'India'
GROUP BY casts
ORDER BY total_movies DESC
LIMIT 10;



/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2 ;



