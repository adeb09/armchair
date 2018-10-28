DROP TABLE IF EXISTS t_game
;

CREATE TABLE t_game (
  "gid" INT PRIMARY KEY,
  "seas" SMALLINT,
  "wk" SMALLINT,
  "day" VARCHAR(3),
  "v" VARCHAR(3),
  "h" VARCHAR(3),
  "stad" VARCHAR(50),
  "temp" SMALLINT,
  "humd" SMALLINT,
  "wspd" SMALLINT,
  "wdir" VARCHAR(4),
  "cond" VARCHAR(15),
  "surf" VARCHAR(20),
  "ou" DECIMAL(3, 1),
  "sprv" DECIMAL(3, 1),
  "ptsv" SMALLINT,
  "ptsh" SMALLINT
)
;

INSERT INTO t_game
SELECT * FROM game
;

DROP TABLE game
;

ALTER TABLE t_game RENAME TO game
;
