
-- Basketball Practice Dataset for Postgres
-- Schema + INSERTs
-- Run as a single script.

-- ============================
-- DDL (idempotent, safe re-run)
-- ============================

CREATE TABLE IF NOT EXISTS team (
    team_id      SERIAL PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE,
    city         TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS coach (
    coach_id     SERIAL PRIMARY KEY,
    full_name    TEXT NOT NULL,
    role         TEXT NOT NULL DEFAULT 'Head Coach',
    team_id      INTEGER REFERENCES team(team_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS player (
    player_id    SERIAL PRIMARY KEY,
    first_name   TEXT NOT NULL,
    last_name    TEXT NOT NULL,
    email        TEXT UNIQUE,
    gender       CHAR(1) CHECK (gender IN ('M','F')),
    age          INTEGER CHECK (age > 0),
    position     TEXT CHECK (position IN ('Guard','Forward','Center','Coach Assistant')),
    avg_points   NUMERIC(5,2) DEFAULT 0,
    city         TEXT,
    state        TEXT,
    team_id      INTEGER REFERENCES team(team_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS match (
    match_id       SERIAL PRIMARY KEY,
    match_date     TEXT NOT NULL,
    venue_city     TEXT NOT NULL,
    home_team_id   INTEGER NOT NULL REFERENCES team(team_id),
    away_team_id   INTEGER NOT NULL REFERENCES team(team_id),
    home_score     INTEGER CHECK (home_score >= 0),
    away_score     INTEGER CHECK (away_score >= 0)
);

-- Participation / assignment of players to matches
CREATE TABLE IF NOT EXISTS match_player (
    match_id     INTEGER REFERENCES match(match_id) ON DELETE CASCADE,
    player_id    INTEGER REFERENCES player(player_id) ON DELETE CASCADE,
    starter      BOOLEAN DEFAULT FALSE,
    minutes      INTEGER CHECK (minutes >= 0),
    points       INTEGER CHECK (points >= 0),
    PRIMARY KEY (match_id, player_id)
);

-- ============================
-- Data
-- ============================

-- Teams
INSERT INTO team (name, city) VALUES
    ('Lyon Eagles',        'Lyon'),
    ('Marseille Sharks',   'Marseille'),
    ('Paris Titans',       'Paris'),
    ('Shelbyville Bears',  'Shelbyville'),
    ('Greenville Wolves',  'Greenville')
ON CONFLICT DO NOTHING;

-- Coaches
INSERT INTO coach (full_name, role, team_id)
SELECT c.full_name, c.role, t.team_id
FROM (
    VALUES
      ('Jean Dupont','Head Coach','Lyon Eagles'),
      ('Amina Bensaid','Head Coach','Marseille Sharks'),
      ('Thomas Leroy','Head Coach','Paris Titans'),
      ('Clara Moreau','Head Coach','Shelbyville Bears'),
      ('Marco Rossi','Head Coach','Greenville Wolves')
) AS c(full_name, role, team_name)
JOIN team t ON t.name = c.team_name
ON CONFLICT DO NOTHING;

-- Players (8 per team; include varied cities/states/emails/positions)
-- Lyon Eagles (Coach: Jean Dupont)
INSERT INTO player (first_name,last_name,email,gender,age,position,avg_points,city,state,team_id)
SELECT p.first_name,p.last_name,p.email,p.gender,p.age,p.position,p.avg_points,p.city,p.state,t.team_id
FROM (
    VALUES
      ('Luca','Moretti','luca.moretti@nba.com','M',21,'Guard',14.2,'Lyon','ARA'),
      ('Noah','Martin','noah.martin@gmail.com','M',24,'Forward',11.3,'Lyon','ARA'),
      ('Ethan','Durand','ethan.durand@yahoo.com','M',22,'Guard',9.7,'Villeurbanne','ARA'),
      ('Adam','Nguyen','adam.nguyen@outlook.com','M',20,'Center',6.5,'Lyon','ARA'),
      ('Sofia','Bernard','sofia.bernard@gmail.com','F',23,'Forward',12.9,'Lyon','ARA'),
      ('Amine','Khelifi','amine.khelifi@nba.com','M',25,'Guard',8.4,'Bron','ARA'),
      ('Julie','Roux','julie.roux@gmail.com','F',22,'Coach Assistant',0.0,'Lyon','ARA'),
      ('Milan','Zoric','milan.zoric@nba.com','M',19,'Guard',7.2,'Lyon','ARA')
) AS p(first_name,last_name,email,gender,age,position,avg_points,city,state)
JOIN team t ON t.name = 'Lyon Eagles'
ON CONFLICT DO NOTHING;

-- Marseille Sharks
INSERT INTO player (first_name,last_name,email,gender,age,position,avg_points,city,state,team_id)
SELECT p.first_name,p.last_name,p.email,p.gender,p.age,p.position,p.avg_points,p.city,p.state,t.team_id
FROM (
    VALUES
      ('Yanis','Haddad','yanis.haddad@nba.com','M',26,'Forward',13.1,'Marseille','PACA'),
      ('Mehdi','Talbi','mehdi.talbi@gmail.com','M',24,'Guard',10.8,'Marseille','PACA'),
      ('Omar','Benali','omar.benali@yahoo.com','M',22,'Center',7.9,'Aubagne','PACA'),
      ('Chloe','Fabre','chloe.fabre@gmail.com','F',21,'Forward',9.5,'Marseille','PACA'),
      ('Lea','Giraud','lea.giraud@nba.com','F',20,'Guard',6.8,'Marseille','PACA'),
      ('Hugo','Perez','hugo.perez@hotmail.com','M',23,'Guard',8.6,'Marseille','PACA'),
      ('Boris','Ivanov','boris.ivanov@nba.com','M',27,'Center',5.4,'Marseille','PACA'),
      ('Aline','Marchand','aline.marchand@gmail.com','F',22,'Coach Assistant',0.0,'Marseille','PACA')
) AS p(first_name,last_name,email,gender,age,position,avg_points,city,state)
JOIN team t ON t.name = 'Marseille Sharks'
ON CONFLICT DO NOTHING;

-- Paris Titans
INSERT INTO player (first_name,last_name,email,gender,age,position,avg_points,city,state,team_id)
SELECT p.first_name,p.last_name,p.email,p.gender,p.age,p.position,p.avg_points,p.city,p.state,t.team_id
FROM (
    VALUES
      ('Pierre','Leclerc','pierre.leclerc@nba.com','M',28,'Guard',15.2,'Paris','IDF'),
      ('Anton','Smirnov','anton.smirnov@gmail.com','M',24,'Forward',12.1,'Paris','IDF'),
      ('Rayan','Diallo','rayan.diallo@yahoo.com','M',23,'Center',9.0,'Paris','IDF'),
      ('Nina','Kovac','nina.kovac@gmail.com','F',22,'Forward',10.2,'Paris','IDF'),
      ('Elise','Laurent','elise.laurent@nba.com','F',25,'Guard',7.7,'Paris','IDF'),
      ('Ibrahim','Sow','ibrahim.sow@hotmail.com','M',21,'Guard',8.9,'Paris','IDF'),
      ('Paul','Garcia','paul.garcia@nba.com','M',26,'Center',6.1,'Saint-Denis','IDF'),
      ('Anna','Volkova','anna.volkova@gmail.com','F',20,'Coach Assistant',0.0,'Paris','IDF')
) AS p(first_name,last_name,email,gender,age,position,avg_points,city,state)
JOIN team t ON t.name = 'Paris Titans'
ON CONFLICT DO NOTHING;

-- Shelbyville Bears (city ends with 'ville')
INSERT INTO player (first_name,last_name,email,gender,age,position,avg_points,city,state,team_id)
SELECT p.first_name,p.last_name,p.email,p.gender,p.age,p.position,p.avg_points,p.city,p.state,t.team_id
FROM (
    VALUES
      ('Jack','Miller','jack.miller@gmail.com','M',23,'Guard',11.8,'Shelbyville','KY'),
      ('Ava','Johnson','ava.johnson@nba.com','F',22,'Forward',9.3,'Shelbyville','KY'),
      ('Logan','Davis','logan.davis@yahoo.com','M',24,'Center',7.0,'Shelbyville','KY'),
      ('Mason','Wilson','mason.wilson@hotmail.com','M',21,'Guard',8.1,'Shelbyville','KY'),
      ('Mia','Brown','mia.brown@nba.com','F',20,'Forward',6.9,'Shelbyville','KY'),
      ('Evelyn','Jones','evelyn.jones@gmail.com','F',19,'Guard',5.8,'Shelbyville','KY'),
      ('Henry','Taylor','henry.taylor@nba.com','M',25,'Center',6.2,'Shelbyville','KY'),
      ('Zoe','Anderson','zoe.anderson@gmail.com','F',23,'Coach Assistant',0.0,'Shelbyville','KY')
) AS p(first_name,last_name,email,gender,age,position,avg_points,city,state)
JOIN team t ON t.name = 'Shelbyville Bears'
ON CONFLICT DO NOTHING;

-- Greenville Wolves (city ends with 'ville')
INSERT INTO player (first_name,last_name,email,gender,age,position,avg_points,city,state,team_id)
SELECT p.first_name,p.last_name,p.email,p.gender,p.age,p.position,p.avg_points,p.city,p.state,t.team_id
FROM (
    VALUES
      ('Caleb','Harris','caleb.harris@nba.com','M',24,'Guard',10.4,'Greenville','SC'),
      ('Oliver','Clark','oliver.clark@gmail.com','M',22,'Forward',9.1,'Greenville','SC'),
      ('Isabella','Lewis','isabella.lewis@yahoo.com','F',23,'Center',6.0,'Greenville','SC'),
      ('Lucas','Walker','lucas.walker@hotmail.com','M',20,'Guard',7.5,'Greenville','SC'),
      ('Emily','Hall','emily.hall@nba.com','F',21,'Forward',8.2,'Greenville','SC'),
      ('Daniel','Young','daniel.young@gmail.com','M',26,'Guard',9.9,'Greenville','SC'),
      ('James','King','james.king@nba.com','M',27,'Center',5.7,'Greenville','SC'),
      ('Grace','Wright','grace.wright@gmail.com','F',22,'Coach Assistant',0.0,'Greenville','SC')
) AS p(first_name,last_name,email,gender,age,position,avg_points,city,state)
JOIN team t ON t.name = 'Greenville Wolves'
ON CONFLICT DO NOTHING;

-- Matches (2025 season sample)
INSERT INTO match (match_date, venue_city, home_team_id, away_team_id, home_score, away_score)
SELECT m.match_date, m.venue_city, th.team_id, ta.team_id, m.home_score, m.away_score
FROM (
    VALUES
      ('2025-01-15','Lyon','Lyon Eagles','Paris Titans',78,74),
      ('2025-01-22','Marseille','Marseille Sharks','Greenville Wolves',69,71),
      ('2025-02-03','Paris','Paris Titans','Shelbyville Bears',82,77),
      ('2025-02-17','Shelbyville','Shelbyville Bears','Lyon Eagles',75,79),
      ('2025-03-01','Greenville','Greenville Wolves','Marseille Sharks',73,68),
      ('2025-03-10','Lyon','Lyon Eagles','Marseille Sharks',88,81)
) AS m(match_date, venue_city, home_team, away_team, home_score, away_score)
JOIN team th ON th.name = m.home_team
JOIN team ta ON ta.name = m.away_team
ON CONFLICT DO NOTHING;

-- Assign players to matches (subset; enough coverage to make queries meaningful)
-- Lyon vs Paris (2025-01-15)
INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 30, s.pts
FROM match mt
JOIN team th ON th.team_id = mt.home_team_id AND th.name = 'Lyon Eagles'
JOIN player pl ON pl.team_id = th.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (12),(10),(8),(7)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-01-15'
ON CONFLICT DO NOTHING;

INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 28, s.pts
FROM match mt
JOIN team ta ON ta.team_id = mt.away_team_id AND ta.name = 'Paris Titans'
JOIN player pl ON pl.team_id = ta.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (14),(11),(9),(6)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-01-15'
ON CONFLICT DO NOTHING;

-- Marseille vs Greenville (2025-01-22)
INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 29, s.pts
FROM match mt
JOIN team th ON th.team_id = mt.home_team_id AND th.name = 'Marseille Sharks'
JOIN player pl ON pl.team_id = th.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (11),(10),(9),(7)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-01-22'
ON CONFLICT DO NOTHING;

INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 27, s.pts
FROM match mt
JOIN team ta ON ta.team_id = mt.away_team_id AND ta.name = 'Greenville Wolves'
JOIN player pl ON pl.team_id = ta.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (12),(9),(8),(5)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-01-22'
ON CONFLICT DO NOTHING;

-- Paris vs Shelbyville (2025-02-03)
INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 31, s.pts
FROM match mt
JOIN team th ON th.team_id = mt.home_team_id AND th.name = 'Paris Titans'
JOIN player pl ON pl.team_id = th.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (15),(12),(9),(8)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-02-03'
ON CONFLICT DO NOTHING;

INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 26, s.pts
FROM match mt
JOIN team ta ON ta.team_id = mt.away_team_id AND ta.name = 'Shelbyville Bears'
JOIN player pl ON pl.team_id = ta.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (13),(10),(7),(6)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-02-03'
ON CONFLICT DO NOTHING;

-- Shelbyville vs Lyon (2025-02-17)
INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 25, s.pts
FROM match mt
JOIN team th ON th.team_id = mt.home_team_id AND th.name = 'Shelbyville Bears'
JOIN player pl ON pl.team_id = th.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (10),(9),(8),(7)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-02-17'
ON CONFLICT DO NOTHING;

INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 28, s.pts
FROM match mt
JOIN team ta ON ta.team_id = mt.away_team_id AND ta.name = 'Lyon Eagles'
JOIN player pl ON pl.team_id = ta.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (13),(12),(9),(7)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-02-17'
ON CONFLICT DO NOTHING;

-- Greenville vs Marseille (2025-03-01)
INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 27, s.pts
FROM match mt
JOIN team th ON th.team_id = mt.home_team_id AND th.name = 'Greenville Wolves'
JOIN player pl ON pl.team_id = th.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (12),(11),(8),(6)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-03-01'
ON CONFLICT DO NOTHING;

INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 27, s.pts
FROM match mt
JOIN team ta ON ta.team_id = mt.away_team_id AND ta.name = 'Marseille Sharks'
JOIN player pl ON pl.team_id = ta.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (10),(9),(9),(6)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-03-01'
ON CONFLICT DO NOTHING;

-- Lyon vs Marseille (2025-03-10)
INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 29, s.pts
FROM match mt
JOIN team th ON th.team_id = mt.home_team_id AND th.name = 'Lyon Eagles'
JOIN player pl ON pl.team_id = th.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (16),(12),(10),(8)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-03-10'
ON CONFLICT DO NOTHING;

INSERT INTO match_player (match_id, player_id, starter, minutes, points)
SELECT mt.match_id, pl.player_id, TRUE, 28, s.pts
FROM match mt
JOIN team ta ON ta.team_id = mt.away_team_id AND ta.name = 'Marseille Sharks'
JOIN player pl ON pl.team_id = ta.team_id AND pl.position IN ('Guard','Forward')
JOIN LATERAL (VALUES (14),(11),(8),(6)) AS s(pts) ON TRUE
WHERE mt.match_date = '2025-03-10'
ON CONFLICT DO NOTHING;

-- Indexes to speed up common queries
CREATE INDEX IF NOT EXISTS idx_player_team ON player(team_id);
CREATE INDEX IF NOT EXISTS idx_match_date ON match(match_date);
CREATE INDEX IF NOT EXISTS idx_match_home_away ON match(home_team_id, away_team_id);
CREATE INDEX IF NOT EXISTS idx_match_player_player ON match_player(player_id);
