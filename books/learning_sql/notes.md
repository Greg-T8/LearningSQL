# My notes from "Learning SQL" by Alan Beaulieu

<img src='images/1744531821624.png' width='254'/>

<details>
<summary>Book Resources</summary>

- [Example MySQL Databases](https://dev.mysql.com/doc/index-other.html)

</details>

## Helpful Commands

```bash
# Shell commands
mysql -u <username> -p              -- login to mysql
mysql -u <username> -p <database>   -- login to mysql and use a specific database
mysql -u <username> -p <database> < script.sql  -- run a script
```


```sql
-- General MySQL statements
mysql> show databases;                     -- show all databases
mysql> use <database>;                     -- use a specific database
```


## Chapter 2: Creating and Populating a Database

### MySQL Data Types

- [MySQL Reference - Data Types](https://dev.mysql.com/doc/refman/8.4/en/data-types.html)

#### Character Data
- Stored as fixed-length or variable-length strings.
- Fixed-length strings are right-padded with spaces and always consume the same
  number of bytes
- Variable-length strings are stored with a length prefix and consume only the
  number of bytes needed to store the string.
- Variable-length strings are not right-padded with spaces.

Example:
```sql
char(20)                -- Fixed-length string of 20 characters
varchar(20)             -- Variable-length string of up to 20 characters
```

- Maximum length for `char` columns is 255 bytes
- `varchar` columns can be up to 65,535 bytes

- There are other text types, e.g. `mediumtext` and `longtext`, for storing longer strings, .e.g. emails, XML documents.

**Rule of Thumb**: use the `char` type when all strings are of the same length, such as state abbreviations.

#### Text Data

MySQL offers four text data types for storing larger strings:

| Type         | Maximum Size        | Best Use Case               |
| ------------ | ------------------- | --------------------------- |
| `tinytext`   | 255 bytes           | Short text                  |
| `text`       | 65,535 bytes        | Medium-length documents     |
| `mediumtext` | 16,777,215 bytes    | Larger documents            |
| `longtext`   | 4,294,967,295 bytes | Very large documents, files |

Important notes:
- Data exceeding column size will be truncated
- Trailing spaces are preserved
- For sorting/grouping, only the first 1,024 bytes are used
- `varchar` (up to 65,535 bytes) often eliminates the need for `tinytext`/`text` 
- Choose `varchar` for short free-form entries (e.g., notes fields) and `mediumtext`/`longtext` for document storage.

#### Numeric Data

MySQL provides several numeric data types for different storage needs.

##### Integer Types

| Type        | Signed Range                    | Unsigned Range     |
| ----------- | ------------------------------- | ------------------ |
| `tinyint`   | -128 to 127                     | 0 to 255           |
| `smallint`  | -32,768 to 32,767               | 0 to 65,535        |
| `mediumint` | -8,388,608 to 8,388,607         | 0 to 16,777,215    |
| `int`       | -2,147,483,648 to 2,147,483,647 | 0 to 4,294,967,295 |
| `bigint`    | -2^63 to 2^63 - 1               | 0 to 2^64 - 1      |

#####	 Floating-Point Types

For decimal values, MySQL offers `float` and `double` types with syntax `float(p, s)` or `double(p, s)`:
- `p` = precision (total digits)
- `s` = scale (digits after decimal point)

Examples:
```sql
float(7, 4)     -- Stores values like 123.4567
double(16, 8)   -- Stores values like 12345678.12345678
```

Note: Values exceeding specified precision will be rounded; attempting to store values with too many digits before the decimal point causes an error.

##### Temporal Types

The following table shows the MySQL temporal types, including the default format and the allowable values:

| Type        | Format              | Allowable Values                                   |
| ----------- | ------------------- | -------------------------------------------------- |
| `date`      | YYYY-MM-DD          | 1000-01-01 to 9999-12-31                           |
| `datetime`  | YYYY-MM-DD HH:MI:SS | 1000-01-01 00:00:00 to 9999-12-31 23:59:59         |
| `timestamp` | YYYY-MM-DD HH:MI:SS | 1970-01-01 00:00:01 UTC to 2038-01-19 03:14:07 UTC |
| `time`      | HHH:MMI:SS          | -838:59:59 to 838:59:59                            |
| `year`      | YYYY                | 1901 to 2155                                       |

Practical examples:  
- Columns to hold future shipping date would use the `date` type
- A column that holds information about actual shipping would use the `datetime` type
- A column that tracks when a user last modified a record would use the `timestamp` type
- Columns that hold data regarding the length of time to complete a task would use the `time` type

The following table shows the date format components.

| Component | Definition              | Range                         |
| --------- | ----------------------- | ----------------------------- |
| `YYYY`    | Year, including centruy | 1000 to 9999                  |
| `MM`      | Month                   | 01 (January) to 12 (December) |
| `DD`      | Day of the month        | 01 to 31                      |
| `HH`      | Hour of the day         | 00 to 23                      |
| `HHH`     | Hours (elapsed)         | -838 to 838                   |
| `MI`      | Minutes                 | 00 to 59                      |
| `SS`      | Seconds                 | 00 to 59                      |

#### Table Creation

The following example illustrates the design of a table using basic normalization:

![Person table](./ch02/ch02-database-design-for-person-table.svg)

The following script creates the `person` table:

```sql
CREATE TABLE person (
    person_id SMALLINT UNSIGNED,
    fname VARCHAR(20),
    lname VARCHAR(20),
    eye_color ENUM('BR','BL','GR'),
    birth_date DATE,
    street VARCHAR(30),
    city VARCHAR(20),
    state VARCHAR(20),
    country VARCHAR(20),
    postal_code VARCHAR(20),
    CONSTRAINT pk_person PRIMARY KEY (person_id)
);
```
See file [create_person_table.sql](./ch02/create_person_table.sql).

To run this script, issue the following command:

```bash
mysql -u <username> -p <database> < create_person_table.sql
```
<img src="images/1745783028752.png" width="450"/>

To confirm the table was created, issue the `describe` command:

```sql
desc person;
```
<img src="images/1745783213856.png" width="500"/>

Things to note:
- Column 3 `Null` indicates whether a column can be omitted when inserting data.
- Column 5 `Default` indicates whether a column can be populated with a default value.
- Column 6 `Extra` shows any other pertinent information about the column.

Since a person can have multiple favorite foods, we create a separate table, `favorite_food`, to store this information.

```sql
CREATE TABLE
    favorite_food (
        person_id SMALLINT UNSIGNED,
        food VARCHAR(20),
        CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
        CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id) REFERENCES person (person_id)
    )
```
See file [create_favorite_food.sql](./ch02/create_favorite_food.sql).

To run this script, issue the following command:

```bash
mysql -u <username> -p <database> < create_favorite_food.sql
```
<img src="images/1745784158974.png" width="500"/>

Things to note:
- The `PRIMARY KEY` constraint ensures that the combination of `person_id` and `food` is unique.
- The `FOREIGN KEY` constraint constrains the `person_id` column to only accept values that exist in the `person` table.

#### Populating and Modifying the Tables

With the tables created, you can now explore the four SQL data statments: `insert`, `update`, `delete`, and `select`.

##### Inserting Data

There are three main components to the `insert` statement:
- The name of the table into which you want to insert data
- The names of the columns in the table to be populated
- The values to be inserted into the columns

Unless all the columns have been defined with the `NOT NULL` constraint, you are not required to provide data for every column in the table. This means you can leave off columns that are not required.

##### Generating numeric key data

How are values generated for numeric primary keys? A couple of options:
- Look at largest value in the table and add 1
- Let the database engine generate the value for you

The first option is not a good idea because it proves problematic in a multi-user environment, since two users could be trying to insert data at the same time. The second option is a better choice, and MySQL provides the `AUTO_INCREMENT` attribute to do this:

`ALTER TABLE person MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;`

**Output:**  
<img src="images/1746517640544.png" width="850"/>

The output gives an error because you first need to disable the foreign key constraint on the `favorite_food` table. The following progession of statements will do this:

```sql
set foreign_key_checks = 0;
ALTER TABLE person
    MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;
set foreign_key_checks = 1;
```
[alter_table_auto_increment.sql](./ch02/alter_table_auto_increment.sql)  

**Output:**  
<img src="images/1746518280052.png" width="650"/>

Running the `desc` command on the `person` table shows that the `AUTO_INCREMENT` attribute has been added to the `person_id` column.

<img src="images/1746518369147.png" width="650"/>

When inserting data into the `person` table, you provide a `null` value for the `person_id` column. The database engine will automatically generate the next available number for you.

#### The `insert` statement

The following statement creates a row in the `person` table:

```sql
INSERT INTO person
  (person_id, fname, lname, eye_color, birth_date) 
VALUES (null, 'William', 'Turner', 'BR', '1972-05-27');
```

To confirm data was inserted, issue the following command:

```sql
SELECT person_id, fname, lname, birth_date FROM person;
```
**Output:**  
<img src="images/1746518774833.png" width="400"/>

**Note:** MySQL automatically generates the `person_id` value, in this case `1`.

If there were more rows in the table, you can add a `WHERE` clause to the `SELECT` statement to limit the output:

```sql
SELECT person_id, fname, lname, birth_date
FROM person
WHERE person_id=1;
```
**Output:**  
<img src="images/1746518948022.png" width="400"/>

**Note:**  
- Values were not provided for the `street`, `city`, `state`, `country`, and `postal_code` columns, so they are set to `null`.
- The value provided for `birth_date` is a string, which is converted to a date value by MySQL (as long as the string is in the correct format).
- The column names and values must correspond in number and type.

The following statements show inserting William's favorite foods into the `favorite_food` table:

```sql
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'pizza');
K, 1 row affected (0.05 sec)

INSERT INTO favorite_food (person_id, food)
VALUES (1, 'cookies');
K, 1 row affected (0.02 sec)

INSERT INTO favorite_food (person_id, food)
VALUES (1, 'nachos');
```
**Output:**  
<img src="images/1746519246778.png" width="400"/>

The following query retrieves William's favorite foods in alphabetical order:

```sql
SELECT food 
FROM favorite_food 
WHERE person_id = 1
ORDER BY food;
```
**Output:**  
<img src="images/1746519360413.png" width="500"/>

Adding Susan to the `person` table, including her address columns:

```sql
INSERT INTO person (person_id, fname, lname, eye_color, birth_date, street, city, state, country, postal_code) 
VALUES (null, 'Susan', 'Smith', 'BL', '1975-11-02', '23 Maple St.', 'Arlington', 'VA', 'USA', '20220');
```
Querying the `person` table shows that Susan's `person_id` is `2`:  
<img src="images/1746519643042.png" width="450"/>


##### Outputting in XML

With MySQL, you can use the `--xml` option to output the results of a query in XML format. This is useful for exporting data to other applications or for web services.

```bash
mysql -u gtate -p --xml sakila
```

Example output:  
<img src="images/1746519830941.png" width="750"/>


