DROP TABLE IF EXISTS t_player
;

CREATE TABLE t_player(
  "player" CHAR(7),
  "fname" VARCHAR(20),
  "lname" VARCHAR(20),
  "pname" VARCHAR(20),
  "pos1" VARCHAR(2),
  "pos2" VARCHAR(2),
  "height" SMALLINT,
  "weight" SMALLINT,
  "dob" VARCHAR(10),
  "forty" DECIMAL(4, 2),
  "bench" SMALLINT,
  "vertical" DECIMAL(3, 1),
  "broad" SMALLINT,
  "shuttle" DECIMAL(4, 2),
  "cone" DECIMAL(4, 2),
  "arm" DECIMAL(5, 3),
  "hand" FLOAT,
  "dpos" SMALLINT,
  "col" VARCHAR(30),
  "dv" VARCHAR(30),
  "start" SMALLINT,
  "cteam" VARCHAR(3),
  "posd" VARCHAR(4),
  "jnum" SMALLINT,
  "dcp" SMALLINT,
  "nflid" INT
)
;

INSERT INTO t_player
SELECT * FROM player
;

DROP TABLE player
;

ALTER TABLE t_player RENAME TO player
;