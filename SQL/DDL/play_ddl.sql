DROP TABLE IF EXISTS t_play
;

CREATE TABLE t_play (
       gid INT NOT NULL
       , pid INT PRIMARY KEY
       , off VARCHAR(3)
       , def VARCHAR(3)
       , "type" VARCHAR(4)
       , dseq SMALLINT
       , len SMALLINT
       , qtr SMALLINT
       , min SMALLINT
       , sec SMALLINT
       , ptso SMALLINT
       , ptsd SMALLINT
       , timo SMALLINT
       , timd SMALLINT
       , dwn SMALLINT
       , ytg SMALLINT
       , yfog SMALLINT
       , zone SMALLINT
       , fd SMALLINT
       , sg SMALLINT
       , nh SMALLINT
       , pts SMALLINT
       , tck SMALLINT
       , sk SMALLINT
       , pen SMALLINT
       , ints SMALLINT
       , fum SMALLINT
       , saf SMALLINT
       , blk SMALLINT
)
;

INSERT INTO t_play
SELECT * FROM play
;

DROP TABLE play
;

ALTER TABLE t_play RENAME TO play
;