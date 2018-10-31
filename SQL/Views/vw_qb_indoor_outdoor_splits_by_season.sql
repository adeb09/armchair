DROP VIEW IF EXISTS vw_qb_indoor_outdoor_splits_by_season
;

CREATE VIEW vw_qb_indoor_outdoor_splits_by_season AS
WITH qbs AS (
     SELECT player
            , fname
            , lname
       FROM player
      WHERE pos1 = 'QB'
         OR pos2 = 'QB'
)

, sub1 AS (
  SELECT c.seas AS season
         , a.player AS player_id
         , b.fname AS first_name
         , b.lname AS last_name
         , CASE 
           WHEN c.cond IN ('Dome', 'Closed Roof', 'Covered Roof') THEN TRUE
           ELSE FALSE
           END AS is_indoor
         , COUNT(1) AS num_games
         , SUM(a.pc) * 1.0 / SUM(a.pa) * 100 AS completion_pct
         , SUM(a.py) * 1.0 / SUM(a.pa) AS pass_yards_per_attempt
         , SUM(a.tdp) * 1.0 / SUM(a.pa) * 100 AS touchdown_pct
         , SUM(a.ints) * 1.0 / SUM(a.pa) * 100 AS interception_pct
         , SUM(a.ry) * 1.0 / SUM(a.ra) AS rush_yards_per_attempt
         , SUM(a.pa) AS pass_attempts
         , SUM(a.pc) AS pass_completions
         , SUM(a.py) AS pass_yards
         , SUM(a.ints) AS interceptions
         , SUM(a.tdp) AS pass_tds
         , SUM(a.ra) AS rush_attempts
         , SUM(a.sra) AS successful_rush_attempts
         , SUM(a.ry) AS rush_yards
         , SUM(a.tdr) AS rush_tds
         , SUM(a.fuml) AS fumbles_lost
         , SUM(a.peny) AS penalty_yardage
         , SUM(a.conv) AS conversions
         , AVG(a.fp + a.fp2 + a.fp3 * 1.0 / 3) AS avg_fantasy_points_per_game
         , (SUM(a.fp) + SUM(a.fp2) + SUM(a.fp3)) * 1.0 / 3 AS avg_fantasy_points_total
         , AVG(a.pa) AS pass_attempts_per_game
         , AVG(a.pc) AS pass_completions_per_game
         , AVG(a.py) AS pass_yards_per_game
         , AVG(a.ints) AS interceptions_per_game
         , AVG(a.tdp) AS pass_tds_per_game
         , AVG(a.ra) AS rush_attempts_per_game
         , AVG(a.sra) AS successful_rush_attempts_per_game
         , AVG(a.ry) AS rush_yards_per_game
         , AVG(a.tdr) AS rush_tds_per_game
         , AVG(a.fuml) AS fumbles_lost_per_game
         , AVG(a.peny) AS penalty_yards_per_game
         , AVG(a.conv) AS conversions_per_game
         , 5 * (SUM(a.pc) * 1.0 / SUM(a.pa) - 0.3) AS a
         , 0.25 * (SUM(a.py) * 1.0 / SUM(a.pa) - 3) AS b
         , SUM(a.tdp) * 1.0 / SUM(a.pa) * 20 AS c
         , 2.375 - 25 * SUM(a.ints) * 1.0 / SUM(a.pa) AS d
    FROM offense AS a
         INNER JOIN qbs AS b
         ON a.player = b.player
       
         LEFT JOIN game AS c
         ON a.gid = c.gid
   GROUP BY 1, 2, 3, 4, 5
   ORDER BY 1, 2
)

, sub2 AS (
  SELECT *
         , (a + b + c + d) * 1.0 / 6 * 100 AS passer_rating
    FROM sub1
)

, indoor AS (
  SELECT *
    FROM sub2
   WHERE is_indoor IS TRUE
)

, outdoor AS (
  SELECT *
    FROM sub2
   WHERE is_indoor IS FALSE
)

SELECT a.season
       , a.first_name
       , a.last_name
       , a.player_id
       , a.num_games AS outdoor_games_played
       , b.num_games AS indoor_games_played
       , a.num_games * 1.0 / (a.num_games + b.num_games) * 100 AS pct_games_played_outdoor
       , b.num_games * 1.0 / (a.num_games + b.num_games) * 100 AS pct_games_played_indoor
       , a.passer_rating AS outdoor_passer_rating
       , b.passer_rating AS indoor_passer_rating
       , a.passer_rating - b.passer_rating AS passer_rating_diff
       , a.completion_pct AS outdoor_completion_pct
       , b.completion_pct AS indoor_completion_pct
       , a.completion_pct - b.completion_pct AS completion_pct_diff
       , a.pass_yards_per_attempt AS outdoor_pass_yards_per_attempt
       , b.pass_yards_per_attempt AS indoor_pass_yards_per_attempt
       , a.pass_yards_per_attempt - b.pass_yards_per_attempt AS pass_yards_per_attempt_diff
       , a.touchdown_pct AS outdoor_touchdown_pct
       , b.touchdown_pct AS indoor_touchdown_pct
       , a.touchdown_pct - b.touchdown_pct AS touchdown_pct_diff
       , a.interception_pct AS outdoor_interception_pct
       , b.interception_pct AS indoor_interception_pct
       , a.interception_pct - b.interception_pct AS interception_pct_diff
       , a.avg_fantasy_points_per_game AS outdoor_avg_fantasy_points_per_game
       , b.avg_fantasy_points_per_game AS indoor_avg_fantasy_points_per_game
       , a.avg_fantasy_points_per_game - b.avg_fantasy_points_per_game AS avg_fantasy_points_per_game_diff
       , a.avg_fantasy_points_total AS outdoor_avg_fantasy_points_total
       , b.avg_fantasy_points_total AS indoor_avg_fantasy_points_total
       , a.conversions_per_game AS outdoor_conversions_per_game
       , b.conversions_per_game AS indoor_conversions_per_game
       , a.rush_yards_per_attempt AS outdoor_rush_yards_per_attempt
       , b.rush_yards_per_attempt AS indoor_rush_yards_per_attempt
       , a.rush_yards_per_attempt - b.rush_yards_per_attempt AS rush_yards_per_attempt_diff
       , a.pass_attempts_per_game AS outdoor_pass_attempts_per_game
       , b.pass_attempts_per_game AS indoor_pass_attempts_per_game
       , a.pass_completions_per_game AS outdoor_pass_completions_per_game
       , b.pass_completions_per_game AS indoor_pass_completions_per_game
       , a.pass_yards_per_game AS outdoor_pass_yards_per_game
       , b.pass_yards_per_game AS indoor_pass_yards_per_game
       , a.pass_tds_per_game AS outdoor_pass_tds_per_game
       , b.pass_tds_per_game AS indoor_pass_tds_per_game
       , a.interceptions_per_game AS outdoor_interceptions_per_game
       , b.interceptions_per_game AS indoor_interceptions_per_game
       , a.rush_attempts_per_game AS outdoor_rush_attempts_per_game
       , b.rush_attempts_per_game AS indoor_rush_yards_per_attempt
       , a.successful_rush_attempts_per_game AS outdoor_successful_rush_attempts_per_game
       , b.successful_rush_attempts_per_game AS indoor_successful_rush_attempts_per_game
       , a.rush_yards_per_game AS outdoor_rush_yards_per_game
       , b.rush_yards_per_game AS indoor_rush_yards_per_game
       , a.rush_tds_per_game AS outdoor_rush_tds_per_game
       , b.rush_tds_per_game AS indoor_rush_tds_per_game
       , a.fumbles_lost_per_game AS outdoor_fumbles_lost_per_game
       , b.fumbles_lost_per_game AS indoor_fumbles_lost_per_game
       , a.penalty_yards_per_game AS outdoor_penalty_yards_per_game
       , b.penalty_yards_per_game AS indoor_penalty_yards_per_game
       , a.pass_attempts AS outdoor_pass_attempts
       , b.pass_attempts AS indoor_pass_attempts
       , a.pass_completions AS outdoor_pass_completions
       , b.pass_completions AS indoor_pass_completions
       , a.pass_yards AS outdoor_pass_yards
       , b.pass_yards AS indoor_pass_yards
       , a.interceptions AS outdoor_interceptions
       , b.interceptions AS indoor_interceptions
       , a.pass_tds AS outdoor_pass_tds
       , b.pass_tds AS indoor_pass_tds
       , a.rush_attempts AS outdoor_rush_attempts
       , b.rush_attempts AS indoor_rush_attempts
       , a.successful_rush_attempts AS outdoor_successful_rush_attempts
       , b.successful_rush_attempts AS indoor_successful_rush_attempts
       , a.rush_yards AS outdoor_rush_yards
       , b.rush_yards AS indoor_rush_yards
       , a.rush_tds AS outdoor_rush_tds
       , b.rush_tds AS indoor_rush_tds
       , a.fumbles_lost AS outdoor_fumbles_lost
       , b.fumbles_lost AS indoor_fumbles_lost
       , a.penalty_yardage AS outdoor_penalty_yardage
       , b.penalty_yardage AS indoor_penalty_yardage
       , a.conversions AS outdoor_conversions
       , b.conversions AS indoor_conversions
  FROM outdoor AS a
       LEFT JOIN indoor AS b
       ON a.season = b.season
          AND a.player_id = b.player_id

 UNION ALL  -- no full join or right join in SQLite so need 2nd left join swapping tables

SELECT a.season
       , a.first_name
       , a.last_name
       , a.player_id
       , b.num_games AS outdoor_games_played
       , a.num_games AS indoor_games_played
       , b.num_games * 1.0 / (a.num_games + b.num_games) * 100 AS pct_games_played_outdoor
       , a.num_games * 1.0 / (a.num_games + b.num_games) * 100 AS pct_games_played_indoor
       , b.passer_rating AS outdoor_passer_rating
       , a.passer_rating AS indoor_passer_rating
       , b.passer_rating - a.passer_rating AS passer_rating_diff
       , b.completion_pct AS outdoor_completion_pct
       , a.completion_pct AS indoor_completion_pct
       , b.completion_pct - a.completion_pct AS completion_pct_diff
       , b.pass_yards_per_attempt AS outdoor_pass_yards_per_attempt
       , a.pass_yards_per_attempt AS indoor_pass_yards_per_attempt
       , b.pass_yards_per_attempt - a.pass_yards_per_attempt AS pass_yards_per_attempt_diff
       , b.touchdown_pct AS outdoor_touchdown_pct
       , a.touchdown_pct AS indoor_touchdown_pct
       , b.touchdown_pct - a.touchdown_pct AS touchdown_pct_diff
       , b.interception_pct AS outdoor_interception_pct
       , a.interception_pct AS indoor_interception_pct
       , b.interception_pct - a.interception_pct AS interception_pct_diff
       , b.avg_fantasy_points_per_game AS outdoor_avg_fantasy_points_per_game
       , a.avg_fantasy_points_per_game AS indoor_avg_fantasy_points_per_game
       , b.avg_fantasy_points_per_game - a.avg_fantasy_points_per_game AS avg_fantasy_points_per_game_diff
       , b.avg_fantasy_points_total AS outdoor_avg_fantasy_points_total
       , a.avg_fantasy_points_total AS indoor_avg_fantasy_points_total
       , b.conversions_per_game AS outdoor_conversions_per_game
       , a.conversions_per_game AS indoor_conversions_per_game
       , b.rush_yards_per_attempt AS outdoor_rush_yards_per_attempt
       , a.rush_yards_per_attempt AS indoor_rush_yards_per_attempt
       , b.rush_yards_per_attempt - a.rush_yards_per_attempt AS rush_yards_per_attempt_diff
       , b.pass_attempts_per_game AS outdoor_pass_attempts_per_game
       , a.pass_attempts_per_game AS indoor_pass_attempts_per_game
       , b.pass_completions_per_game AS outdoor_pass_completions_per_game
       , a.pass_completions_per_game AS indoor_pass_completions_per_game
       , b.pass_yards_per_game AS outdoor_pass_yards_per_game
       , a.pass_yards_per_game AS indoor_pass_yards_per_game
       , b.pass_tds_per_game AS outdoor_pass_tds_per_game
       , a.pass_tds_per_game AS indoor_pass_tds_per_game
       , b.interceptions_per_game AS outdoor_interceptions_per_game
       , a.interceptions_per_game AS indoor_interceptions_per_game
       , b.rush_attempts_per_game AS outdoor_rush_attempts_per_game
       , a.rush_attempts_per_game AS indoor_rush_yards_per_attempt
       , b.successful_rush_attempts_per_game AS outdoor_successful_rush_attempts_per_game
       , a.successful_rush_attempts_per_game AS indoor_successful_rush_attempts_per_game
       , b.rush_yards_per_game AS outdoor_rush_yards_per_game
       , a.rush_yards_per_game AS indoor_rush_yards_per_game
       , b.rush_tds_per_game AS outdoor_rush_tds_per_game
       , a.rush_tds_per_game AS indoor_rush_tds_per_game
       , b.fumbles_lost_per_game AS outdoor_fumbles_lost_per_game
       , a.fumbles_lost_per_game AS indoor_fumbles_lost_Per_game
       , b.penalty_yards_per_game AS outdoor_penalty_yards_per_game
       , a.penalty_yards_per_game AS indoor_penalty_yards_per_game
       , b.pass_attempts AS outdoor_pass_attempts
       , a.pass_attempts AS indoor_pass_attempts
       , b.pass_completions AS outdoor_pass_completions
       , a.pass_completions AS indoor_pass_completions
       , b.pass_yards AS outdoor_pass_yards
       , a.pass_yards AS indoor_pass_yards
       , b.interceptions AS outdoor_interceptions
       , a.interceptions AS indoor_interceptions
       , b.pass_tds AS outdoor_pass_tds
       , a.pass_tds AS indoor_pass_tds
       , b.rush_attempts AS outdoor_rush_attempts
       , a.rush_attempts AS indoor_rush_attempts
       , b.successful_rush_attempts AS outdoor_successful_rush_attempts
       , a.successful_rush_attempts AS indoor_successful_rush_attempts
       , b.rush_yards AS outdoor_rush_yards
       , a.rush_yards AS indoor_rush_yards
       , b.rush_tds AS outdoor_rush_tds
       , a.rush_tds AS indoor_rush_tds
       , b.fumbles_lost AS outdoor_fumbles_lost
       , a.fumbles_lost AS indoor_fumbles_lost
       , b.penalty_yardage AS outdoor_penalty_yardage
       , a.penalty_yardage AS indoor_penalty_yardage
       , b.conversions AS outdoor_conversions
       , a.conversions AS indoor_conversions
  FROM indoor AS a
       LEFT JOIN outdoor AS b
       ON a.season = b.season
          AND a.player_id = b.player_id
 WHERE b.player_id IS NULL
 ORDER BY a.season, a.last_name
;