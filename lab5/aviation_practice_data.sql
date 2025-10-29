-- Aviation Practice Dataset for Postgres
-- Schema + INSERTs (idempotent)
-- Run as a single script.

-- =====================================
-- DDL
-- =====================================

-- CREATE SCHEMA IF NOT EXISTS aviation;
-- SET search_path = aviation, public;

CREATE TABLE IF NOT EXISTS base (
    base_id   SERIAL PRIMARY KEY,
    name      TEXT NOT NULL UNIQUE,
    city      TEXT NOT NULL,
    state     TEXT NOT NULL,   -- e.g., 'NV', 'TX'
    country   TEXT NOT NULL DEFAULT 'USA'
);

CREATE TABLE IF NOT EXISTS aircraft (
    aircraft_id  SERIAL PRIMARY KEY,
    tail_number  TEXT NOT NULL UNIQUE,           -- e.g., 'AF-101'
    model        TEXT NOT NULL,                  -- e.g., 'F-16C'
    category     TEXT NOT NULL CHECK (category IN ('Fighter','Transport','Recon','Trainer','Tanker')),
    in_service   BOOLEAN NOT NULL DEFAULT TRUE,
    base_id      INTEGER REFERENCES base(base_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pilot (
    pilot_id     SERIAL PRIMARY KEY,
    first_name   TEXT NOT NULL,
    last_name    TEXT NOT NULL,
    callsign     TEXT NOT NULL,
    email        TEXT UNIQUE,
    gender       CHAR(1) NOT NULL CHECK (gender IN ('M','F')),
    age          INTEGER NOT NULL CHECK (age > 0),
    role         TEXT NOT NULL CHECK (role IN ('Captain','First Officer','Ground Crew','Instructor')),
    flight_hours NUMERIC(7,1) NOT NULL CHECK (flight_hours >= 0),
    base_id      INTEGER REFERENCES base(base_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS mission (
    mission_id      SERIAL PRIMARY KEY,
    code_name       TEXT NOT NULL UNIQUE,       -- e.g., 'Operation Night Hawk'
    mission_date    DATE NOT NULL,
    origin_base_id  INTEGER NOT NULL REFERENCES base(base_id),
    commander_id    INTEGER REFERENCES pilot(pilot_id) ON DELETE SET NULL
);

-- Many-to-many between missions and pilots
CREATE TABLE IF NOT EXISTS mission_pilot (
    mission_id       INTEGER REFERENCES mission(mission_id) ON DELETE CASCADE,
    pilot_id         INTEGER REFERENCES pilot(pilot_id)   ON DELETE CASCADE,
    role_in_mission  TEXT NOT NULL CHECK (role_in_mission IN ('Commander','Pilot','First Officer','Crew Chief','Observer')),
    PRIMARY KEY (mission_id, pilot_id)
);

-- Many-to-many between missions and aircraft
CREATE TABLE IF NOT EXISTS mission_aircraft (
    mission_id    INTEGER REFERENCES mission(mission_id)  ON DELETE CASCADE,
    aircraft_id   INTEGER REFERENCES aircraft(aircraft_id) ON DELETE CASCADE,
    sortied_hours NUMERIC(5,1) CHECK (sortied_hours >= 0),
    PRIMARY KEY (mission_id, aircraft_id)
);

-- =====================================
-- Indexes
-- =====================================

CREATE INDEX IF NOT EXISTS idx_pilot_base ON pilot(base_id);
CREATE INDEX IF NOT EXISTS idx_aircraft_base ON aircraft(base_id);
CREATE INDEX IF NOT EXISTS idx_mission_date ON mission(mission_date);
CREATE INDEX IF NOT EXISTS idx_base_state ON base(state);

-- =====================================
-- Seed Data
-- =====================================

-- Bases
INSERT INTO base (name, city, state, country) VALUES
  ('Nellis AFB',        'Las Vegas',      'NV', 'USA'),
  ('Reno Field',        'Reno',           'NV', 'USA'),
  ('Sheppard AFB',      'Wichita Falls',  'TX', 'USA'),
  ('Ellington Field',   'Houston',        'TX', 'USA'),
  ('Edwards AFB',       'Edwards',        'CA', 'USA')
ON CONFLICT DO NOTHING;

-- Aircraft (joined to base by name to resolve FK)
INSERT INTO aircraft (tail_number, model, category, in_service, base_id)
SELECT a.tail_number, a.model, a.category, a.in_service, b.base_id
FROM (
  VALUES
    -- Nellis
    ('AF-101','F-16C','Fighter', TRUE,  'Nellis AFB'),
    ('AF-102','F-35A','Fighter', TRUE,  'Nellis AFB'),
    ('AF-103','RQ-4B','Recon',   TRUE,  'Nellis AFB'),
    -- Reno
    ('RN-201','T-38C','Trainer', TRUE,  'Reno Field'),
    ('RN-202','C-130J','Transport',TRUE,'Reno Field'),
    -- Sheppard
    ('TX-301','KC-135R','Tanker', TRUE, 'Sheppard AFB'),
    ('TX-302','F-15E','Fighter',  TRUE, 'Sheppard AFB'),
    -- Ellington
    ('TX-401','C-17A','Transport',TRUE, 'Ellington Field'),
    ('TX-402','T-6A','Trainer',   TRUE, 'Ellington Field'),
    -- Edwards
    ('CA-501','F-22A','Fighter',  TRUE, 'Edwards AFB'),
    ('CA-502','RQ-170','Recon',   TRUE, 'Edwards AFB')
) AS a(tail_number,model,category,in_service,base_name)
JOIN base b ON b.name = a.base_name
ON CONFLICT DO NOTHING;

-- Pilots (8 per several bases; includes a deliberate non-flying role "Ground Crew")
INSERT INTO pilot (first_name,last_name,callsign,email,gender,age,role,flight_hours,base_id)
SELECT p.first_name,p.last_name,p.callsign,p.email,p.gender,p.age,p.role,p.flight_hours,b.base_id
FROM (
  VALUES
    -- Nellis AFB (NV)
    ('Jean','Dupont','Falcon','jean.dupont@airops.gov','M',34,'Captain',   1850.0,'Nellis AFB'),
    ('Amina','Bensaid','Nova','amina.bensaid@airops.gov','F',26,'First Officer', 820.5,'Nellis AFB'),
    ('Luca','Moretti','Viper','l.moretti@nato.int','M',29,'Instructor', 1400.0,'Nellis AFB'),
    ('Sara','Nguyen','Sable','sara.nguyen@gmail.com','F',24,'Ground Crew', 0.0,'Nellis AFB'),
    ('Owen','Carter','Talon','owen.carter@airops.gov','M',31,'First Officer', 990.2,'Nellis AFB'),
    ('Nina','Kovac','Raven','n.kovac@airops.gov','F',27,'Captain', 1305.7,'Nellis AFB'),
    ('Hiro','Tanaka','Zephyr','hiro.tanaka@airops.gov','M',25,'First Officer', 610.0,'Nellis AFB'),
    ('Maya','Lopez','Aurora','maya.lopez@yahoo.com','F',23,'First Officer', 520.3,'Nellis AFB'),

    -- Sheppard AFB (TX)
    ('Akari','Ito','Starlight','akari.ito@airops.gov','F',33,'Captain', 1725.4,'Sheppard AFB'),
    ('Carlos','Ramirez','Cougar','c.ramirez@airops.gov','M',30,'First Officer', 975.0,'Sheppard AFB'),
    ('Emily','Hall','Comet','emily.hall@gmail.com','F',22,'First Officer', 480.6,'Sheppard AFB'),
    ('James','King','Atlas','j.king@airops.gov','M',36,'Captain', 2105.3,'Sheppard AFB'),
    ('Ava','Johnson','Echo','ava.johnson@airops.gov','F',24,'Ground Crew', 0.0,'Sheppard AFB'),
    ('Logan','Davis','Bolt','logan.davis@yahoo.com','M',28,'Instructor', 1200.9,'Sheppard AFB'),

    -- Ellington Field (TX)
    ('Hannah','Wright','Siren','hannah.wright@airops.gov','F',27,'Captain', 1280.0,'Ellington Field'),
    ('Boris','Ivanov','Boreal','boris.ivanov@airops.gov','M',32,'First Officer', 1105.2,'Ellington Field'),
    ('Chloe','Fabre','Lynx','chloe.fabre@gmail.com','F',25,'First Officer', 690.4,'Ellington Field'),
    ('Rayan','Diallo','Ares','rayan.diallo@airops.gov','M',26,'Instructor', 1015.8,'Ellington Field'),

    -- Reno Field (NV)
    ('Mehdi','Talbi','Quasar','mehdi.talbi@gmail.com','M',24,'First Officer', 540.0,'Reno Field'),
    ('Lea','Giraud','Iris','lea.giraud@airops.gov','F',21,'First Officer', 360.5,'Reno Field'),
    ('Hugo','Perez','Draco','hugo.perez@hotmail.com','M',27,'Captain', 1455.9,'Reno Field'),

    -- Edwards AFB (CA)
    ('Thomas','Leroy','Aquila','t.leroy@airops.gov','M',35,'Captain', 1980.2,'Edwards AFB'),
    ('Clara','Moreau','Valkyrie','clara.moreau@airops.gov','F',31,'Captain', 1902.6,'Edwards AFB'),
    ('Marco','Rossi','Orion','marco.rossi@airops.gov','M',29,'First Officer', 905.5,'Edwards AFB')
) AS p(first_name,last_name,callsign,email,gender,age,role,flight_hours,base_name)
JOIN base b ON b.name = p.base_name
ON CONFLICT DO NOTHING;

-- Missions
INSERT INTO mission (code_name, mission_date, origin_base_id, commander_id)
SELECT m.code_name, m.mission_date, b.base_id, cmd.pilot_id
FROM (
  VALUES
    ('Operation Night Hawk','2025-02-05','Nellis AFB','Jean','Dupont'),
    ('Operation Sky Bridge','2025-02-18','Ellington Field','Hannah','Wright'),
    ('Operation Desert Shield','2025-03-01','Sheppard AFB','James','King'),
    ('Operation Silver Arrow','2025-03-12','Reno Field','Hugo','Perez'),
    ('Operation Northern Star','2025-03-20','Edwards AFB','Clara','Moreau'),
    ('Operation Dawn Patrol','2025-04-02','Nellis AFB','Nina','Kovac')
) AS m(code_name,mission_date,base_name,cmd_first,cmd_last)
JOIN base b ON b.name = m.base_name
JOIN pilot cmd ON cmd.first_name = m.cmd_first AND cmd.last_name = m.cmd_last
ON CONFLICT DO NOTHING;

-- Mission ⇄ Aircraft assignments
INSERT INTO mission_aircraft (mission_id, aircraft_id, sortied_hours)
SELECT ms.mission_id, ac.aircraft_id, x.sortied_hours
FROM (
  VALUES
    ('Operation Night Hawk','AF-101', 2.5),
    ('Operation Night Hawk','AF-103', 3.1),
    ('Operation Sky Bridge','TX-401', 4.0),
    ('Operation Sky Bridge','TX-402', 1.2),
    ('Operation Desert Shield','TX-301', 3.6),
    ('Operation Desert Shield','TX-302', 2.8),
    ('Operation Silver Arrow','RN-201', 1.7),
    ('Operation Silver Arrow','RN-202', 2.9),
    ('Operation Northern Star','CA-501', 3.3),
    ('Operation Northern Star','CA-502', 2.4),
    ('Operation Dawn Patrol','AF-102', 2.6),
    ('Operation Dawn Patrol','AF-103', 2.2)
) AS x(code_name,tail_number,sortied_hours)
JOIN mission ms ON ms.code_name = x.code_name
JOIN aircraft ac ON ac.tail_number = x.tail_number
ON CONFLICT DO NOTHING;

-- Mission ⇄ Pilot assignments
INSERT INTO mission_pilot (mission_id, pilot_id, role_in_mission)
SELECT ms.mission_id, pl.pilot_id, r.role_in_mission
FROM (
  VALUES
    -- Operation Night Hawk (Nellis)
    ('Operation Night Hawk','Jean','Dupont','Commander'),
    ('Operation Night Hawk','Amina','Bensaid','First Officer'),
    ('Operation Night Hawk','Owen','Carter','Pilot'),
    ('Operation Night Hawk','Luca','Moretti','Observer'),

    -- Operation Sky Bridge (Ellington)
    ('Operation Sky Bridge','Hannah','Wright','Commander'),
    ('Operation Sky Bridge','Boris','Ivanov','First Officer'),
    ('Operation Sky Bridge','Chloe','Fabre','Pilot'),

    -- Operation Desert Shield (Sheppard)
    ('Operation Desert Shield','James','King','Commander'),
    ('Operation Desert Shield','Akari','Ito','Pilot'),
    ('Operation Desert Shield','Carlos','Ramirez','First Officer'),

    -- Operation Silver Arrow (Reno)
    ('Operation Silver Arrow','Hugo','Perez','Commander'),
    ('Operation Silver Arrow','Mehdi','Talbi','First Officer'),
    ('Operation Silver Arrow','Lea','Giraud','Observer'),

    -- Operation Northern Star (Edwards)
    ('Operation Northern Star','Clara','Moreau','Commander'),
    ('Operation Northern Star','Thomas','Leroy','Pilot'),
    ('Operation Northern Star','Marco','Rossi','First Officer'),

    -- Operation Dawn Patrol (Nellis)
    ('Operation Dawn Patrol','Nina','Kovac','Commander'),
    ('Operation Dawn Patrol','Hiro','Tanaka','First Officer'),
    ('Operation Dawn Patrol','Maya','Lopez','Observer')
) AS r(code_name,first_name,last_name,role_in_mission)
JOIN mission ms ON ms.code_name = r.code_name
JOIN pilot pl ON pl.first_name = r.first_name AND pl.last_name = r.last_name
ON CONFLICT DO NOTHING;

-- =====================================
-- Checks (sanity examples; read-only diagnostics)
-- =====================================

-- Example: ensure all mission commanders are also in mission_pilot as 'Commander'
-- (not enforced; serves as a quick check query)
-- SELECT ms.code_name
-- FROM mission ms
-- LEFT JOIN mission_pilot mp ON mp.mission_id = ms.mission_id AND mp.role_in_mission = 'Commander'
-- WHERE mp.pilot_id IS NULL;

-- Example: pilots at NV or TX bases
-- SELECT p.first_name, p.last_name, b.name, b.state FROM pilot p JOIN base b ON p.base_id=b.base_id WHERE b.state IN ('NV','TX');

-- End of script.
