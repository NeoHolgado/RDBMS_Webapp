// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 7432;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/fighters', async function (req, res) {
    try {
        // Get all fighters and their team names
        const [fighters] = await db.query(`
            SELECT Fighters.*, Teams.team_name FROM Fighters
            LEFT JOIN Teams
                ON Fighters.team_id = Teams.team_id;
        `);

        // Get all teams and their id's, names for dropdown
        const [teams] = await db.query('SELECT team_id, team_name FROM Teams;');
    res.render('fighters', { fighters: fighters, teams : teams });
    } catch (error) {
        console.error('Error loading fighters:', error);
        res.status(500).send('Error loading fighters.');
    }
});

app.get('/fights', async function (req, res) {
    try {
        // Get all fights and their event names
        const [fights] = await db.query(`
            SELECT Fights.*, Events.event_name FROM Fights
            LEFT JOIN Events
                ON Fights.event_id = Events.event_id;
        `);

        // Get a full list of events for dropdown
        const [events] = await db.query('SELECT event_id, event_name FROM Events;');

        // Get all fighters and join first/last names for dropdown
        const [fighters] = await db.query(`
            SELECT fighter_id, CONCAT(first_name, ' ', last_name) AS fighter_name
            FROM Fighters;
        `)
        res.render('fights_participants', { 
            fights, events, fighters 
        });
    } catch (error) {
        console.error('Error loading fights_participants:', error);
        res.status(500).send('Error loading fights_participants.');
    }
});

app.get('/participants', async function (req, res) {
    try {
        // Get all participants with fighter and fight names
        const [participants] = await db.query(`
            SELECT 
                Participants.*,
                CONCAT(Fighters.first_name, ' ', Fighters.last_name) AS fighter_name,
                Fights.fight_name
            FROM Participants
            LEFT JOIN Fighters ON Participants.fighter_id = Fighters.fighter_id
            LEFT JOIN Fights ON Participants.fight_id = Fights.fight_id;
        `);

        // Get all fighters for the dropdown
        const [fighters] = await db.query(`
            SELECT fighter_id, CONCAT(first_name, ' ', last_name) AS fighter_name
            FROM Fighters;
        `);

        // Get all fights for the dropdown
        const [fights] = await db.query(`
            SELECT fight_id, fight_name FROM Fights;
        `);

        res.render('participants', { participants, fighters, fights });
    } catch (error) {
        console.error('Error loading participants:', error);
        res.status(500).send('Error loading participants.');
    }
});

app.get('/teams', async function (req, res) {
    try {
        const [teams] = await db.query('SELECT * FROM Teams;');
        res.render('teams', { teams: teams });
    } catch (error) {
        console.error('Error loading teams:', error);
        res.status(500).send('Error loading teams.');
    }
});

app.get('/events', async function (req, res) {
    try {
        const [events_fighters] = await db.query('SELECT * FROM Fighters_Events;');
        const [events] = await db.query('SELECT * FROM Events;');
        const [fighters] = await db.query('SELECT fighter_id, first_name, last_name FROM Fighters;');

        const formattedEvents = events.map(event => {
            const date = new Date(event.date);
            event.date = date.toISOString().slice(0, 16);
            return event;
        });

        // READ Fighters names and Event Names
        const [fighters_events] = await db.query(`
            SELECT 
                Fighters_Events.*,
                CONCAT(Fighters.first_name, ' ', Fighters.last_name) AS fighter_name,
                Events.event_name
            FROM Fighters_Events
            LEFT JOIN Fighters ON Fighters_Events.fighter_id = Fighters.fighter_id
            LEFT JOIN Events ON Fighters_Events.event_id = Events.event_id;
        `);

        res.render('events_fighters', {
            events: formattedEvents,
            fighterEvents: events_fighters,
            fighters: fighters,
            fighters_events
        });
    } catch (error) {
        console.error('Error loading events/fighters:', error);
        res.status(500).send('Error loading events_fighters.');
    }
});

// RESET DATABASE
app.post('/reset', async (req, res) => {
    try {
        await db.query('CALL reset_db();');
        res.redirect('/')
    } catch (err) {
        console.error('Error resetting database:', err)
        res.status(500).send('Reset failed.');
    }
});

// eq helper
app.engine('.hbs', engine({
    extname: '.hbs',
    helpers: {
      eq: (a, b) => a === b
    }
  }));


// UPDATE FIGHTER 

app.post('/update-fighter', async (req, res) => {
    const { fighter_id, first_name, last_name, weight_class, age, record, team_id } = req.body;
    try {
        await db.query('CALL UpdateFighterById(?, ?, ?, ?, ?, ?, ?);', [fighter_id, first_name, last_name, weight_class, age, record, team_id]);
        res.redirect('/fighters');

    } catch (error) {
        console.error('Error updating fighter: ', error);
        res.status(500).send('Failed to update fighter'); 
    }
});

// DELETE FIGHTER
app.post('/delete-fighter', async (req, res) => {
    const { fighter_id } = req.body;

    try {
        await db.query('CALL DeleteFighterById(?);', [fighter_id]);
        res.redirect('/fighters');

    } catch (error) {
        console.error('Error, could not delete fighter:', error);
        res.status(500).send('Error deleting fighter.');
    }
});

// UPDATE FIGHT 

app.post('/update-fight', async (req, res) => {
    const { fight_id, fight_name, method, round, championship, event_id  } = req.body;
    try {
        await db.query('CALL UpdateFightById(?, ?, ?, ?, ?, ?);', [fight_id, fight_name, method, round, championship, event_id  ]);
        res.redirect('/fights');

    } catch (error) {
        console.error('Error updating fight: ', error);
        res.status(500).send('Failed to update fight'); 
    }
});

// DELETE FIGHT
app.post('/delete-fight', async (req, res) => {
    const { fight_id } = req.body;

    try {
        await db.query('CALL DeleteFightById(?);', [fight_id]);
        res.redirect('/fights');

    } catch (error) {
        console.error('Error, could not delete fight:', error);
        res.status(500).send('Error deleting fight.');
    }
});


// UPDATE TEAM

app.post('/update-team', async (req, res) => {
    const { team_id, team_name, location, website  } = req.body;
    try {
        await db.query('CALL UpdateTeamById(?, ?, ?, ?);', [ team_id, team_name, location, website ]);
        res.redirect('/teams');

    } catch (error) {
        console.error('Error updating team: ', error);
        res.status(500).send('Failed to update team'); 
    }
});


// DELETE TEAM
app.post('/delete-team', async (req, res) => {
    const { team_id } = req.body;

    try {
        await db.query('CALL DeleteTeamById(?);', [team_id]);
        res.redirect('/teams');

    } catch (error) {
        console.error('Error deleting team: ', error);
        res.status(500).send('Failed to delete team or tried to delete "None" team'); 
    }
});

// UPDATE PARTICIPANTS

app.post('/update-participant', async (req, res) => {
    const { participant_id, fighter_id, fight_id, result  } = req.body;
    try {
        await db.query('CALL UpdateParticipantByID(?, ?, ?, ?);', [ participant_id, fighter_id, fight_id, result ]);
        res.redirect('/participants');

    } catch (error) {
        console.error('Error updating participants: ', error);
        res.status(500).send('Failed to update participants'); 
    }
});

// DELETE PARTICIPANT
app.post('/delete-participant', async (req, res) => {
    const { participant_id } = req.body;

    try {
        await db.query('CALL DeleteParticipantById(?);', [participant_id]);
        res.redirect('/participants');

    } catch (error) {
        console.error('Error, could not delete participant:', error);
        res.status(500).send('Error deleting participant.');
    }
});

// UPDATE EVENT
app.post('/update-event', async (req, res) => {
    const { event_id, event_name, location, date  } = req.body;
    try {
        await db.query('CALL UpdateEventById(?, ?, ?, ?);', [  event_id, event_name, location, date  ]);
        res.redirect('/events');

    } catch (error) {
        console.error('Error updating events: ', error);
        res.status(500).send('Failed to update events'); 
    }
});

// DELETE EVENT
app.post('/delete-event', async (req, res) => {
    const { event_id } = req.body;

    try {
        await db.query('CALL DeleteEventById(?);', [event_id]);
        res.redirect('/events');

    } catch (error) {
        console.error('Error, could not delete event:', error);
        res.status(500).send('Error deleting event.');
    }
});

// CREATE Fighter
app.post('/add-fighter', async function (req, res) {
    try {
        // Parse frontend form data
        let data = req.body;

        // Validate that age is not negative
        const age = parseInt(data.age);
        if (isNaN(age) || age < 0) {
            return res.status(400).send('Age must be positive');
        }

        // Convert empty team_id to NULL
        const team_id = data.team_id === '' ? null : parseInt(data.team_id);

        // Prepare the stored procedure call
        const query = `CALL CreateFighter(?, ?, ?, ?, ?, ?, @new_fighter_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query, [
           data.first_name,
           data.last_name,
           age,
           data.weight_class,
           data.record,
           team_id 
        ]);
        
        console.log(`Fighter created`)
        res.redirect('/fighters');
    } catch (err) {
        console.error('Error Creating Fighter:', err);
        res.status(500).send('An error occurred while creating the fighter')
    }
});

// CREATE Fight
app.post('/add-fight', async function (req, res) {
    try {
        // Parse frontend form data
        let data = req.body;

        // Prepare the stored procedure call
        const query = `CALL CreateFight(?, ?, ?, ?, ?, @new_fight_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query, [
           data.fight_name,
           data.method,
           parseInt(data.round),
           parseInt(data.championship),
           parseInt(data.event_id)
        ]);
        
        console.log(`Fight created`)
        res.redirect('/fights');
    } catch (err) {
        console.error('Error Creating Fight:', err);
        res.status(500).send('An error occurred while creating the fight')
    }
});

// CREATE Participant
app.post('/add-participant', async function (req, res) {
    try {
        // Parse frontend form data
        let data = req.body;

        // Prepare the stored procedure call
        const query = `CALL CreateParticipant(?, ?, ?, @new_participant_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query, [
           parseInt(data.fighter_id),
           parseInt(data.fight_id),
           data.result
        ]);
        
        console.log(`Participant created:`)
        res.redirect('/participants');
    } catch (err) {
        console.error('Error Creating Participant', err);
        res.status(500).send('An error occurred while creating the participant')
    }
});

// CREATE Team
app.post('/add-team', async function (req, res) {
    try {
        // Parse frontend form data
        let data = req.body;

        // Prepare the stored procedure call
        const query = `CALL CreateTeam(?, ?, ?, @new_team_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query, [
           data.team_name,
           data.location,
           data.website
        ]);
        
        console.log(`Team created:`)
        res.redirect('/teams');
    } catch (err) {
        console.error('Error Creating Team', err);
        res.status(500).send('An error occurred while creating the team')
    }
});

// CREATE Event
app.post('/add-event', async function (req, res) {
    try {
        // Parse frontend form data
        let data = req.body;

        // Prepare the stored procedure call
        const query = `CALL CreateEvent(?, ?, ?, @new_event_id);`;

        // Store ID of last inserted row
        const [[rows]] = await db.query(query, [
           data.event_name,
           data.location,
           data.date
        ]);
        
        console.log(`Event created:`)
        res.redirect('/events');
    } catch (err) {
        console.error('Error Creating Event', err);
        res.status(500).send('An error occurred while creating the event')
    }
});

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});