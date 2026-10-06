-- =====================================================================
-- College Football Prediction App - SQL Server CREATE TABLE statements
-- Tables are created in dependency order (parents before children).
-- =====================================================================

-- Drop tables in reverse order so the script can be re-run
DROP TABLE IF EXISTS ReturnerStats;
DROP TABLE IF EXISTS KickerStats;
DROP TABLE IF EXISTS PunterStats;
DROP TABLE IF EXISTS DefenderStats;
DROP TABLE IF EXISTS RBStats;
DROP TABLE IF EXISTS QBStats;
DROP TABLE IF EXISTS PlayerStats;
DROP TABLE IF EXISTS PlayerPosition;
DROP TABLE IF EXISTS Player;
DROP TABLE IF EXISTS Position;
DROP TABLE IF EXISTS RosterCoach;
DROP TABLE IF EXISTS Roster;
DROP TABLE IF EXISTS Coach;
DROP TABLE IF EXISTS GamePrediction;
DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS WeeklyPredictionResults;
DROP TABLE IF EXISTS AppUserTeam;
DROP TABLE IF EXISTS AppUser;
DROP TABLE IF EXISTS Team;
DROP TABLE IF EXISTS Stadium;


create table Stadium (
    StadiumID int NOT NULL IDENTITY(1,1),
    StadiumAddress varchar(200) not null,
    Capacity int null,
    TypeOfField varchar(10) not null,
    CONSTRAINT PK_Stadium PRIMARY KEY (StadiumID),
    CONSTRAINT CK_Stadium_TypeOfField CHECK (TypeOfField IN ('Turf', 'Grass'))
);

-- HasHome: Team 1..1 -- 1..1 Stadium
create table Team (
    TeamID int NOT NULL IDENTITY(1,1),
    UniversityName varchar(100) not null,
    TeamName varchar(100) not null,
    StadiumID int not null,
    CONSTRAINT PK_Team PRIMARY KEY (TeamID),
    CONSTRAINT UQ_Team_Stadium UNIQUE (StadiumID),
    CONSTRAINT FK_Team_Stadium FOREIGN KEY (StadiumID) REFERENCES Stadium (StadiumID)
);

create table AppUser (
    AppUserID int NOT NULL IDENTITY(1,1),
    FirstName varchar(50) not null,
    LastName varchar(50) not null,
    Email varchar(100) not null,
    Password varchar(255) not null,
    CONSTRAINT PK_AppUser PRIMARY KEY (AppUserID),
    CONSTRAINT UQ_AppUser_Email UNIQUE (Email)
);

-- AppUser 0..* -- 0..* Team  (many-to-many -> junction table)
create table AppUserTeam (
    AppUserID int not null,
    TeamID int not null,
    CONSTRAINT PK_AppUserTeam PRIMARY KEY (AppUserID, TeamID),
    CONSTRAINT FK_AppUserTeam_AppUser FOREIGN KEY (AppUserID) REFERENCES AppUser (AppUserID),
    CONSTRAINT FK_AppUserTeam_Team FOREIGN KEY (TeamID) REFERENCES Team (TeamID)
);

-- Has: AppUser 1..1 -- 0..* WeeklyPredictionResults
create table WeeklyPredictionResults (
    WPRID int NOT NULL IDENTITY(1,1),
    StartDate date not null,
    NumberOfCorrectPredictions int not null DEFAULT 0,
    AppUserID int not null,
    CONSTRAINT PK_WeeklyPredictionResults PRIMARY KEY (WPRID),
    CONSTRAINT FK_WPR_AppUser FOREIGN KEY (AppUserID) REFERENCES AppUser (AppUserID)
);

-- PlayedAtHome, PlayedAway, WonBy (0..1), PlayedAt
create table Game (
    GameID int NOT NULL IDENTITY(1,1),
    GameDate date not null,
    GameTime time not null,
    HomeScore int null,
    AwayScore int null,
    HomeTeamID int not null,
    AwayTeamID int not null,
    WinningTeamID int null,
    StadiumID int not null,
    CONSTRAINT PK_Game PRIMARY KEY (GameID),
    CONSTRAINT FK_Game_HomeTeam FOREIGN KEY (HomeTeamID) REFERENCES Team (TeamID),
    CONSTRAINT FK_Game_AwayTeam FOREIGN KEY (AwayTeamID) REFERENCES Team (TeamID),
    CONSTRAINT FK_Game_WinningTeam FOREIGN KEY (WinningTeamID) REFERENCES Team (TeamID),
    CONSTRAINT FK_Game_Stadium FOREIGN KEY (StadiumID) REFERENCES Stadium (StadiumID)
);

-- Makes: AppUser 0..* -- 0..* Game, with GamePrediction as the association class
-- WinningPTeam: Team 1..1 -- 0..* GamePrediction
create table GamePrediction (
    GamePredictionID int NOT NULL IDENTITY(1,1),
    PredictionDateTime datetime not null,
    AppUserID int not null,
    GameID int not null,
    WinningPTeamID int not null,
    CONSTRAINT PK_GamePrediction PRIMARY KEY (GamePredictionID),
    CONSTRAINT UQ_GamePrediction_User_Game UNIQUE (AppUserID, GameID),
    CONSTRAINT FK_GamePrediction_AppUser FOREIGN KEY (AppUserID) REFERENCES AppUser (AppUserID),
    CONSTRAINT FK_GamePrediction_Game FOREIGN KEY (GameID) REFERENCES Game (GameID),
    CONSTRAINT FK_GamePrediction_Team FOREIGN KEY (WinningPTeamID) REFERENCES Team (TeamID)
);

create table Coach (
    CoachID int NOT NULL IDENTITY(1,1),
    CoachName varchar(100) not null,
    CONSTRAINT PK_Coach PRIMARY KEY (CoachID)
);

-- Has: Team 1..1 -- 0..* Roster
create table Roster (
    RosterID int NOT NULL IDENTITY(1,1),
    SeasonYear int not null,
    SeasonWins int not null DEFAULT 0,
    SeasonLosses int not null DEFAULT 0,
    SeasonTies int not null DEFAULT 0,
    TeamID int not null,
    CONSTRAINT PK_Roster PRIMARY KEY (RosterID),
    CONSTRAINT FK_Roster_Team FOREIGN KEY (TeamID) REFERENCES Team (TeamID)
);

-- Coach 0..* -- 0..* Roster  (many-to-many -> junction table)
create table RosterCoach (
    RosterID int not null,
    CoachID int not null,
    CONSTRAINT PK_RosterCoach PRIMARY KEY (RosterID, CoachID),
    CONSTRAINT FK_RosterCoach_Roster FOREIGN KEY (RosterID) REFERENCES Roster (RosterID),
    CONSTRAINT FK_RosterCoach_Coach FOREIGN KEY (CoachID) REFERENCES Coach (CoachID)
);

create table Position (
    PositionID int NOT NULL IDENTITY(1,1),
    PositionName varchar(20) not null,
    CONSTRAINT PK_Position PRIMARY KEY (PositionID),
    CONSTRAINT CK_Position_Name CHECK (PositionName IN ('QB', 'RB', 'Defender', 'Returner', 'Kicker', 'Punter'))
);

create table Player (
    PlayerID int NOT NULL IDENTITY(1,1),
    PlayerName varchar(100) not null,
    PlayerDateOfBirth date null,
    CONSTRAINT PK_Player PRIMARY KEY (PlayerID)
);

-- Plays: Player 0..* -- 1..* Position  (many-to-many -> junction table)
create table PlayerPosition (
    PlayerID int not null,
    PositionID int not null,
    CONSTRAINT PK_PlayerPosition PRIMARY KEY (PlayerID, PositionID),
    CONSTRAINT FK_PlayerPosition_Player FOREIGN KEY (PlayerID) REFERENCES Player (PlayerID),
    CONSTRAINT FK_PlayerPosition_Position FOREIGN KEY (PositionID) REFERENCES Position (PositionID)
);

-- On: Player 0..* -- 1..* Roster, with PlayerStats as the association class
-- PlayerStats is also the parent (superclass) of the six stats tables below
create table PlayerStats (
    PlayerStatsID int NOT NULL IDENTITY(1,1),
    Position varchar(20) not null,
    PlayerID int not null,
    RosterID int not null,
    CONSTRAINT PK_PlayerStats PRIMARY KEY (PlayerStatsID),
    CONSTRAINT FK_PlayerStats_Player FOREIGN KEY (PlayerID) REFERENCES Player (PlayerID),
    CONSTRAINT FK_PlayerStats_Roster FOREIGN KEY (RosterID) REFERENCES Roster (RosterID)
);

-- ---------------------------------------------------------------------
-- Subclasses of PlayerStats: each ID is both the PRIMARY KEY and a
-- FOREIGN KEY to PlayerStats, so no IDENTITY on these.
-- ---------------------------------------------------------------------
create table QBStats (
    QBStatsID int not null,
    Attempts int not null DEFAULT 0,
    Completions int not null DEFAULT 0,
    Yards int not null DEFAULT 0,
    TDs int not null DEFAULT 0,
    INTs int not null DEFAULT 0,
    CONSTRAINT PK_QBStats PRIMARY KEY (QBStatsID),
    CONSTRAINT FK_QBStats_PlayerStats FOREIGN KEY (QBStatsID) REFERENCES PlayerStats (PlayerStatsID)
);

create table RBStats (
    RBStatsID int not null,
    Carries int not null DEFAULT 0,
    Yards int not null DEFAULT 0,
    TDs int not null DEFAULT 0,
    Long int not null DEFAULT 0,
    Fumbles int not null DEFAULT 0,
    CONSTRAINT PK_RBStats PRIMARY KEY (RBStatsID),
    CONSTRAINT FK_RBStats_PlayerStats FOREIGN KEY (RBStatsID) REFERENCES PlayerStats (PlayerStatsID)
);

create table DefenderStats (
    DefenderStatsID int not null,
    Tackles int not null DEFAULT 0,
    Sacks decimal(4,1) not null DEFAULT 0,
    Interceptions int not null DEFAULT 0,
    DefensiveTDs int not null DEFAULT 0,
    CONSTRAINT PK_DefenderStats PRIMARY KEY (DefenderStatsID),
    CONSTRAINT FK_DefenderStats_PlayerStats FOREIGN KEY (DefenderStatsID) REFERENCES PlayerStats (PlayerStatsID)
);

create table PunterStats (
    PunterStatsID int not null,
    Punts int not null DEFAULT 0,
    Yards int not null DEFAULT 0,
    Long int not null DEFAULT 0,
    CONSTRAINT PK_PunterStats PRIMARY KEY (PunterStatsID),
    CONSTRAINT FK_PunterStats_PlayerStats FOREIGN KEY (PunterStatsID) REFERENCES PlayerStats (PlayerStatsID)
);

create table KickerStats (
    KickerStatsID int not null,
    FieldGoalAttempts int not null DEFAULT 0,
    FieldGoalsMade int not null DEFAULT 0,
    Long int not null DEFAULT 0,
    ExtraPointAttempts int not null DEFAULT 0,
    ExtraPointsMade int not null DEFAULT 0,
    CONSTRAINT PK_KickerStats PRIMARY KEY (KickerStatsID),
    CONSTRAINT FK_KickerStats_PlayerStats FOREIGN KEY (KickerStatsID) REFERENCES PlayerStats (PlayerStatsID)
);

create table ReturnerStats (
    ReturnerStatsID int not null,
    KickOffAttempts int not null DEFAULT 0,
    KickOffYards int not null DEFAULT 0,
    KickOffLong int not null DEFAULT 0,
    KickOffTDs int not null DEFAULT 0,
    PuntReturnAttempts int not null DEFAULT 0,
    PuntReturnYards int not null DEFAULT 0,
    PuntReturnLong int not null DEFAULT 0,
    PuntReturnTDs int not null DEFAULT 0,
    CONSTRAINT PK_ReturnerStats PRIMARY KEY (ReturnerStatsID),
    CONSTRAINT FK_ReturnerStats_PlayerStats FOREIGN KEY (ReturnerStatsID) REFERENCES PlayerStats (PlayerStatsID)
);
