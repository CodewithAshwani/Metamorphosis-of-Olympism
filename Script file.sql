1.	How many olympics games have been held?
Solution:

select count(distinct games) as total_olympic_games
    from athletes_history;

2.	List down all Olympics games held so far.
Solution:
select distinct oh.year,oh.season,oh.city
    from athletes_history oh
    order by year;

3.	Mention the total no of nations who participated in each olympics game?
Solution:
with all_countries as
        (select games, nr.region
        from athletes_history oh
        join noc_regions_history nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;

4.	Which year saw the highest and lowest no of countries participating in olympics?
solution:
with all_countries as
              (select games, nr.region
              from athletes_history oh
              join noc_regions_history nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;

5.	Which nation has participated in all of the olympic games?
Solution:
with tot_games as
              (select count(distinct games) as total_games
              from athletes_history),
          countries as
              (select games, nr.region as country
              from athletes_history oh
              join noc_regions_history nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;

6.	Identify the sport which was played in all summer olympics.
Solution:
WITH 
    t1 AS (
        SELECT COUNT(DISTINCT games)AS Total_summer_games
        FROM athletes_history
        WHERE season = 'Summer' 
       
    ),
    t2 AS (
        SELECT DISTINCT sport, games
        FROM athletes_history
        WHERE season = 'Summer' 
        ORDER BY games
    ),
    t3 AS (
        SELECT sport, COUNT(games) AS Number_of_Games
        FROM t2
        GROUP BY sport
    )
SELECT * FROM t3
join t1 on t1.Total_summer_games=t3.Number_of_Games;

7.	Which Sports were just played only once in the olympics?
8.	Fetch the total no of sports played in each olympic games.
9.	Fetch details of the oldest athletes to win a gold medal.
10.	Find the Ratio of male and female athletes participated in all olympic games.
11.	Fetch the top 5 athletes who have won the most gold medals.
Solution:
with t1 as 
	(SELECT name, COUNT(1) AS Total_Medals
	FROM athletes_history
	WHERE medal = 'Gold'
	GROUP BY name
	ORDER BY COUNT(1) DESC),
t2 as
(select  *, dense_rank() over(order by Total_medals desc)as rank
 from t1)
select * 
from t2
where rank<=5;


12.	Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
13.	Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
14.	List down total gold, silver and broze medals won by each country.
Solution:

SELECT nr.region AS country, 
       ah.medal, 
       COUNT(1) AS total_medals
FROM athletes_history AS ah
JOIN noc_regions_history AS nr ON nr.noc = ah.noc
WHERE ah.medal <> 'NA'
GROUP BY nr.region, ah.medal
order by nr.region, ah.medal;

--create extension tablefunc;(TO create the CROSSTAB function Command)

select country
, coalesce(gold ,0)as gold
, coalesce(silver ,0) as silver
, coalesce(bronze , 0) as bronze
from crosstab('SELECT nr.region AS country, 
						   ah.medal, 
						   COUNT(1) AS total_medals
					FROM athletes_history AS ah
					JOIN noc_regions_history AS nr ON nr.noc = ah.noc
					WHERE ah.medal <> ''NA''
					GROUP BY nr.region, ah.medal
					order by nr.region, ah.medal',
					'values(''Bronze''),(''Gold''),(''Silver'')')
				as result(country varchar , bronze bigint, gold bigint, silver bigint)
				order by gold desc, silver desc, bronze desc;

15.	List down total gold, silver and broze medals won by each country corresponding to each olympic games.
16.	Identify which country won the most gold, most silver and most bronze medals in each olympic games.

Solution:

select position('-' in '1896 Summer-Australia')
select substring('1896 Summer-Australia' , 15)


--"1896 Summer-Australia"

WITH temp AS (
    SELECT split_part(games_country, '-', 1) AS games,
           split_part(games_country, '-', 2) AS country,
           COALESCE(gold, 0) AS gold,
           COALESCE(silver, 0) AS silver,
           COALESCE(bronze, 0) AS bronze
    FROM crosstab(
        'SELECT concat(games, ''-'', nr.region) AS games_country, 
                medal, 
                COUNT(1) AS total_medals
         FROM athletes_history AS ah
         JOIN noc_regions_history AS nr ON nr.noc = ah.noc
         WHERE medal <> ''NA''
         GROUP BY games_country, medal
         ORDER BY games_country, medal',
        'VALUES (''Bronze''), (''Gold''), (''Silver'')'
    ) AS result(games_country VARCHAR, bronze BIGINT, gold BIGINT, silver BIGINT)
)
SELECT  distinct games 
,concat(first_value(Country) over (partition by games order by gold desc)
		,'-'
		,first_value(gold) over (partition by games order by gold desc)) as gold

,concat(first_value(Country) over (partition by games order by silver desc)
		,'-'
		,first_value(silver) over (partition by games order by silver desc)) as silver

,concat(first_value(Country) over (partition by games order by bronze desc)
		,'-'
		,first_value(bronze) over (partition by games order by bronze desc)) as bronze
FROM temp
order by games;



17.	Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
18.	Which countries have never won gold medal but have won silver/bronze medals?
19.	In which Sport/event, India has won highest medals.
20.	Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.