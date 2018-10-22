/* view that holds more play by play metrics; can be joined to any entity with pid */
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
         , SUM(CASE "type" WHEN 'RUSH' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_rush_attempts
         , SUM(CASE "type" WHEN 'RUSH' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_rush_yards
         , SUM(CASE "type" WHEN 'PASS' THEN 1 ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_pass_attempts
         , SUM(CASE "type" WHEN 'PASS' THEN yds ELSE 0 END) OVER (PARTITION BY gid, off ORDER BY pid) AS cum_pass_yards
    FROM pbp
   ORDER BY pid
)

SELECT gid
       , pid
       , off
       , def
       , "type"
       , cum_rush_attempts
       , cum_rush_yards
       , ROUND(cum_rush_yards * 1.0 / cum_rush_attempts, 2) AS yards_per_rush_attempt
       , cum_pass_attempts
       , cum_pass_yards
       , ROUND(cum_pass_yards * 1.0 / cum_pass_attempts, 2) AS yards_per_pass_attempt
  FROM rolling_stats
;