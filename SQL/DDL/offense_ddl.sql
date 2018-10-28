DROP TABLE IF EXISTS t_offense
;

CREATE TABLE t_offense (
  "uid" INT PRIMARY KEY,
  "gid" INT NOT NULL,
  "player" CHAR(7),
  "pa" SMALLINT,
  "pc" SMALLINT,
  "py" SMALLINT,
  "ints" SMALLINT,
  "tdp" SMALLINT,
  "ra" SMALLINT,
  "sra" SMALLINT,
  "ry" SMALLINT,
  "tdr" SMALLINT,
  "trg" SMALLINT,
  "rec" SMALLINT,
  "recy" SMALLINT,
  "tdrec" SMALLINT,
  "ret" SMALLINT,
  "rety" SMALLINT,
  "tdret" SMALLINT,
  "fuml" SMALLINT,
  "peny" SMALLINT,
  "conv" SMALLINT,
  "fp" DECIMAL(4, 2),
  "fp2" DECIMAL(4, 2),
  "fp3" DECIMAL(4, 2),
  "game" SMALLINT,
  "seas" SMALLINT,
  "year" SMALLINT,
  "team" VARCHAR(3),
  "posd" VARCHAR(3),
  "jnum" SMALLINT,
  "dcp" SMALLINT,
  "nflid" INT
)
;

INSERT INTO t_offense
SELECT * FROM offense
;

DROP TABLE offense
;

ALTER TABLE t_offense RENAME TO offense
;