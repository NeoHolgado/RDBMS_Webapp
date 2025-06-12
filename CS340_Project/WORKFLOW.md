# WORKFLOW for CS340_Project

**Clone Repository**
How to clone repository

1. Open terminal and navigate to the directory where you want to place the project
2. Clone the GitHub repository
    git clone https://github.com/Neo-Holgado/CS340_Project.git 
3. Navigate into project directory
    cd CS340_Project
4. Install dependencies
    npm install

**Project Branches**
    main
    neoBranch
    kyleBranch

**File Structure**
├── database
│   └── db-connector.js
├── node_modules
├── public
│   └── style.css
└── views
    ├── events_fighters.hbs
    ├── fighters.hbs
    ├── fights_participants.hbs
    ├── home.hbs
    ├── teams.hbs
    └── layouts
        └── main.hbs
└── .gitignore
├── app.js
├── package-lock.json
├── package.json
└── README.md
└── WORKFLOW.md

**Roles**
Create pages (make sure you are in your branch before starting development -- See below)

Neo:
1. Fighters page
    page located in CS340_Project/views/fighters.hbs
2. Fights and Participants page
    page located in CS340_Project/views/fights_participants.hbs

Kyle:
3. Teams page
    page located in CS340_Project/views/teams.hbs
4. Events and Fighters_Events
    page located in CS340_Project/views/fighters_events.hbs

**Feature Branch Workflow**
We will add our own code in our separate branches to avoid conflicts with the main branch
to ensure there is only working code in "main".  Once we know that our code works, we can 
merge with the main branch.

1. Start on main branch
    git checkout main
2. Pull latest changes
    git pull origin main
3. Switch to your own branch
    git checkout <name>Branch
4. Sync your branch with the main branch
    git checkout <name>Branch
    git pull origin main
5. Make changes, then commit and push in your branch
    git add .
    git commit -m "<commit message>"
    git push origin <name>Branch
6. Sync changes
    git checkout <name>Branch
7. Merge to main branch when feature is done (Only when you verify it works! See "Testing Development")
    git checkout main
    git pull origin main
    git merge <name>Branch
    git push origin main

**Testing Development**
npm run development

1. This can be run locally without remote connection on 
    http://localhost:7432
2. Or, when connected to OSU ENGR server through vpn and remote SSH connection
    http://classwork.engr.oregonstate.edu:7432/ 

**Keeping the application alive**
This step is only done after production is complete!

1. Input the following into terminal from project root directory
    npm run production