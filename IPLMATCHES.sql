-- Created table:1 name 'matches'

CREATE TABLE matches (
    match_id BIGINT,
    season INT,
    city VARCHAR(20),
    match_date DATE,
    team1 VARCHAR(30),
    team2 VARCHAR(30),
    toss_winner VARCHAR(30),
    toss_decision VARCHAR(10),
    match_result VARCHAR(10),
    dl_applied INT,
    winner VARCHAR(30),
    win_by_runs INT,
    win_by_wickets INT,
    player_of_match VARCHAR(25),
    venue VARCHAR(60),
    umpire1 VARCHAR(25),
    umpire2 VARCHAR(25)
);

-- Added a new column on existing table
ALTER TABLE matches
ADD COLUMN umpire3 VARCHAR(25);

SELECT * FROM matches

-- Created an another table name 'deliveries'
CREATE TABLE deliveries(
match_id BIGINT,
	inning INT,
	batting_team VARCHAR (30),
	bowling_team VARCHAR (30),
	match_over INT,
	ball INT,
	batsman VARCHAR (25),
	non_striker VARCHAR (25),
	bowler VARCHAR (25),
	is_super_over SMALLINT,
	wide_runs SMALLINT,
	bye_runs SMALLINT,
	legbye_runs SMALLINT,
	noball_runs SMALLINT,
	penalty_runs SMALLINT,
	batsman_runs SMALLINT,
	extra_runs SMALLINT,
	total_runs SMALLINT,
	player_dismissed VARCHAR (25),
	dismissal_kind VARCHAR (25),
	fielder VARCHAR (25)
);

SELECT * FROM deliveries;


---Questions---

--1. Top 3 most player of match on 2017?
SELECT season, player_of_match FROM matches
WHERE season = '2017'
GROUP BY 1,2
ORDER BY 2 DESC
LIMIT 3

-- This shows Yuvraj Singh Played Most Player Of The Match On 2017.

--2. 7 Most Played venue in the History of IPL from 2008 to 2017
SELECT venue, 
COUNT(*) AS match_count FROM matches
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 7

-- This shows 'M Chinnaswamy Stadium' host most games as count of 66.


--3. Most Player of the Matches across 9 Seasons
SELECT player_of_match, 
COUNT (*) AS count_player_of_match FROM matches
GROUP BY 1
ORDER BY 2 DESC

-- 'CH Gayle' has won most player of the match, which is 66 for 9 seasons.

--4. Matches Played across each season.
SELECT season, 
COUNT (match_id) AS count_match FROM matches
GROUP BY 1
ORDER BY 2 DESC

-- The report shows that 2013 has played most matches.

--5. Most Favourite Umpires

SELECT umpire, 
COUNT(*) AS match_count
FROM 
(SELECT umpire1 AS umpire FROM matches
UNION ALL
SELECT umpire2 AS umpire FROM matches)
AS all_umpires
GROUP BY 1
ORDER BY 2 DESC

-- This shows 'HDPK Dharmasena' is most favourite umpire.

--FACTS OF IPL

--6. How many matches got tied between 2008 to 2017?
SELECT
COUNT (match_id) 
FROM matches AS count_result
WHERE match_result ILIKE 'tie'

-- Total 7 matches are tied between 2008 to 2017.

--7. How many matches result were decided on 'Duckworth Lewis Method' between 2008 to 2017? And which year has highest decission taken for match result under 'Duckwort Lewis Method'?
SELECT season,
COUNT (match_id) AS total_dl
FROM matches
WHERE dl_applied = '1'
GROUP BY 1
ORDER BY 2 DESC

-- Total 16 match result were decided by the 'Duckworth Lewis Method' betwee 2008 to 2017. And on 2016 there are highest matches were decided under 'Duckworth Lewis Method'.

--8. Which match is the biggest win on between 2008 to 2017 on the basis of run margin? Which team won the match with how many runs margin? And who is the looser team? What is the name of the venue?
SELECT season, team1, team2, winner, venue,
MAX(win_by_runs) AS win_by_runs
FROM matches
WHERE win_by_runs IS NOT NULL
GROUP BY 1, 2, 3, 4, 5
ORDER BY 6 DESC

-- Between the match of 'Mumbai Indians VS Delhi Daredevils', 'Mumbai Indians' won the match with the margin of 146 runs. And the venue was 'Feroz Shah Kotla'. This match was helds on season '2017'.

--9. Which venues were decided the most match result under 'Duckworth Lewis Method'?
SELECT venue,
COUNT (match_id) AS total_match
FROM matches
WHERE dl_applied = '1'
GROUP BY 1
ORDER BY 2 DESC

-- 'M Chinnaswamy Stadium' and 'Eden Garden' has most match result under 'Duckworth Lewis Method' which were 3 and 3 each matches.

--10. Stadium wise analysis for most played matches.

SELECT venue,
SUM(CASE 
WHEN toss_decision = 'bat' AND winner = team1 THEN 1
WHEN toss_decision = 'field' AND winner = team2 THEN 1
ELSE 0
END) AS wins_batting_first,

SUM(CASE
WHEN toss_decision = 'bat' AND winner = team2 THEN 1
WHEN toss_decision = 'field' AND winner = team1 THEN 1
ELSE 0
END) AS wins_batting_second,
COUNT(match_id) AS total_matches,

ROUND(SUM(CASE 
WHEN toss_decision = 'bat' AND winner = team1 THEN 1
WHEN toss_decision = 'field' AND winner = team2 THEN 1
ELSE 0
END) * 100 / COUNT (match_id), 2) AS avg_wins_batting_first,

ROUND(SUM(CASE
WHEN toss_decision = 'bat' AND winner = team2 THEN 1
WHEN toss_decision = 'field' AND winner = team1 THEN 1
ELSE 0
END) * 100 / COUNT (match_id), 2) AS avg_wins_batting_second

FROM matches
GROUP BY venue
ORDER BY total_matches DESC;

--11. Is Toss Winner Also the Match Winner for the year of 2017?
SELECT COUNT(*) AS match_winner,
COUNT(CASE WHEN toss_winner = winner THEN 1 END) AS toss_match_winner
FROM matches
WHERE season = 2017;

--Yes 2017 is the toss winner is the match winner which is 34 matches winning out of 59 matches.

--12. What is the trends on 2015 after winning the toss?
SELECT season, toss_decision,
ROUND (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matches WHERE season = 2017), 2) AS toss_trends
FROM matches
--WHERE season = 2016
GROUP BY season, toss_decision
ORDER BY season DESC;

-- As per the data after toss 57.63% has more fielding and 42.37% batting taken.

--13. Total runs scored by each teams in all the season
SELECT batting_team,
SUM(total_runs) AS total_runs
FROM deliveries
GROUP BY batting_team
ORDER BY total_runs DESC;

--14. Total Runs scored by each team in a particular season

SELECT m.season, d.batting_team, SUM(d.total_runs) AS total_runs
FROM deliveries d
JOIN matches m ON d.match_id = m.match_id
GROUP BY m.season, d.batting_team
ORDER BY m.season, total_runs DESC;

--15. Top 5 players with the most runs

SELECT m.season, d.batsman,
SUM (total_runs) AS total_runs
FROM deliveries d
JOIN matches m ON d.match_id = m.match_id
GROUP BY m.season, d.batsman
ORDER BY m.season, total_runs DESC
LIMIT 5;

--16. Find the team win percentage

-- Total matches played by team
WITH matches_played AS(
	SELECT team, COUNT(match_id) AS matches_played
	FROM(
	SELECT team1 AS team, match_id
	--COUNT(match_id) AS matches_played
	FROM matches
	--GROUP BY team
UNION ALL
	SELECT team2 AS team, match_id
	--COUNT(match_id) AS matches_played
	FROM matches
	--GROUP BY team
) AS combined_teams
	GROUP BY team
),

-- Number of matches won by team

matches_won AS(
SELECT winner,
	COUNT (match_id) AS matches_won
	FROM matches
	GROUP BY winner
)

-- Win percentage calculation

SELECT mp.team, mp.matches_played, 
COALESCE (mw.matches_won, 0) AS matches_won,
	ROUND((mw.matches_won * 1.0 /mp.matches_played) * 100, 2) AS win_percentage
FROM matches_played mp
LEFT JOIN matches_won mw ON mp.team = mw.winner
ORDER BY win_percentage DESC;

--17. Teams that have higher win percentage after winning the toss might have tactical advantage (Impact of toss on Winning)
SELECT toss_winner AS team, COUNT(*) AS toss_wins,
       SUM(CASE WHEN winner = toss_winner THEN 1 ELSE 0 END) AS matches_won_after_toss,
       ROUND((SUM(CASE WHEN winner = toss_winner THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS toss_win_percentage
FROM matches
GROUP BY toss_winner
ORDER BY toss_win_percentage DESC;

