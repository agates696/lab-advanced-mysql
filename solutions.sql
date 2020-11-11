USE publications;
SELECT * FROM authors;
SELECT * FROM sales;

-- Calculate the royalty of each sale for each author and the advance for each author and publication
SELECT * FROM titles;
SELECT * FROM titleauthor;

SELECT 
    t.title_id,
    au.au_id,
    ROUND((t.price * s.qty * t.royalty / 100) * ta.royaltyper / 100,
            2) AS royalty,
    ROUND((t.advance * ta.royaltyper) / 100, 2) AS advance
FROM
    titles AS t,
    titleauthor AS ta,
    authors AS au,
    sales AS s
WHERE
    t.title_id = ta.title_id
        AND ta.au_id = au.au_id
        AND t.title_id = s.title_id;
        
-- AGGREGATE TOTAL ROYALTIES
SELECT  title_id, au_id,SUM(royalty) as total_royalty, advance
FROM
(SELECT t.title_id, au.au_id, round((t.price * s.qty * t.royalty / 100) * ta.royaltyper/100, 2) as royalty, round((t.advance*ta.royaltyper)/100,2) as advance
FROM titles as t, titleauthor as ta, authors as au, sales as s
WHERE t.title_id = ta.title_id AND ta.au_id = au.au_id AND t.title_id = s.title_id) as sub1
GROUP BY title_id, au_id;

-- CALCULATE TOTAL PROFITS
SELECT au_id, title_id, SUM(royalty + advance) as total_profit
FROM
(SELECT t.title_id, au.au_id, round((t.price * s.qty * t.royalty / 100) * ta.royaltyper/100, 2) as royalty, round((t.advance*ta.royaltyper)/100,2) as advance
FROM titles as t, titleauthor as ta, authors as au, sales as s
WHERE t.title_id = ta.title_id AND ta.au_id = au.au_id AND t.title_id = s.title_id) as sub1
GROUP BY title_id, au_id;

-- CHALLENGE 2: Alternative solution
CREATE TEMPORARY TABLE temp_profits
SELECT t.title_id, au.au_id, round((t.price * s.qty * t.royalty / 100) * ta.royaltyper/100, 2) as royalty, round((t.advance*ta.royaltyper)/100,2) as advance
FROM titles as t, titleauthor as ta, authors as au, sales as s
WHERE t.title_id = ta.title_id AND ta.au_id = au.au_id AND t.title_id = s.title_id;

SELECT title_id, au_id, SUM(royalty) as total_royalty, advance
FROM temp_profits 
GROUP BY title_id, au_id;

SELECT au_id, title_id, SUM(royalty + advance) as total_profit
FROM temp_profits 
GROUP BY title_id, au_id
order by total_profit desc;

-- CHALLENGE 3 - PERMANENT TABLE
DROP TABLE if exists most_profiting_authors;
CREATE TABLE most_profiting_authors (
	SELECT au_id, SUM(royalty + advance) as total_profit
	FROM temp_profits 
	GROUP BY title_id, au_id
	order by total_profit desc
    limit 3
);

SELECT * FROM most_profiting_authors;

