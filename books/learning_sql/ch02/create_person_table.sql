-- Program: SQL script to create the 'person' table.
-- Context: Example from the book "Learning SQL", Chapter 2.
-- Author: Greg Tate
-- Date: 2025-04-27
CREATE TABLE
    person (
        person_id SMALLINT UNSIGNED,
        fname VARCHAR(20),
        lname VARCHAR(20),
        eye_color ENUM('BR', 'BL', 'GR'),
        birth_date DATE,
        street VARCHAR(30),
        city VARCHAR(20),
        state VARCHAR(20),
        country VARCHAR(20),
        postal_code VARCHAR(20),
        CONSTRAINT pk_person PRIMARY KEY (person_id)
    );