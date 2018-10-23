DROP TABLE IF EXISTS t_drive
;

CREATE TABLE t_drive (
       uid INT PRIMARY KEY
       , gid INT NOT NULL
       , fpid INT
       , tname VARCHAR(3)
       , drvn SMALLINT
       , obt VARCHAR(4)
       , qtr SMALLINT
       , min SMALLINT
       , sec SMALLINT
       , yfog SMALLINT
       , plays SMALLINT
       , succ SMALLINT
       , rfd SMALLINT
       , pfd SMALLINT
       , ofd SMALLINT
       , ry SMALLINT
       , ra SMALLINT
       , py SMALLINT
       , pa SMALLINT
       , pc SMALLINT
       , peyf SMALLINT
       , peya SMALLINT
       , net SMALLINT
       , res VARCHAR(4)
)
;

INSERT INTO t_drive
SELECT * FROM drive
;

DROP TABLE drive
;

ALTER TABLE t_drive RENAME TO drive
;