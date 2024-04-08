1.	How many olympics games have been held?
Solution:

select count(distinct games) as total_olympic_games
    from athletes_history;

2.	List down all Olympics games held so far.
3.	Mention the total no of nations who participated in each olympics game?
4.	Which year saw the highest and lowest no of countries participating in olympics?
5.	Which nation has participated in all of the olympic games?
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
GROUP BY nr.region, ah.medal;


15.	List down total gold, silver and broze medals won by each country corresponding to each olympic games.
16.	Identify which country won the most gold, most silver and most bronze medals in each olympic games.
17.	Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
18.	Which countries have never won gold medal but have won silver/bronze medals?
19.	In which Sport/event, India has won highest medals.
20.	Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.