/*
Marvel Cinematic Universe Data Exploration
Skills used: Common Table Expressions (CTE), Window Functions, Partitions, Aggregate Functions, Subqueries, Joins, Operator, Data Cleaning
*/


/*		Movie Queries		*/

# MCU's revenue per year
	# SKILLS: Aggregate Function
SELECT
	EXTRACT(year FROM release_date) AS year,
    SUM(worldwide_box_office) AS annual_revenue,
    COUNT(*) AS num_movies
FROM box_office
GROUP BY year;

# Revenue by movie as a percentage of total franchise revenue
	# SKILLS: Aggregate Window Function
SELECT movie,
	ROUND(((worldwide_box_office/SUM(worldwide_box_office) OVER()) * 100), 2) AS percent_of_MCU_revenue
FROM box_office
ORDER BY percent_of_MCU_revenue desc;

# Domestic box office compared to total box office per movie
	# SKILLS: Operator
SELECT movie,
	ROUND((domestic_box_office/worldwide_box_office) * 100, 2) AS percent_domestic
FROM box_office
ORDER BY percent_domestic;

# Gross profit & margin per movie
	# SKILLS: CTE, Join, Operator
WITH gross AS (
	SELECT movie,
		release_date,
            	production_budget,
            	worldwide_box_office,worldwide_box_office - production_budget AS gross_profit
    	FROM box_office)
SELECT gross.*,
	ROUND((gross_profit/worldwide_box_office) * 100, 2) AS gross_margin
FROM gross;

# Highest-grossing MCU movie each year
	# SKILLS: CTE, Aggregate Function, Join
WITH most_successful_movie AS (
	SELECT EXTRACT(year FROM release_date) AS year,
		MAX(worldwide_box_office) AS revenue
	FROM box_office
    	GROUP BY year)
SELECT most_successful_movie.*, box_office.movie
FROM most_successful_movie
JOIN box_office ON most_successful_movie.revenue = box_office.worldwide_box_office;

# Highest-rated MCU movie each year
	# SKILLS: CTE, Ranking Window Function, Partition
WITH rankings AS (
	SELECT EXTRACT(year FROM release_date) AS year,
		movie,
		rating,
		RANK() OVER(PARTITION BY EXTRACT(year FROM release_date) ORDER BY rating desc) AS ranking
	FROM box_office
	JOIN movie_ratings USING (movie))
SELECT year, movie, rating
FROM rankings
WHERE ranking = 1
ORDER BY year desc;


/*		Actor Queries		*/

# Comparing each actor's MCU box office to career box office (MCU/career)
	# SKILLS: Operator 
SELECT actor,
	role,
	number_of_movies,
        mcu_worldwide_box_office,
        career_worldwide_box_office,
        ROUND((mcu_worldwide_box_office/career_worldwide_box_office) * 100, 2) AS mcu_vs_career_boxoffice
FROM actors
ORDER BY number_of_movies desc;

# Comparing number of leading roles to number of MCU appearances for each actor appearing in > 1 movie
	# SKILLS: CTE, Aggregate Function, Join
WITH leading_roles AS (
	SELECT actor,
		COUNT(*) AS number_leading_roles
    	FROM leading_cast
    	GROUP BY actor)
SELECT leading_roles.*, 
	number_of_movies
FROM leading_roles
JOIN actors USING (actor)
ORDER BY number_leading_roles desc;

# Highest-grossing actors, only including movies in which actor had a leading role
	# SKILLS: CTE, Aggregate Function, Join
WITH leading_roles AS (
	SELECT actor,
		COUNT(*) AS count
    	FROM leading_cast
    	GROUP BY actor)
SELECT lc.actor,
	SUM(worldwide_box_office) AS worldwide_revenue,
        lr.count AS num_movies
FROM box_office bo
JOIN leading_cast lc ON bo.movie = lc.movie
JOIN leading_roles lr ON lc.actor = lr.actor
GROUP BY lc.actor, lr.count
ORDER BY worldwide_revenue desc;
