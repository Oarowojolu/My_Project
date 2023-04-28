select *
from films 
INNER JOIN (select count(*), release_year as years_selected
from films 
GROUP BY release_year) AS t
ON films.release_year = t.years_selected
WHERE count > 200

Select *
from films 
where budget < 23000000
AND gross < 36833473
AND certification < 'Q'
AND language < 'E%'
AND duration > 104
AND country = 'USA'
AND release_year < 2005

Select *
from films 
INNER JOIN (select count(*), release_year as years_selected
from films 
GROUP BY release_year) AS t
ON films.release_year = t.years_selected
WHERE count < 100
AND budget < 23000000
AND gross > 36833473
AND certification < 'Q'
AND duration > 104
AND country = 'USA'
AND release_year < 2005

Select *
from films 
INNER JOIN (select count(*), release_year as years_selected
from films 
GROUP BY release_year) AS t
ON films.release_year = t.years_selected
WHERE count < 10000
OFFSET 2500

Select *
from films 
INNER JOIN (select count(*), budget as budget_selected
from films 
GROUP BY budget) AS t
ON films.budget = t.budget_selected
WHERE count < 10000
ORDER BY budget
OFFSET 2500

select count(*), certification
from films
group by certification 
ORDER BY count desc

RELEASE YEAR:

select title, release_year
from films
order by release_year
offset 2499;

SELECT count(*), certification
FROM films 
GROUP BY certification 
ORDER BY count DESC

SELECT SUBSTR(title, 1, 1) AS alpha, COUNT(*) AS title_count
FROM    films
GROUP   BY SUBSTR(title, 1, 1)
ORDER by title_count desc

SELECT *
FROM films 
INNER JOIN (select count(*), country 
from films 
GROUP BY country) AS c
ON films.country = c.country
WHERE count < 100
AND budget < 23000000
AND gross > 36833473
AND certification < 'Q'
AND duration > 104
AND films.country != 'USA'
-- THEN > 100 per country THEN Europe
AND release_year < 2005

SELECT * 
from films
where country ='USA'
and duration > 104
and title not like 'T%';

SELECT * 
from films
where country ='USA'
and duration > 104
and title not like 'T%'
AND release_year > 2005;

SELECT *
FROM films 
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification >'Q';

RESULT: 
 -- Showing 100 out of 232 rows

SELECT  SUBSTR(title, 1, 1) AS alpha, COUNT(*) AS title_count
FROM    films

where country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification >'Q'
AND budget < 23000000
GROUP   BY SUBSTR(title, 1, 1)
ORDER by title_count desc

SELECT *
FROM films 
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification >'Q'
AND budget < 23000000
AND title < 'C%';

SELECT *
FROM films 
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification >'Q'
AND budget < 23000000
AND title > 'J%'

SELECT *
FROM films
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification <='Q'
AND budget < 12500000

-- Is your first letter of title before 'J'?
-- Answer: Yes 
SELECT *
FROM films
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification <='Q'
AND budget < 12500000
AND title > 'J%'
ANSWER: 14

SELECT *
FROM films
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification <='Q'
AND budget < 12500000
AND title > 'J%'
AND release_year <= 2011;

SELECT *
FROM films
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification <='Q'
AND budget < 12500000
AND title > 'J%'
AND release_year <= 2011
AND title > 'O%'

SELECT *
FROM films
WHERE country = 'USA'
AND duration > 104
AND title NOT LIKE 'T%'
AND release_year > 2005
AND certification <='Q'
AND budget < 12500000
AND title > 'J%'
AND release_year <= 2011
AND title >= 'O%'
AND duration < 122
order by duration

-- Here are the codes used to check our results and which questions to ask: 

-- To see how many answers remain: 
SELECT count(*)
FROM films
WHERE country = 'USA'
AND duration > 104;
 
-- To see which number of answers we will need to use: 
SELECT count(*), release_year
FROM films
WHERE country = 'USA'
AND duration > 104
GROUP BY release_year
order by release_year

-- To see which number of answers we will need to use if there are only groups of 1 or 2 
SELECT count(*), gross
FROM films
WHERE country = 'USA'
AND duration > 104
GROUP BY gross
order by gross
OFFSET 700

-- To group the remaining answers by the first letter: 
SELECT SUBSTR(title, 1, 1) AS alpha, COUNT(*) AS title_count
FROM films
where country = 'USA'
AND duration > 104
GROUP BY SUBSTR(title, 1, 1)
ORDER by title_count desc
