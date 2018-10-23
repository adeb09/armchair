/* view that holds more play by play metrics; can be joined to any entity with pid
pid = play ID
gid = game ID
cum = cumulative
curr = current
qtr = quarter
succ = successful
uc = under center
sg = shotgun
nh = no-huddle
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
         , nh
         , sg
         , CASE
           WHEN NULLIF(sg, '') IS NULL THEN 'Y'
           ELSE ''
           END AS uc
         , succ
         , zone
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
         , SUM(CASE succ WHEN 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_plays_curr_half
         , cum_succ_run_plays
         , cum_succ_run_plays_curr_qtr
         , SUM(CASE WHEN succ = 'Y' AND "type" = 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_run_plays_curr_half
         , cum_succ_pass_plays
         , cum_succ_pass_plays_curr_qtr
         , SUM(CASE WHEN succ = 'Y' AND "type" = 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_pass_plays_curr_half
         , SUM(CASE WHEN uc = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_uc_succ_plays
         , SUM(CASE WHEN uc = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_uc_succ_plays_curr_qtr
         , SUM(CASE WHEN uc = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_uc_succ_plays_curr_half
         , SUM(CASE WHEN nh = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_nh_succ_plays
         , SUM(CASE WHEN nh = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_nh_succ_plays_curr_qtr
         , SUM(CASE WHEN nh = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_nh_succ_plays_curr_half
         , SUM(CASE WHEN sg = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_sg_succ_plays
         , SUM(CASE WHEN sg = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_sg_succ_plays_curr_qtr
         , SUM(CASE WHEN sg = 'Y' AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_sg_succ_plays_curr_half
         , SUM(CASE WHEN zone = 1 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_plays_own_0_20
         , SUM(CASE WHEN zone = 2 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_plays_own_21_40
         , SUM(CASE WHEN zone = 3 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_plays_midfield
         , SUM(CASE WHEN zone = 4 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_plays_opp_21_40
         , SUM(CASE WHEN zone = 5 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_succ_plays_redzone
         , SUM(CASE WHEN zone = 1 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_plays_own_0_20_curr_qtr
         , SUM(CASE WHEN zone = 2 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_plays_own_21_40_curr_qtr
         , SUM(CASE WHEN zone = 3 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_plays_midfield_curr_qtr
         , SUM(CASE WHEN zone = 4 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_plays_opp_21_40_curr_qtr
         , SUM(CASE WHEN zone = 5 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, qtr ORDER BY pid) AS cum_succ_plays_redzone_curr_qtr
         , SUM(CASE WHEN zone = 1 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_plays_own_0_20_curr_half
         , SUM(CASE WHEN zone = 2 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_plays_own_21_40_curr_half
         , SUM(CASE WHEN zone = 3 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_plays_midfield_curr_half
         , SUM(CASE WHEN zone = 4 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_plays_opp_21_40_curr_half
         , SUM(CASE WHEN zone = 5 AND succ = 'Y' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off, half ORDER BY pid) AS cum_succ_plays_redzone_curr_half
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
       , cum_succ_plays_curr_half
       , cum_succ_run_plays
       , cum_succ_run_plays_curr_qtr
       , cum_succ_run_plays_curr_half
       , cum_succ_pass_plays
       , cum_succ_pass_plays_curr_qtr
       , cum_succ_pass_plays_curr_half
       , cum_uc_succ_plays
       , cum_uc_succ_plays_curr_qtr
       , cum_uc_succ_plays_curr_half
       , cum_nh_succ_plays
       , cum_nh_succ_plays_curr_qtr
       , cum_nh_succ_plays_curr_half
       , cum_sg_succ_plays
       , cum_sg_succ_plays_curr_qtr
       , cum_sg_succ_plays_curr_half
       , cum_succ_plays_own_0_20
       , cum_succ_plays_own_21_40
       , cum_succ_plays_midfield
       , cum_succ_plays_opp_21_40
       , cum_succ_plays_redzone
       , cum_succ_plays_own_0_20_curr_qtr
       , cum_succ_plays_own_21_40_curr_qtr
       , cum_succ_plays_midfield_curr_qtr
       , cum_succ_plays_opp_21_40_curr_qtr
       , cum_succ_plays_redzone_curr_qtr
       , cum_succ_plays_own_0_20_curr_half
       , cum_succ_plays_own_21_40_curr_half
       , cum_succ_plays_midfield_curr_half
       , cum_succ_plays_opp_21_40_curr_half
       , cum_succ_plays_redzone_curr_half
  FROM sub
;