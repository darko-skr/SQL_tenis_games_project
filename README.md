# Tennis Tournament Database

This project is a PostgreSQL-based database designed to manage data related to tennis tournaments, players, matches, and prize distribution. The database aims to model and store information in a normalized and structured manner, allowing for efficient queries and data analysis. Additionally, this project provides several analytical queries to gain insights into player performance, tournament prize distribution, and more.

# Key Features

- Normalization: The database schema is structured following the principles of database normalization, promoting data consistency, reducing redundancy, and ensuring efficient storage.

- Data Integrity: Various constraints are implemented to enforce data validity, such as primary keys, foreign keys, and check constraints. For example, constraints enforce valid surface types for tournaments and ensure that prize amounts are non-negative.

- Comprehensive Data Model: The schema includes tables for players, tournaments, tournament editions, matches, prize money, and the participation of players in matches, allowing for complex relationships and querying capabilities.

# Schema Overview

- Players: Stores information about tennis players, such as first name, last name, and birth date.

- Tournaments: Contains data on tennis tournaments, including the surface type (Clay, Grass, Hard) and the tournament name.

- Tournament Editions: Tracks different editions of a tournament by year and includes the start and end dates.

- Matches: Stores data about matches between players, including the players involved, the match date, and the round (e.g., final).

- Player Matches: Records the participation of players in specific matches and the round they reached.

- Prize Money: Tracks the prize distribution based on the round achieved for each tournament.

# Analytical Queries

This project also includes a range of analytical SQL queries that demonstrate the database's potential for data analysis and reporting:
[SQL Analysis](https://github.com/darko-skr/tenis_games_project/blob/main/project_sql/SQL_Analysis.sql)
