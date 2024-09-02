SELECT current_database(), current_schema(), current_user;

CREATE USER tennis WITH PASSWORD '**************';
CREATE SCHEMA tennis;	
-- specifying the schema owner
ALTER SCHEMA tennis OWNER TO tennis;
	
-- assigning the default schema to the user
SHOW search_path;
SET search_path TO tennis,public;
ALTER USER tennis set SEARCH_PATH = 'tennis';


DROP TABLE IF EXISTS Players CASCADE;
CREATE TABLE Players (
    player_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    CONSTRAINT chk_name_length CHECK (LENGTH(first_name) > 0 AND LENGTH(last_name) > 0)
);

DROP TABLE IF EXISTS Tournaments CASCADE;
CREATE TABLE Tournaments (
    tournament_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surface VARCHAR(20) NOT NULL,
    CONSTRAINT chk_surface CHECK (surface IN ('Clay', 'Grass', 'Hard'))
);

DROP TABLE IF EXISTS tournament_editions CASCADE;
CREATE TABLE tournament_editions (
    edition_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tournament_id INTEGER REFERENCES Tournaments(tournament_id),
    year INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT chk_dates CHECK (start_date <= end_date),
    UNIQUE(tournament_id, year)
);

DROP TABLE IF EXISTS Matches CASCADE;
CREATE TABLE Matches (
    match_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    edition_id INTEGER REFERENCES TournamentEditions(edition_id),
    player1_id INTEGER REFERENCES Players(player_id),
    player2_id INTEGER REFERENCES Players(player_id),
    winner_id INTEGER REFERENCES Players(player_id),
    match_date DATE NOT NULL,
    round_rank INTEGER NOT NULL CHECK (round_rank BETWEEN 1 AND 7),
    CONSTRAINT chk_match_date CHECK (match_date IS NOT NULL)
);

SELECT * FROM prizemoney

ALTER table TournamentEditions rename to tournament_editions

DROP TABLE IF EXISTS player_matches CASCADE;
CREATE TABLE player_matches (
    match_id INTEGER REFERENCES Matches(match_id),
    player_id INTEGER REFERENCES Players(player_id),
    round_rank INTEGER CHECK (round_rank BETWEEN 1 AND 7),
    PRIMARY KEY (match_id, player_id)
);

DROP TABLE IF EXISTS prize_money CASCADE;
CREATE TABLE prize_money (
    tournament_id INTEGER REFERENCES Tournaments(tournament_id),
    round_rank INTEGER CHECK (round_rank BETWEEN 1 AND 7),
    prize_amount DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (tournament_id, round_rank),
    CONSTRAINT chk_prize_amount CHECK (prize_amount >= 0)
);







