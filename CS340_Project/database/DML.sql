-- Neo Holgado and Kyle Marasa (Team 35)
-- CS340-400
-- 05/08/2025
-- Project Step 3 DML queries

-- Fighters Entity -------------------------------------------------------------

-- Get all fighters, their data, and their team names to display in the table
SELECT Fighters.*, Teams.team_name
FROM Fighters
LEFT JOIN Teams 
    ON Fighters.team_id = Teams.team_id;

-- Get a single fighter's data for the update fighter form
SELECT fighter_id, first_name, last_name, weight_class, age, record, team_id
FROM Fighters
WHERE fighter_id = :fighter_id_selected_from_fighter_page;

-- Add a fighter
INSERT INTO Fighters (first_name, last_name, weight_class, age, record, team_id)
VALUES
(
    :first_name_input,
    :last_name_input,
    :weight_class_from_dropdown_input,
    :age_input,
    :record_input,
    :team_id_from_dropdown_input
);

-- Update a fighter's data based on submission of the update fighter form
UPDATE Fighters
SET
    first_name = :first_name_input,
    last_name = :last_name_input,
    weight_class = :weight_class_from_dropdown_input,
    age = :age_input,
    record = :record_input,
    team_id = :team_id_from_dropdown_input
WHERE fighter_id = :fighter_id_from_the_update_form;

-- Delete a Fighter
DELETE FROM Fighters WHERE fighter_id = :fighter_id_selected_from_fighter_page;

-- Dis-associate a Fight from from a Fighter (M-to-M relationship deletion)
DELETE FROM Fights
WHERE fighter_id = :fighter_id_selected_from_participant_list
AND fight_id = :fight_id_selected_from_participant_list;

-- Dis-associate an Event from a fighter (M-to-M relationship deletion)
DELETE FROM Events
WHERE fighter_id = :fighter_id_selected_from_fighter_and_event_list
AND event_id = :event_id_selected_from_fighter_and_event_list;

-- Fighters Entity -------------------------------------------------------------


-- Fights Entity ---------------------------------------------------------------

-- Get all fights, their data, and their event names to display in a table
SELECT Fights.*, Events.event_name FROM fights
LEFT JOIN Events
    ON Fights.event_id = Events.event_id;

-- Get a single fight's data for the update fighter form
SELECT fight_id, fight_name, method, round, championship, event_id
FROM Fights
WHERE fight_id = :fight_id_selected_from_fight_page;

-- Add a fight
INSERT INTO Fights (fight_name, method, round, championship, event_id)
VALUES (
    :fight_name_input,
    :method_from_dropdown_input, 
    :round_input, 
    :championship_from_dropdown_input,
    :event_id_from_dropdown_input
);

-- Update a fight based on submission of the update fight form
UPDATE Fights
SET
    fight_name = :fight_name_input,
    method = :method_from_dropdown_input,
    round = :round_input,
    championship = :championship_from_dropdown_input,
    event_id = :event_id_from_dropdown_input
WHERE fight_id= :fight_id_from_the_update_form;

-- Delete a fight
DELETE FROM Fights WHERE fight_id = :fight_id_selected_from_fight_page;

-- dis-associate a fighter from a fight (M-to-M relationship deletion)
DELETE FROM Fighter
WHERE fighter_id = :fighter_id_selected_from_participant_list
AND fight_id = :fight_id_selected_from_participant_list;

-- Fights Entity ---------------------------------------------------------------


-- Participants Entity ---------------------------------------------------------

-- Get all participants with their current associated Fighters and Fights to list
SELECT 
    Participants.*, 
    CONCAT(Fighters.first_name, ' ', Fighters.last_name) AS fighter_name,
    Fights.fight_name
FROM Participants
LEFT JOIN Fighters
    ON Participants.fighter_id = Fighters.fighter_id
LEFT JOIN Fights
    ON Participants.fight_id = Fights.fight_id
ORDER BY Fights.fight_name ASC;

-- Update a participant's result based on submission of the update participant form
UPDATE Participants
SET result = :result_from_dropdown_input
WHERE participant_id = :participant_id_from_the_update_form;

-- Participants Entity ---------------------------------------------------------


-- Teams Entity ----------------------------------------------------------------

SELECT * FROM Teams;

SELECT * FROM Teams WHERE team_id = :team_id_selected_from_team_page;


-- add new team
INSERT INTO Teams (team_name, location, website)
VALUES (
    :team_name_input,
    :location_input,
    :website_input

);

-- update teams
UPDATE Teams
SET
    team_name = :team_name_input,
    location = :location_input,
    website = :website_input
WHERE team_id = :team_id_from_the_update_form;

-- del team

DELETE FROM Teams WHERE team_id = :team_id_selected_from_team_page;

-- Teams Entity ----------------------------------------------------------------


-- Events Entity ---------------------------------------------------------------

SELECT * FROM Events;

SELECT * FROM Events WHERE event_id = :event_id_selected_from_event_page;

-- add new event
INSERT INTO Events (event_name, location, date)
VALUES (
    :event_name_input,
    :location_input,
    :date_input

);

-- update event
UPDATE Events
SET
    event_name = :event_name_input,
    location = :location_input,
    date = :date_input
WHERE event_id = :event_id_from_the_update_form;

-- del event

DELETE FROM Events WHERE event_id = :event_id_selected_from_event_page;


-- Events Entity ---------------------------------------------------------------


-- Fighters_Events Entity ------------------------------------------------------

-- READ operation for Fighter_Events intersection table, displays FK id's as Name counterparts
SELECT 
    Fighters_Events.*,
    CONCAT(Fighters.first_name, ' ', Fighters.last_name) AS fighter_name,
    Events.event_name
    FROM Fighters_Events
    LEFT JOIN Fighters ON Fighters_Events.fighter_id = Fighters.fighter_id
    LEFT JOIN Events ON Fighters_Events.event_id = Events.event_id;

-- Fighters_Events Entity ------------------------------------------------------