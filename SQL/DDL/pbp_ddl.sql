DROP TABLE IF EXISTS t_pbp
;

CREATE TABLE t_pbp (
       gid INT NOT NULL
       , pid INT PRIMARY KEY
       , detail VARCHAR(1000)
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
       , yds SMALLINT
       , succ CHAR(1)
       , fd CHAR(1)
       , sg CHAR(1)
       , nh CHAR(1)
       , pts SMALLINT
       , bc CHAR(7)
       , kne CHAR(1)
       , dir CHAR(2)
       , rtck1 CHAR(7)
       , rtck2 CHAR(7)
       , psr CHAR(7)
       , comp CHAR(1)
       , spk CHAR(1)
       , loc VARCHAR(2)
       , trg CHAR(7)
       , dfb CHAR(7)
       , ptck1 CHAR(7)
       , ptck2 CHAR(7)
       , sk1 CHAR(7)
       , sk2 CHAR(7)
       , ptm1 VARCHAR(3)
       , pen1 CHAR(7)
       , desc1 VARCHAR(50)
       , cat1 SMALLINT
       , pey1 SMALLINT
       , act1 CHAR(1)
       , ptm2 VARCHAR(3)
       , pen2 CHAR(7)
       , desc2 VARCHAR(50)
       , cat2 SMALLINT
       , pey2 SMALLINT
       , act2 CHAR(1)
       , ptm3 VARCHAR(3)
       , pen3 CHAR(7)
       , desc3 VARCHAR(50)
       , cat3 SMALLINT
       , pey3 SMALLINT
       , act3 CHAR(1)
       , ints CHAR(7)
       , iry SMALLINT
       , fum CHAR(7)
       , frcv CHAR(7)
       , fry VARCHAR(3)
       , forc CHAR(7)
       , saf CHAR(7)
       , blk CHAR(7)
       , brcv CHAR(7)
       , fgxp CHAR(2)
       , fkicker CHAR(7)
       , dist SMALLINT
       , good CHAR(1)
       , punter CHAR(7)
       , pgro VARCHAR(3)
       , pnet VARCHAR(3)
       , ptb CHAR(1)
       , pr CHAR(7)
       , pry VARCHAR(3)
       , pfc CHAR(1)
       , kicker CHAR(7)
       , kgro SMALLINT
       , knet SMALLINT
       , ktb CHAR(1)
       , kr CHAR(7)
       , kry SMALLINT
)
;

INSERT INTO t_pbp
SELECT * FROM pbp
;

DROP TABLE pbp
;

ALTER TABLE t_pbp RENAME TO pbp
;