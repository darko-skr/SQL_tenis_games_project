
/*This query shows the number of players from each country (number_of_players) and generates a 
comma-separated list of all players from that country.*/
SELECT 
	 country_code	AS country_code
	,COUNT(*) 		AS number_of_players
	,STRING_AGG(
		' '|| first_name ||' '|| last_name,','
	) AS list_of_all_players
FROM players
GROUP BY country_code
ORDER BY number_of_players DESC

/*This query calculates total prize money in each tournament.*/

SELECT 
	 t.name  				AS tournament_name
	,SUM(pm.prize_amount)   AS total_prize_money
FROM prize_money pm
INNER JOIN tournaments t on t.tournament_id = pm.tournament_id
GROUP BY tournament_name
ORDER BY total_prize_money DESC

SELECT * FROM prize_money

/*This query identifies the top player with the most wins on each of the three surfaces: Clay, Grass, and Hard. 
It calculates the number of matches won by each player on each surface, 
ranks the players within each surface, and selects the player with the highest number of wins for each surface.*/

WITH rankedplayers AS (
    SELECT 
         p.player_id  AS player_id
        ,p.first_name AS first_name
        ,p.last_name  AS last_name
        ,t.surface    AS surface
        ,COUNT(m.match_id) AS wins_on_surface
        ,ROW_NUMBER() OVER (PARTITION BY t.surface ORDER BY COUNT(m.match_id) DESC) AS rank
    FROM matches m
    INNER JOIN tournament_editions te ON m.edition_id = te.edition_id
    INNER JOIN tournaments t ON te.tournament_id = t.tournament_id
    INNER JOIN players p ON m.winner_id = p.player_id
    GROUP BY 
         p.player_id
        ,p.first_name
        ,p.last_name
        ,t.surface
)
SELECT 
     player_id  	 AS player_id
    ,first_name 	 AS first_name
    ,last_name  	 AS last_name
    ,surface    	 AS surface
    ,wins_on_surface AS wins_on_surface
FROM rankedplayers
WHERE rank = 1
ORDER BY surface;


/*This query identifies the top 3 players who have won the most finals (round 7) in tennis matches.*/

SELECT 
     p.player_id  	   AS player_id
    ,p.first_name 	   AS first_name
    ,p.last_name  	   AS last_name
    ,COUNT(m.match_id) AS finals_won
FROM matches m
INNER JOIN players p ON m.winner_id = p.player_id
WHERE m.round_rank = 7
GROUP BY 
    p.player_id
   ,p.first_name
   ,p.last_name
ORDER BY finals_won DESC
FETCH FIRST 3 ROWS ONLY;



/*This analysis calculates the win percentage for each player by dividing the number of matches won 
by the total number of matches played. It provides a key performance indicator that highlights the effectiveness of players,
allowing for meaningful comparisons and insights into their performance over time.*/

WITH player_wins AS (
    SELECT 
         p.player_id 		AS player_id
        ,COUNT(m.winner_id) AS wins
    FROM players p
    INNER JOIN matches m ON p.player_id = m.winner_id
    GROUP BY 
        p.player_id
)
,number_of_games_by_player AS (
    SELECT 
         p.player_id 		AS player_id
        ,p.first_name 		AS first_name
        ,p.last_name 		AS last_name
        ,COUNT(pm.match_id) AS total_number_of_matches
    FROM players p
    INNER JOIN player_matches pm ON p.player_id = pm.player_id
    GROUP BY 
        p.player_id
       ,p.first_name
       ,p.last_name
)
SELECT 
     pw.player_id 				  AS player_id
    ,pw.wins 					  AS wins
    ,nog.total_number_of_matches  AS total_matches
    ,ROUND(100 * (pw.wins::NUMERIC / nog.total_number_of_matches::NUMERIC), 2) AS result_percentage
FROM player_wins pw 
JOIN number_of_games_by_player nog ON nog.player_id = pw.player_id
ORDER BY 
    player_id;

	
	/*This query analyzes how much each player has earned across tournaments 
	by calculating the total prize money based on the highest round they reached in each tournament. */
	WITH PlayerMaxRound AS (
    SELECT 
         p.player_id AS player_id
        ,p.first_name AS first_name
        ,p.last_name AS last_name
        ,te.tournament_id AS tournament_id
        ,MAX(m.round_rank) AS max_round_reached
    FROM matches m
    INNER JOIN tournament_editions te ON m.edition_id = te.edition_id
    INNER JOIN players p ON m.player1_id = p.player_id OR m.player2_id = p.player_id
    GROUP BY 
         p.player_id
        ,p.first_name
        ,p.last_name
        ,te.tournament_id
),
PlayerEarnings AS (
    SELECT 
         pmr.player_id 		  AS player_id
        ,pmr.first_name 	  AS first_name
        ,pmr.last_name 		  AS last_name
        ,SUM(pm.prize_amount) AS total_earnings
    FROM PlayerMaxRound pmr
    INNER JOIN prize_money pm ON pmr.tournament_id = pm.tournament_id AND pmr.max_round_reached = pm.round_rank
    GROUP BY 
         pmr.player_id
        ,pmr.first_name
        ,pmr.last_name
)
SELECT 
     pe.player_id 		AS player_id
    ,pe.first_name 		AS first_name
    ,pe.last_name 		AS last_name
    ,pe.total_earnings  AS total_earnings
FROM PlayerEarnings pe
ORDER BY total_earnings DESC;

/*This SQL query analyzes tennis players' yearly performance by calculating their annual match wins and total matches played. 
It joins data on players' wins and matches, grouped by year, to provide a comprehensive view of their performance trends.
By examining these trends, it can help predict a player's future performance trajectory*/
WITH player_wins AS (
    SELECT 
         p.player_id AS player_id
        ,p.first_name AS first_name
        ,p.last_name AS last_name
        ,te.year AS year
        ,COUNT(m.match_id) AS wins_per_year
    FROM matches m
    INNER JOIN tournament_editions te ON m.edition_id = te.edition_id
    INNER JOIN players p ON m.winner_id = p.player_id
    GROUP BY 
         p.player_id
        ,p.first_name
        ,p.last_name
        ,te.year
)
,player_total_matches AS (
    SELECT 
         p.player_id AS player_id
        ,p.first_name AS first_name
        ,p.last_name AS last_name
        ,EXTRACT(YEAR FROM m.match_date) AS year
        ,COUNT(m.match_id) AS total_matches_per_year
    FROM players p
    INNER JOIN player_matches pm ON p.player_id = pm.player_id
    INNER JOIN matches m ON pm.match_id = m.match_id
    GROUP BY 
         p.player_id
        ,p.first_name
        ,p.last_name
        ,EXTRACT(YEAR FROM m.match_date)
)
SELECT 
     pw.player_id AS player_id
    ,pw.first_name AS first_name
    ,pw.last_name AS last_name
    ,pw.year AS year
    ,pw.wins_per_year AS wins_per_year
    ,ptm.total_matches_per_year AS total_matches_per_year
FROM player_wins pw
INNER JOIN player_total_matches ptm ON pw.player_id = ptm.player_id AND pw.year = ptm.year
ORDER BY 
    pw.player_id, 
    pw.year;


/*This SQL script creates a view called player_wins, which stores aggregated data on the number of matches won by each player,
categorized by year and surface type.

Once the view is created, you can query it by specifying a particular year.*/
	
CREATE VIEW PlayerWins AS
SELECT 
     p.player_id AS player_id
    ,p.first_name AS first_name
    ,p.last_name AS last_name
    ,te.year AS year
    ,t.surface AS surface
    ,COUNT(m.match_id) AS wins_on_surface
FROM matches m
INNER JOIN tournament_editions te ON m.edition_id = te.edition_id
INNER JOIN tournaments t ON te.tournament_id = t.tournament_id
INNER JOIN players p ON m.winner_id = p.player_id
GROUP BY 
     p.player_id
    ,p.first_name
    ,p.last_name
    ,te.year
    ,t.surface;

	
SELECT *
FROM PlayerWins
WHERE year = 2022;