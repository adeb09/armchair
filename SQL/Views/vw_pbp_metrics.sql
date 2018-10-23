/* view that holds more play by play metrics; can be joined to any entity with pid 
cum = cumulative
curr = current
qtr = quarter
*/
DROP VIEW IF EXISTS vw_pbp_metrics
;

CREATE VIEW vw_pbp_metrics AS
WITH primary_key AS (
     SELECT DISTINCT pid
       FROM play
)

, rolling_stats AS (
  SELECT gid
         , pid
         , off
         , def
         , "type"
         , yds
         , qtr
         , CASE
           WHEN qtr <= 2 THEN 1
           ELSE 2
           END AS half
         , SUM(CASE "type" WHEN 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_rush_attempts
         , SUM(CASE "type" WHEN 'RUSH' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_rush_yards
         , SUM(CASE "type" WHEN 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_rush_attempts_curr_qtr
         , SUM(CASE "type" WHEN 'RUSH' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_rush_yards_curr_qtr
         , SUM(CASE "type" WHEN 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_pass_attempts
         , SUM(CASE "type" WHEN 'PASS' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_pass_yards
         , SUM(CASE "type" WHEN 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_pass_attempts_curr_qtr
         , SUM(CASE "type" WHEN 'PASS' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_pass_yards_curr_qtr
         , SUM(CASE succ WHEN 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_plays
         , SUM(CASE succ WHEN 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_plays_curr_qtr
         , SUM(CASE WHEN succ = 'Y' AND "type" = 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_run_plays
         , SUM(CASE WHEN succ = 'Y' AND "type" = 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_run_plays_curr_qtr
         , SUM(CASE WHEN succ = 'Y' AND "type" = 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_pass_plays
         , SUM(CASE WHEN succ = 'Y' AND "type" = 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_pass_plays_curr_qtr
    FROM pbp
)

, sub AS (
  SELECT gid
         , pid
         , off
         , def
         , "type"
         , cum_rush_attempts
         , cum_rush_yards
         , ROUND(cum_rush_yards * 1.0 / cum_rush_attempts, 2) AS yards_per_rush_attempt
         , cum_rush_attempts_curr_qtr
         , cum_rush_yards_curr_qtr
         , ROUND(cum_rush_yards_curr_qtr * 1.0 / cum_rush_attempts_curr_qtr, 2) AS yards_per_rush_attempt_curr_qtr
         , SUM(CASE "type" WHEN 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_rush_attempts_curr_half
         , SUM(CASE "type" WHEN 'RUSH' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_rush_yards_curr_half
         , cum_pass_attempts
         , cum_pass_yards
         , ROUND(cum_pass_yards * 1.0 / cum_pass_attempts, 2) AS yards_per_pass_attempt
         , cum_pass_attempts_curr_qtr
         , cum_pass_yards_curr_qtr
         , ROUND(cum_pass_yards_curr_qtr * 1.0 / cum_pass_attempts_curr_qtr, 2) AS yards_per_pass_attempt_curr_qtr
         , SUM(CASE "type" WHEN 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_pass_attempts_curr_half
         , SUM(CASE "type" WHEN 'PASS' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_pass_yards_curr_half
         , cum_succ_plays
         , cum_succ_plays_curr_qtr
         , cum_succ_run_plays
         , cum_succ_run_plays_curr_qtr
         , cum_succ_pass_plays
         , cum_succ_pass_plays_curr_qtr
    FROM rolling_stats
)

SELECT pid
       , cum_rush_attempts
       , cum_rush_yards
       , yards_per_rush_attempt
       , cum_rush_attempts_curr_qtr
       , cum_rush_yards_curr_qtr
       , yards_per_rush_attempt_curr_qtr
       , cum_rush_attempts_curr_half
       , cum_rush_yards_curr_half
       , ROUND(cum_rush_yards_curr_half * 1.0 / cum_rush_attempts_curr_half, 2) AS yards_per_rush_attempt_curr_half
       , cum_pass_attempts
       , cum_pass_yards
       , yards_per_pass_attempt
       , cum_pass_attempts_curr_qtr
       , cum_pass_yards_curr_qtr
       , yards_per_pass_attempt_curr_qtr
       , cum_pass_attempts_curr_half
       , cum_pass_yards_curr_half
       , ROUND(cum_pass_yards_curr_half * 1.0 / cum_pass_attempts_curr_half, 2) AS yards_per_pass_attempt_curr_half
       , cum_succ_plays
       , cum_succ_plays_curr_qtr
       , cum_succ_run_plays
       , cum_succ_run_plays_curr_qtr
       , cum_succ_pass_plays
       , cum_succ_pass_plays_curr_qtr
  FROM sub
 ORDER BY pid
;