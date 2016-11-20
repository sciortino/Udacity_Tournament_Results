-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP VIEW IF EXISTS swiss;
DROP VIEW IF EXISTS standing;
DROP TABLE IF EXISTS player, match;

CREATE TABLE player (
    player_pk   serial CONSTRAINT player_key PRIMARY KEY,
    name        varchar(100) NOT NULL
);

CREATE TABLE match (
    match_pk    serial CONSTRAINT match_key PRIMARY KEY,
    winner      integer REFERENCES player(player_pk),
    loser       integer REFERENCES player(player_pk)
);

CREATE VIEW standing
 AS SELECT p.player_pk as id, p.name, count(m.winner) as wins, count(m.winner)+count(m_losses.loser) as matches
 FROM player p 
 LEFT JOIN match m
 ON p.player_pk = m.winner
 LEFT JOIN match m_losses
 ON p.player_pk = m_losses.loser
 GROUP BY p.player_pk, p.name
 ORDER BY wins;

CREATE VIEW swiss
 AS 
SELECT p1.id as id1, p1.name as name1, p2.id as id2, p2.name as name2 
FROM (SELECT row_number() OVER (ORDER BY wins) as row_num, * FROM standing) p1
 LEFT JOIN (SELECT row_number() OVER (ORDER BY wins) as row_num, * FROM standing) p2
 ON p1.row_num = p2.row_num - 1
 WHERE p1.row_num % 2 = 1;