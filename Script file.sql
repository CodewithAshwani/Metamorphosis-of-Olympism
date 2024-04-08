1.	How many olympics games have been held?
Solution:

select count(distinct games) as total_olympic_games
    from athletes_history;
--------------------------------------------------------------------------------------------------------------------------------------------------
2.	List down all Olympics games held so far.
Solution:
select distinct oh.year,oh.season,oh.city
    from athletes_history oh
    order by year;
--------------------------------------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------------------------------------

7.	Which Sports were just played only once in the olympics?
Solution:
with t1 as
          	(select distinct games, sport
          	from athletes_history),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;
--------------------------------------------------------------------------------------------------------------------------------------------------

8.	Fetch the total no of sports played in each olympic games.

Solution:
with t1 as
      	(select distinct games, sport
      	from athletes_history),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;
--------------------------------------------------------------------------------------------------------------------------------------------------

9.	Fetch details of the oldest athletes to win a gold medal.

Solution:
 with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
              ,team,games,city,sport, event, medal
            from athletes_history),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;
--------------------------------------------------------------------------------------------------------------------------------------------------

10.	Find the Ratio of male and female athletes participated in all olympic games.

Solution:
with t1 as
        	(select sex, count(1) as cnt
        	from athletes_history
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;
--------------------------------------------------------------------------------------------------------------------------------------------------

11.	Fetch the top 5 athletes who have won the most gold medals.

Solution:
WITH T1 AS
	(SELECT NAME,
			COUNT(1) AS TOTAL_MEDALS
		FROM ATHLETES_HISTORY
		WHERE MEDAL = 'Gold'
		GROUP BY NAME
		ORDER BY COUNT(1) DESC),
	T2 AS
	(SELECT *,
			DENSE_RANK() OVER(
			ORDER BY TOTAL_MEDALS DESC)AS RANK
		FROM T1)
SELECT *
FROM T2
WHERE RANK <= 5;

--------------------------------------------------------------------------------------------------------------------------------------------------

12.	Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

Solution:
with t1 as
            (select name, team, count(1) as total_medals
            from athletes_history
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select name, team, total_medals
    from t2
    where rnk <= 5;
--------------------------------------------------------------------------------------------------------------------------------------------------

13.	Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

solution:
with t1 as
            (select nr.region, count(1) as total_medals
            from athletes_history oh
            join noc_regions_history nr on nr.noc = oh.noc
            where medal <> 'NA'
            group by nr.region
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over(order by total_medals desc) as rnk
            from t1)
    select *
    from t2
    where rnk <= 5;
	
--------------------------------------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------------------------------------


15.	List down total gold, silver and broze medals won by each country corresponding to each olympic games.
Solution:
 SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                , medal
                , count(1) as total_medals
                FROM athletes_history oh
                JOIN noc_regions_history nr ON nr.noc = oh.noc
                where medal <> ''NA''
                GROUP BY games,nr.region,medal
                order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);
--------------------------------------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------------------------------------

17.	Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
Solution:
with temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    		, substring(games, position(' - ' in games) + 3) as country
    		, coalesce(gold, 0) as gold
    		, coalesce(silver, 0) as silver
    		, coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
    					, medal
    					, count(1) as total_medals
    				  FROM athletes_history oh
    				  JOIN noc_regions_history nr ON nr.noc = oh.noc
    				  where medal <> ''NA''
    				  GROUP BY games,nr.region,medal
    				  order BY games,medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
    			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)),
    	tot_medals as
    		(SELECT games, nr.region as country, count(1) as total_medals
    		FROM athletes_history oh
    		JOIN noc_regions_history nr ON nr.noc = oh.noc
    		where medal <> 'NA'
    		GROUP BY games,nr.region order BY 1, 2)
    select distinct t.games
    	, concat(first_value(t.country) over(partition by t.games order by gold desc)
    			, ' - '
    			, first_value(t.gold) over(partition by t.games order by gold desc)) as Max_Gold
    	, concat(first_value(t.country) over(partition by t.games order by silver desc)
    			, ' - '
    			, first_value(t.silver) over(partition by t.games order by silver desc)) as Max_Silver
    	, concat(first_value(t.country) over(partition by t.games order by bronze desc)
    			, ' - '
    			, first_value(t.bronze) over(partition by t.games order by bronze desc)) as Max_Bronze
    	, concat(first_value(tm.country) over (partition by tm.games order by total_medals desc nulls last)
    			, ' - '
    			, first_value(tm.total_medals) over(partition by tm.games order by total_medals desc nulls last)) as Max_Medals
    from temp t
    join tot_medals tm on tm.games = t.games and tm.country = t.country
    order by games;
--------------------------------------------------------------------------------------------------------------------------------------------------

18.	Which countries have never won gold medal but have won silver/bronze medals?
Solution:
select * from (
    	SELECT country, coalesce(gold,0) as gold, coalesce(silver,0) as silver, coalesce(bronze,0) as bronze
    		FROM CROSSTAB('SELECT nr.region as country
    					, medal, count(1) as total_medals
    					FROM athletes_history oh
    					JOIN NOC_REGIONS_HISTORY nr ON nr.noc=oh.noc
    					where medal <> ''NA''
    					GROUP BY nr.region,medal order BY nr.region,medal',
                    'values (''Bronze''), (''Gold''), (''Silver'')')
    		AS FINAL_RESULT(country varchar,
    		bronze bigint, gold bigint, silver bigint)) x
    where gold = 0 and (silver > 0 or bronze > 0)
    order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;
--------------------------------------------------------------------------------------------------------------------------------------------------

19.	In which Sport/event, India has won highest medals.
Solution:
with t1 as
        	(select sport, count(1) as total_medals
        	from athletes_history
        	where medal <> 'NA'
        	and team = 'India'
        	group by sport
        	order by total_medals desc),
        t2 as
        	(select *, rank() over(order by total_medals desc) as rnk
        	from t1)
    select sport, total_medals
    from t2
    where rnk = 1;
--------------------------------------------------------------------------------------------------------------------------------------------------

20.	Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
Solution:
select team, sport, games, count(1) as total_medals
    from athletes_history
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;

--------------------------------------------------------------------------------------------------------------------------------------------------
