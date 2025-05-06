/*
Program: Alter person_id to AUTO_INCREMENT in person table
Context: Learning SQL, Chapter 2 (Book exercise)
Author: Greg Tate
Date: 2025-05-06
 */
set
    foreign_key_checks = 0;

ALTER TABLE person
MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;

set
    foreign_key_checks = 1;