/* query to spot check vw_pbp_metrics */

SELECT a.*
       , b.*
  FROM pbp AS a
       INNER JOIN vw_pbp_metrics AS b
       ON a.pid = b.pid
 WHERE a.pid BETWEEN 2000 AND 3000
;