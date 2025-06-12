-- Neo Holgado and Kyle Marasa (Team 35)
-- CS340-400
-- 05/01/2025
-- Project Step 2 DDL queries

SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

-- CREATE TABLE queries --------------------------------------------------------------

-- Drop statement
DROP TABLE IF EXISTS Teams, Fighters, Fights, Participants, Events, Fighters_Events;

-- Create Teams Table
CREATE TABLE Teams(
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL, 
    website VARCHAR(300)
);

-- Create Events Table
CREATE TABLE Events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    date DATETIME NOT NULL
);

-- Create Fighters Table
CREATE TABLE Fighters (
    fighter_id INT AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    weight_class ENUM(
    'Flyweight',
    'Bantamweight',
    'Featherweight',
    'Lightweight',
    'Welterweight',
    'Middleweight',
    'Light Heavyweight',
    'Heavyweight'
    ) NOT NULL,
    age INT UNSIGNED NOT NULL,
    record VARCHAR(10),
    team_id INT NOT NULL,
    PRIMARY KEY (fighter_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- Create Fights Table
CREATE TABLE Fights (
    fight_id INT AUTO_INCREMENT,
    fight_name VARCHAR(200) UNIQUE NOT NULL,
    method ENUM('KO', 'TKO', 'Submission', 'Decision', 'Draw', 'DQ') NOT NULL,
    round INT UNSIGNED NOT NULL,
    championship TINYINT NOT NULL DEFAULT 0,
    event_id INT NOT NULL,
    PRIMARY KEY (fight_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

-- Create Participants Table
CREATE TABLE Participants (
    participant_id INT AUTO_INCREMENT,
    fighter_id INT NOT NULL,
    fight_id INT NOT NULL,
    result ENUM('WIN', 'LOSS', 'DRAW') NOT NULL,
    PRIMARY KEY (participant_id),
    FOREIGN KEY (fighter_id) REFERENCES Fighters(fighter_id) ON DELETE CASCADE,
    FOREIGN KEY (fight_id) REFERENCES Fights(fight_id) ON DELETE CASCADE
);

-- Create Fighters_Events Table
CREATE TABLE Fighters_Events (
    fighter_event_id INT AUTO_INCREMENT PRIMARY KEY,
    fighter_id INT NOT NULL,
    event_id INT NOT NULL,
    FOREIGN KEY (fighter_id) REFERENCES Fighters(fighter_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------------


-- INSERT queries -------------------------------------------------------------------

-- Insert data into Teams
INSERT IGNORE INTO Teams (team_name, location, website)
VALUES
('None', 'N/A', 'N/A'),
('Team Alpha', 'Seattle, WA', 'www.teamalphaseattle.com'),
('Team Zeta', 'Los Angeles, CA', 'www.teamzetalaca.com'),
('Team Omega', 'Miami, FL', 'www.teamomegamiami.com'),
('Team Theta', 'New York, NY', 'www.teamthetanyc.com');

-- Set variable for Teams
SET @none = (SELECT team_id FROM Teams WHERE team_name = 'None');
SET @team_alpha = (SELECT team_id FROM Teams WHERE team_name = 'Team Alpha');
SET @team_zeta = (SELECT team_id FROM Teams WHERE team_name = 'Team Zeta');
SET @team_omega = (SELECT team_id FROM Teams WHERE team_name = 'Team Omega');
SET @team_theta = (SELECT team_id FROM Teams WHERE team_name = 'Team Theta');

-- Insert data into Events
INSERT IGNORE INTO Events (event_name, location, date) 
VALUES 
('UFC 100: West', 'Los Angeles, CA', '2025-05-01'),
('UFC 200: East', 'Miami, FL', '2025-05-15'),
('UFC 300: Showdown', 'New York, NY', '2025-06-01');

-- Set variables for Events
SET @ufc_100 = (SELECT event_id FROM Events WHERE event_name = 'UFC 100: West');
SET @ufc_200 = (SELECT event_id FROM Events WHERE event_name = 'UFC 200: East');
SET @ufc_300 = (SELECT event_id FROM Events WHERE event_name = 'UFC 300: Showdown');

-- Insert data into Fighters
INSERT IGNORE INTO Fighters (first_name, last_name, weight_class, age, record, team_id)
VALUES
('Max', 'Holloway', 'Lightweight', 33, '26-8-0', @team_alpha),
('Jon', 'Jones', 'Heavyweight', 37, '28-1-0', @team_zeta),
('Alex', 'Pereira', 'Light Heavyweight', 37, '12-3-0', @team_omega),
('Islam', 'Makhachev', 'Lightweight', 33, '27-1-0', @team_theta);

-- Set variables for fighters
SET @max_holloway = (SELECT fighter_id FROM Fighters WHERE first_name = 'Max' AND last_name = 'Holloway');
SET @jon_jones = (SELECT fighter_id FROM Fighters WHERE first_name = 'Jon' AND last_name = 'Jones');
SET @alex_pereira = (SELECT fighter_id FROM Fighters WHERE first_name = 'Alex' AND last_name = 'Pereira');
SET @islam_makhachev = (SELECT fighter_id FROM Fighters WHERE first_name = 'Islam' AND last_name = 'Makhachev');
    
-- Insert data into Fights
INSERT IGNORE INTO Fights (fight_name, method, round, championship, event_id)
VALUES
('Alex Pereira VS. Islam Makhachev', 'Submission', 1, 0, @ufc_200),
('Jon Jones VS. Alex Pereira','KO', 2, 0, @ufc_100),
('Islam Makhachev VS. Max Holloway', 'TKO', 4, 1, @ufc_300);

-- Set variables for fights
SET @pereira_makhachev = (SELECT fight_id FROM Fights WHERE fight_name = 'Alex Pereira VS. Islam Makhachev');
SET @jones_pereira = (SELECT fight_id FROM Fights WHERE fight_name = 'Jon Jones VS. Alex Pereira');
SET @makhachev_holloway = (SELECT fight_id FROM Fights WHERE fight_name = 'Islam Makhachev VS. Max Holloway');

-- Insert data into Participants
INSERT IGNORE INTO Participants (fighter_id, fight_id, result)
VALUES
(@jon_jones, @jones_pereira, 'WIN'),
(@alex_pereira, @jones_pereira, 'LOSS'),
(@islam_makhachev, @makhachev_holloway, 'WIN'),
(@max_holloway, @makhachev_holloway, 'LOSS'),
(@alex_pereira, @pereira_makhachev, 'LOSS'),
(@islam_makhachev, @pereira_makhachev, 'WIN');

-- Insert data into Fighters_Events
INSERT IGNORE INTO Fighters_Events (fighter_id, event_id)
VALUES
(@alex_pereira, @ufc_200),
(@jon_jones, @ufc_200),
(@islam_makhachev, @ufc_100),
(@max_holloway, @ufc_300);

-- -- ---------------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS=1;
COMMIT;