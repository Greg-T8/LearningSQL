-- #########################################
-- MySQL Learning Notes - Chapter 02
-- Book: Learning SQL by Alan Beaulieu
-- #########################################

-- 1. Connecting to MySQL
-- mysql -u <username> -p              -- login to mysql
-- mysql -u <username> -p <database>   -- login to mysql and use a specific database

-- 2. General SQL Statements
show databases;                     -- show all databases
use <database>;                     -- use a specific database
show tables;                        -- show all tables in the current database

-- 3. Issuing SQL Statements
SELECT now();                  -- get the current date and time
