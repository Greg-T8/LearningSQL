# My notes from "Learning SQL" by Alan Beaulieu

<img src='images/1744531821624.png' width='254'/>

<details>
<summary>Book Resources</summary>

- [Example MySQL Databases](https://dev.mysql.com/doc/index-other.html)
- <details>
  <summary>Sakila Database Schema</summary>
  <img src='images/1747296772851.png' width='750'/>
  </details>

</details>

<!-- omit in toc -->
## Helpful Commands

```bash
# Shell commands
mysql -u <username> -p                          # login to mysql; the -p option prompts for a password
mysql -u <username> -p <database>               # login to mysql and use a specific database
mysql -u <username> -p <database> < script.sql  # run a script
mysql -u <username> -p <database> --xml         # show results in XML format
```

```sql
-- General MySQL statements
mysql> show databases;                     -- show all databases
mysql> use <database>;                     -- use a specific database
mysql> show tables;                        -- show all tables in the current database
mysql> desc <table>;                       -- show the structure of a table
mysql> select * from <table>;              -- select all rows from a table
mysql> pager less -S;                      -- use the pager to view long output
mysql> nopager;                            -- turn off the pager
```

<!-- omit in toc -->
## Contents
- [Chapter 2: Creating and Populating a Database](#chapter-2-creating-and-populating-a-database)
  - [MySQL Data Types](#mysql-data-types)
    - [Character Data](#character-data)
    - [Text Data](#text-data)
    - [Numeric Data](#numeric-data)
      - [Integer Types](#integer-types)
      - [Floating-Point Types](#floating-point-types)
      - [Temporal Types](#temporal-types)
    - [Table Creation](#table-creation)
    - [Populating and Modifying the Tables](#populating-and-modifying-the-tables)
      - [Inserting Data](#inserting-data)
      - [Updating Data](#updating-data)
      - [Deleting Data](#deleting-data)
    - [When Good Statements Go Bad](#when-good-statements-go-bad)
      - [Non-unique Primary Key](#non-unique-primary-key)
      - [Nonexistent Foreign Key](#nonexistent-foreign-key)
      - [Column Value Violations](#column-value-violations)
      - [Invalid Date Conversions](#invalid-date-conversions)
    - [The Sakila Database](#the-sakila-database)
- [Chapter 3: Query Primer](#chapter-3-query-primer)
  - [Query Mechanics](#query-mechanics)
  - [Query Clauses](#query-clauses)
  - [The `select` Clause](#the-select-clause)
    - [Column Aliases](#column-aliases)
    - [Removing Duplicates](#removing-duplicates)
  - [The `from` Clause](#the-from-clause)
    - [Tables](#tables)
      - [Derived (subquery-generated) Tables](#derived-subquery-generated-tables)
      - [Temporary Tables](#temporary-tables)
      - [Views](#views)
    - [Table Links](#table-links)
    - [Defining Table Aliases](#defining-table-aliases)
  - [The `where` Clause](#the-where-clause)
  - [The `group by` and `having` Clauses](#the-group-by-and-having-clauses)
  - [The `order by` Clause](#the-order-by-clause)
    - [Ascending Versus Descending Sort Order](#ascending-versus-descending-sort-order)
    - [Sorting via Numeric Placeholders](#sorting-via-numeric-placeholders)
  - [Test Your Knowledge](#test-your-knowledge)
- [Chapter 4: Filtering](#chapter-4-filtering)
  - [Condition Evaluation](#condition-evaluation)
  - [Building a Condition](#building-a-condition)
  - [Condition Types](#condition-types)
    - [Equality Conditions](#equality-conditions)
      - [Inequality conditions](#inequality-conditions)
      - [Data modification using equality conditions](#data-modification-using-equality-conditions)
    - [Range Conditions](#range-conditions)
      - [The `between` Operator](#the-between-operator)
      - [String ranges](#string-ranges)
    - [Membership Conditions (`in` Operator)](#membership-conditions-in-operator)
      - [Using subqueries](#using-subqueries)
      - [Using `not in`](#using-not-in)
    - [Matching Conditions](#matching-conditions)


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

#####  Floating-Point Types

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
[create_person_table.sql](./ch02/create_person_table.sql).

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
[create_favorite_food.sql](./ch02/create_favorite_food.sql).

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

###### Generating numeric key data

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

###### The `insert` statement

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


###### Outputting in XML

With MySQL, you can use the `--xml` option to output the results of a query in XML format. This is useful for exporting data to other applications or for web services.

```bash
mysql -u gtate -p --xml sakila
```

Example output:  
<img src="images/1746519830941.png" width="750"/>


##### Updating Data

Use the following command to populate columns in the `person` table that were not populated when the row was created:

```sql
UPDATE person
SET street = '1225 Tremont St.',
  city = 'Boston',
  state = 'MA',
  country = 'USA',
  postal_code = '02138'
WHERE person_id = 1;
```
**Output:**  
<img src="images/1746520147324.png" width="350"/>

##### Deleting Data

Use the following command to delete a row from the `person` table:

```sql
DELETE FROM person
WHERE person_id = 2;
```
**Output:**  
<img src="images/1746520340568.png" width="300"/>

**Note:** The primary key is used to identify the row to be deleted. If you do not specify a `WHERE` clause, all rows in the table will be deleted.

#### When Good Statements Go Bad

##### Non-unique Primary Key

The next statement attempts to bypass the `AUTO_INCREMENT` attribute by inserting a value into the `person_id` column:

```sql
INSERT INTO person
  (person_id, fname, lname, eye_color, birth_date)
VALUES (1, 'Charles', 'Fulton', 'GR', '1968-01-15');
```
**Output:**  
<img src="images/1746520552579.png" width="450"/>

##### Nonexistent Foreign Key

The foreign key constraint on the `favorite_food` table ensures that all values of `person_id` in the `favorite_food` table exist in the `person` table. The following statement attempts to insert a row into the `favorite_food` table with a `person_id` that does not exist in the `person` table:

```sql
INSERT INTO favorite_food (person_id, food)
VALUES (999, 'lasagna');
```
**Output:**  
<img src="images/1746520734368.png" width="650"/>

**Note:** The `favorite_food` table is considered the child table, and the `person` table is the parent table.

##### Column Value Violations

The `eye_color` column in the `person` table is defined as an `ENUM` type, which means it can only accept a limited set of values. The following statement attempts to insert a value that is not in the list of allowed values:

```sql
UPDATE person
SET eye_color = 'ZZ'
WHERE person_id = 1;
```
<img src="images/1746520948905.png" width="500"/>

##### Invalid Date Conversions

If you construct a date string that is not in the correct format, MySQL will not be able to convert it to a date value. The following statement attempts to insert an invalid date string into the `birth_date` column:

```sql
UPDATE person
SET birth_date = 'DEC-21-1980'
WHERE person_id = 1;
```
<img src="images/1746521055345.png" width="600"/>

In general, it's always a good idea to explicitly specify the format string rather than relying on MySQL to guess the format. The following statement uses the `str_to_date` function to specify the format of the date string:

```sql
UPDATE person
SET birth_date = str_to_date('DEC-21-1980', '%b-%d-%Y')   -- %Y = 4-digit year, %b = abbreviated month name
WHERE person_id = 1;
```
**Output:**  
<img src="images/1746521290350.png" width="500"/>

###### Formatting Strings

The following table shows the format strings that can be used with the `str_to_date` function:


| Format | Description                                        |
| ------ | -------------------------------------------------- |
| %a     | The short weekday name, such as Sun, Mon, ...      |
| %b     | The short month name, such as Jan, Feb, ...        |
| %c     | The numeric month (0..12)                          |
| %d     | The numeric day of the month (00..31)              |
| %f     | The number of microseconds (000000..999999)        |
| %H     | The hour of the day, in 24-hour format (00..23)    |
| %h     | The hour of the day, in 12-hour format (01..12)    |
| %i     | The minutes within the hour (00..59)               |
| %j     | The day of year (001..366)                         |
| %M     | The full month name (January..December)            |
| %m     | The numeric month                                  |
| %p     | AM or PM                                           |
| %s     | The number of seconds (00..59)                     |
| %W     | The full weekday name (Sunday..Saturday)           |
| %w     | The numeric day of the week (0=Sunday..6=Saturday) |
| %Y     | The four-digit year                                |


#### The Sakila Database

Produced by MySQL. Models a chain of DVD rental stores.

<img src='images/1747296772851.png' width='750'/>

Some of the tables used:

| Table name | Definition                                       |
| ---------- | ------------------------------------------------ |
| film       | A movie that has been released and can be rented |
| actor      | A person who acts in films                       |
| customer   | A person who watches films                       |
| category   | A genre of films                                 |
| payment    | A rental of a film by a customer                 |
| language   | A language spoken by the actors of a film        |
| film_actor | An actor in a film                               |
| inventory  | A film available for rental                      |

Use `show tables` to see all tables in the Sakila database:

<img src='images/1747297816688.png' width='200'/>

The tables `person` and `favorite_food` are not part of the Sakila database, but were created in this chapter to illustrate how to create and populate tables. 

Use the following command to drop these tables:

```sql
DROP TABLE favorite_food;
DROP TABLE person;
```

Use `describe` to look at the columns in a table:

```sql
desc customer;
```
<img src='images/1747298115512.png' width='650'/>

## Chapter 3: Query Primer

### Query Mechanics

After logging into MySQL, each time a query is sent, the server checks the following things:
1. Do you have permission to execute the statement?
2. Do you have permission to access the desired resource?
3. Is your syntax correct?

If your statement passes these checks, then your query is handed to the *query optimizer*. The query optimizer's job is to determine the most efficient way to execute the query based on the current database schema, available indexes, and statistics about the data. The optimizer looks at things the order in which to join the tables and the indexes available, and then pics an *execution plan*, which the server uses to execute your query.

Once the server finishes executing your query, the *result set* is returned to the calling application, which is the `mysql` tool. The result set is just another table.

<img src='images/1747298639326.png' width='350'/>


### Query Clauses

Several clauses make up the `select` statement:

| Clause name | Purpose                                                                |
| ----------- | ---------------------------------------------------------------------- |
| select      | Determines which columns to include in the query’s result set          |
| from        | Identifies the tables from which to retrieve data and how to join them |
| where       | Filters out unwanted data                                              |
| group by    | Used to group rows together by common column values                    |
| having      | Filters out unwanted groups                                            |
| order by    | Sorts the rows of the final result set by one or more columns          |

### The `select` Clause

The `select` clause is the first clause of a `select` statement. It is one of the last clauses that the database server evaluates. The `from` clause is the second clause of a `select` statement. It identifies the tables from which to retrieve data and how to join them.

```sql
mysql> SELECT * 
    -> FROM language;
```
<img src='images/1747299132326.png' width='350'/>

```sql
mysql> SELECT language_id, name, last_update
    -> FROM language;
```
<img src='images/1747299217897.png' width='350'/>

```sql
mysql> SELECT name
    -> FROM language;
```
<img src='images/1747299284126.png' width='200'/>

In addition to column names, you can include:
- Literals, such as strings or numbers
- Expressions, such as `transaction.amount * -1`
- Built-in function calls, such as `ROUND(transaction.amount, 2)`
- User-defined function calls, such as `my_function(transaction.amount)`

```sql
mysql> SELECT language_id,
    ->   'COMMON' language_usage,
    ->   language_id * 3.1415927 lang_pi_value,
    ->   upper(name) language_name
    -> FROM language;
```
<img src='images/1747299599635.png' width='450'/>

Here is an example of using built-in functions without a `from` clause:

```sql
mysql> SELECT version(),
    ->   user(),
    ->   database();
```
<img src='images/1747299916779.png' width='450'/>

#### Column Aliases

You can use column aliases to rename columns in the result set. This is useful for making the output more readable or for avoiding conflicts with reserved words.

```sql
mysql> SELECT language_id,
    ->   'COMMON' language_usage,                   -- Column alias: 'language_usage'
    ->   language_id * 3.1415927 lang_pi_value,     -- Column alias: 'lang_pi_value'
    ->   upper(name) language_name                  -- Column alias: 'language_name'
    -> FROM language;
```

You can also use the `as` keyword to make your intent clearer, although it is optional:

```sql
mysql> SELECT language_id,
    ->   'COMMON' AS language_usage,                   -- Column alias: 'language_usage'
    ->   language_id * 3.1415927 AS lang_pi_value,     -- Column alias: 'lang_pi_value'
    ->   upper(name) AS language_name                  -- Column alias: 'language_name'
    -> FROM language;
```
#### Removing Duplicates

A query might return duplicate rows of data:

```sql
SELECT actor_id FROM film_actor ORDER BY actor_id;
```
<img src='images/1747300639268.png' width='120'/>

Specify the `all` keyword to include all rows, including duplicates. This is the default, so you don't need to specify it:

```sql
SELECT ALL actor_id FROM film_actor ORDER BY actor_id;
```
Use the `distinct` keyword directly after `select` to remove duplicate rows:

```sql
SELECT DISTINCT actor_id FROM film_actor ORDER BY actor_id;
```
<img src='images/1747300777121.png' width='120'/>

**Note:** Generating a distinct set of results requires the data to be sorted, which can be a time-consuming process for large data sets. Don't fall into the trap of using `distinct` just to be sure there are no duplicates. Instead, take time to understand the data you are working with so that you'll know whether duplicates are possible.

### The `from` Clause

The `from` clause defines the tables used by a query, along with the means of linking tables together.

#### Tables

Types of tables:
- Permanent tables (i.e. created using the `create table` statement)
- Derived tables (i.e. rows returned by a subquery and held in memory)
- Temporary tables (i.e. volatile data held in memory)
- Virtual tables (i.e. created using the `create view` statement)

Each of these tables may be included in the query's `from` clause.

##### Derived (subquery-generated) Tables

A subquery is a query contained within another query. Subqueries are surrounded by parentheses and can be used in various parts of a `select` statement.

When used within the `from` clause, a subquery generates a derived table that is visible from all other query clauses and can interact with other tables named in the `from` clause.

```sql
mysql> SELECT concat(cust.last_name, ', ', cust.first_name) full_name
    -> FROM
    ->   (SELECT first_name, last_name, email       -- Subquery
    ->    FROM customer
    ->    WHERE first_name = 'Jessie'
    ->   ) cust;
```
<img src='images/1747302138487.png' width='500'/>

##### Temporary Tables

Tables look like permanent tables, but any data inserted will disappear at some point (generally at the end of a transaction or when your database session is closed). 

```sql
mysql> CREATE TEMPORARY TABLE actors_j
    -> (actor_id smallint(5),
    -> first_name varchar(45),
    -> last_name varchar(45)
    -> );
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> INSERT INTO actors_j
    -> SELECT actor_id, first_name, last_name
    -> FROM actor
    -> WHERE last_name LIKE 'J%';
Query OK, 7 rows affected (0.00 sec)
Records: 7  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM actors_j;
+----------+------------+-----------+
| actor_id | first_name | last_name |
+----------+------------+-----------+
|      119 | WARREN     | JACKMAN   |
|      131 | JANE       | JACKMAN   |
|        8 | MATTHEW    | JOHANSSON |
|       64 | RAY        | JOHANSSON |
|      146 | ALBERT     | JOHANSSON |
|       82 | WOODY      | JOLIE     |
|       43 | KIRK       | JOVOVICH  |
+----------+------------+-----------+
7 rows in set (0.00 sec)
```

##### Views

A view is a query that is stored in the data dictonary. It looks and acts like a table, but there is no data associated with a view. Because of this, some people refer to views as virtual tables. When you issue a query against a view, your query is merged with the view definition to create a final query to be executed.

```sql
mysql> CREATE VIEW cust_vw AS
    -> SELECT customer_id, first_name, last_name, active
    -> FROM customer;
Query OK, 0 rows affected (0.01 sec)

mysql> SELECT first_name, last_name
    -> FROM cust_vw
    -> WHERE active = 0;
+------------+-----------+
| first_name | last_name |
+------------+-----------+
| SANDRA     | MARTIN    |
| JUDITH     | COX       |
| SHEILA     | WELLS     |
| ERICA      | MATTHEWS  |
| HEIDI      | LARSON    |
| PENNY      | NEAL      |
| KENNETH    | GOODEN    |
| HARRY      | ARCE      |
| NATHAN     | RUNYON    |
| THEODORE   | CULP      |
| MAURICE    | CRAWLEY   |
| BEN        | EASTER    |
| CHRISTIAN  | JUNG      |
| JIMMIE     | EGGLESTON |
| TERRANCE   | ROUSH     |
+------------+-----------+
15 rows in set (0.00 sec)
```

No additional data is stored in the database for a view: the server simply tucks away the select statement for future use.

Views are created for various reasons, including to hide columns from users and to simplify complext database designs.

#### Table Links

After tables, the second derivation from the simple `from` clause is the mandate that if more than one table appears in the `from` clause, the conditions used to *link* the tables must be specified.

This mandate is the ANSI-approved method of joining tables and is the most portable across the various database servers.

```sql
mysql> SELECT customer.first_name, customer.last_name, time(rental.rental_date) rental_time
    -> FROM customer
    ->   INNER JOIN rental                                  -- Using a table link to join the tables
    ->   ON customer.customer_id = rental.customer_id
    -> WHERE date(rental.rental_date) = '2005-06-14';
+------------+-----------+-------------+
| first_name | last_name | rental_time |
+------------+-----------+-------------+
| JEFFERY    | PINSON    | 22:53:33    |
| ELMER      | NOE       | 22:55:13    |
| MINNIE     | ROMERO    | 23:00:34    |
| MIRIAM     | MCKINNEY  | 23:07:08    |
| DANIEL     | CABRAL    | 23:09:38    |
| TERRANCE   | ROUSH     | 23:12:46    |
| JOYCE      | EDWARDS   | 23:16:26    |
| GWENDOLYN  | MAY       | 23:16:27    |
| CATHERINE  | CAMPBELL  | 23:17:03    |
| MATTHEW    | MAHAN     | 23:25:58    |
| HERMAN     | DEVORE    | 23:35:09    |
| AMBER      | DIXON     | 23:42:56    |
| TERRENCE   | GUNDERSON | 23:47:35    |
| SONIA      | GREGORY   | 23:50:11    |
| CHARLES    | KOWALSKI  | 23:54:34    |
| JEANETTE   | GREENE    | 23:54:46    |
+------------+-----------+-------------+
16 rows in set (0.02 sec)
```

#### Defining Table Aliases

When multiple tables are joined in a query, you need a way to identify which table you are referring to when you reference columns in the `select`, `where`, `group by`, `having`, and `order by` clauses. You have two choices:
- Use the entire table name, such as `employee.emp_id`.
- Assign each table an *alias* and use the alias throughout the query.

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer c                                  -- Using a table alias
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14';
```

Additionally, you can use the `as` keyword to make your intent clearer, although it is optional:

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer AS c                               -- Using a table alias with 'as'
    ->   INNER JOIN rental AS r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14';
```

### The `where` Clause

The `where` clause is a mechanism for filtering out unwanted rows from your result set.

```
mysql> SELECT title
    -> FROM film
    -> WHERE rating = 'G' AND rental_duration >= 7;
+-------------------------+
| title                   |
+-------------------------+
| BLANKET BEVERLY         |
| BORROWERS BEDAZZLED     |
| BRIDE INTRIGUE          |
| CATCH AMISTAD           |
| CITIZEN SHREK           |
| COLDBLOODED DARLING     |
| CONTROL ANTHEM          |
| ...                     |
| WAKE JAWS               |
| WAR NOTTING             |
+-------------------------+
29 rows in set (0.00 sec)
```

Individual conditions are combined using the `and`, `or`, and `not` keywords.

```sql
mysql> SELECT title
    -> FROM film
    -> WHERE rating = 'G' OR rental_duration >= 7;
+---------------------------+
| title                     |
+---------------------------+
| ACE GOLDFINGER            |
| ADAPTATION HOLES          |
| AFFAIR PREJUDICE          |
| AFRICAN EGG               |
| ALAMO VIDEOTAPE           |
| AMISTAD MIDSUMMER         |
| ...                       |
| WESTWARD SEABISCUIT       |
| WOLVES DESIRE             |
| WON DARES                 |
| WORKER TARZAN             |
| YOUNG LANGUAGE            |
+---------------------------+
340 rows in set (0.00 sec)
```

When using both the `and` and `or` keywords, you can use parentheses to group conditions together:

```sql
mysql> SELECT title, rating, rental_duration
    -> FROM film
    -> WHERE (rating = 'G' AND rental_duration >= 7)
    ->   OR (rating = 'PG-13' AND rental_duration < 4);
+-------------------------+--------+-----------------+
| title                   | rating | rental_duration |
+-------------------------+--------+-----------------+
| ALABAMA DEVIL           | PG-13  |               3 |
| BACKLASH UNDEFEATED     | PG-13  |               3 |
| BILKO ANONYMOUS         | PG-13  |               3 |
| ...                                                |
| WAKE JAWS               | G      |               7 |
| WAR NOTTING             | G      |               7 |
| WORLD LEATHERNECKS      | PG-13  |               3 |
+-------------------------+--------+-----------------+
68 rows in set (0.00 sec)
```

### The `group by` and `having` Clauses

Use the `group by` clause to group the data by colummn values.

```sql
mysql> SELECT c.first_name, c.last_name, count(*)
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> GROUP BY c.first_name, c.last_name
    -> HAVING count(*) >= 40;
+------------+-----------+----------+
| first_name | last_name | count(*) |
+------------+-----------+----------+
| TAMMY      | SANDERS   |       41 |
| CLARA      | SHAW      |       42 |
| ELEANOR    | HUNT      |       46 |
| SUE        | PETERS    |       40 |
| MARCIA     | DEAN      |       42 |
| WESLEY     | BULL      |       40 |
| KARL       | SEAL      |       45 |
+------------+-----------+----------+
7 rows in set (0.02 sec)
```

When using the `group by` clause, you can use the `having` clause to filter out unwanted groups. The `having` clause is similar to the `where` clause, but it operates on groups of rows rather than individual rows.

### The `order by` Clause

The `order by` clause is the mechanism for sorting your result set using either raw column data or expressions based on column data.

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14';
+------------+-----------+-------------+
| first_name | last_name | rental_time |
+------------+-----------+-------------+
| JEFFERY    | PINSON    | 22:53:33    |
| ELMER      | NOE       | 22:55:13    |
| MINNIE     | ROMERO    | 23:00:34    |
| MIRIAM     | MCKINNEY  | 23:07:08    |
| DANIEL     | CABRAL    | 23:09:38    |
| TERRANCE   | ROUSH     | 23:12:46    |
| JOYCE      | EDWARDS   | 23:16:26    |
| GWENDOLYN  | MAY       | 23:16:27    |
| CATHERINE  | CAMPBELL  | 23:17:03    |
| MATTHEW    | MAHAN     | 23:25:58    |
| HERMAN     | DEVORE    | 23:35:09    |
| AMBER      | DIXON     | 23:42:56    |
| TERRENCE   | GUNDERSON | 23:47:35    |
| SONIA      | GREGORY   | 23:50:11    |
| CHARLES    | KOWALSKI  | 23:54:34    |
| JEANETTE   | GREENE    | 23:54:46    |
+------------+-----------+-------------+
16 rows in set (0.01 sec)
```

To sort the result set by a single column, use the `order by` clause:

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14'
    -> ORDER BY c.last_name;
+------------+-----------+-------------+
| first_name | last_name | rental_time |
+------------+-----------+-------------+
| DANIEL     | CABRAL    | 23:09:38    |
| CATHERINE  | CAMPBELL  | 23:17:03    |
| HERMAN     | DEVORE    | 23:35:09    |
| AMBER      | DIXON     | 23:42:56    |
| JOYCE      | EDWARDS   | 23:16:26    |
| JEANETTE   | GREENE    | 23:54:46    |
| SONIA      | GREGORY   | 23:50:11    |
| TERRENCE   | GUNDERSON | 23:47:35    |
| CHARLES    | KOWALSKI  | 23:54:34    |
| MATTHEW    | MAHAN     | 23:25:58    |
| GWENDOLYN  | MAY       | 23:16:27    |
| MIRIAM     | MCKINNEY  | 23:07:08    |
| ELMER      | NOE       | 22:55:13    |
| JEFFERY    | PINSON    | 22:53:33    |
| MINNIE     | ROMERO    | 23:00:34    |
| TERRANCE   | ROUSH     | 23:12:46    |
+------------+-----------+-------------+
16 rows in set (0.00 sec)
```

To sort the result set by multiple columns, list the columns in the `order by` clause, separated by commas:

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14'
    -> ORDER BY c.last_name, c.first_name;
+------------+-----------+-------------+
| first_name | last_name | rental_time |
+------------+-----------+-------------+
| DANIEL     | CABRAL    | 23:09:38    |
| CATHERINE  | CAMPBELL  | 23:17:03    |
| HERMAN     | DEVORE    | 23:35:09    |
| AMBER      | DIXON     | 23:42:56    |
| JOYCE      | EDWARDS   | 23:16:26    |
| JEANETTE   | GREENE    | 23:54:46    |
| SONIA      | GREGORY   | 23:50:11    |
| TERRENCE   | GUNDERSON | 23:47:35    |
| CHARLES    | KOWALSKI  | 23:54:34    |
| MATTHEW    | MAHAN     | 23:25:58    |
| GWENDOLYN  | MAY       | 23:16:27    |
| MIRIAM     | MCKINNEY  | 23:07:08    |
| ELMER      | NOE       | 22:55:13    |
| JEFFERY    | PINSON    | 22:53:33    |
| MINNIE     | ROMERO    | 23:00:34    |
| TERRANCE   | ROUSH     | 23:12:46    |
+------------+-----------+-------------+
16 rows in set (0.01 sec)
```

#### Ascending Versus Descending Sort Order

By default, the `order by` clause sorts the result set in ascending order. To sort in descending order, use the `desc` keyword:

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14'
    -> ORDER BY time(r.rental_date) desc;
+------------+-----------+-------------+
| first_name | last_name | rental_time |
+------------+-----------+-------------+
| JEANETTE   | GREENE    | 23:54:46    |
| CHARLES    | KOWALSKI  | 23:54:34    |
| SONIA      | GREGORY   | 23:50:11    |
| TERRENCE   | GUNDERSON | 23:47:35    |
| AMBER      | DIXON     | 23:42:56    |
| HERMAN     | DEVORE    | 23:35:09    |
| MATTHEW    | MAHAN     | 23:25:58    |
| CATHERINE  | CAMPBELL  | 23:17:03    |
| GWENDOLYN  | MAY       | 23:16:27    |
| JOYCE      | EDWARDS   | 23:16:26    |
| TERRANCE   | ROUSH     | 23:12:46    |
| DANIEL     | CABRAL    | 23:09:38    |
| MIRIAM     | MCKINNEY  | 23:07:08    |
| MINNIE     | ROMERO    | 23:00:34    |
| ELMER      | NOE       | 22:55:13    |
| JEFFERY    | PINSON    | 22:53:33    |
+------------+-----------+-------------+
16 rows in set (0.01 sec)
```

#### Sorting via Numeric Placeholders

If you are sorting using the columns in your `select` clause, you can use numeric placeholders to refer to the columns by their position in the `select` clause. The first column is 1, the second column is 2, and so on.

```sql
mysql> SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14'
    -> ORDER BY 3 desc;
+------------+-----------+-------------+
| first_name | last_name | rental_time |
+------------+-----------+-------------+
| JEANETTE   | GREENE    | 23:54:46    |
| CHARLES    | KOWALSKI  | 23:54:34    |
| SONIA      | GREGORY   | 23:50:11    |
| TERRENCE   | GUNDERSON | 23:47:35    |
| AMBER      | DIXON     | 23:42:56    |
| HERMAN     | DEVORE    | 23:35:09    |
| MATTHEW    | MAHAN     | 23:25:58    |
| CATHERINE  | CAMPBELL  | 23:17:03    |
| GWENDOLYN  | MAY       | 23:16:27    |
| JOYCE      | EDWARDS   | 23:16:26    |
| TERRANCE   | ROUSH     | 23:12:46    |
| DANIEL     | CABRAL    | 23:09:38    |
| MIRIAM     | MCKINNEY  | 23:07:08    |
| MINNIE     | ROMERO    | 23:00:34    |
| ELMER      | NOE       | 22:55:13    |
| JEFFERY    | PINSON    | 22:53:33    |
+------------+-----------+-------------+
16 rows in set (0.00 sec)
```
This feature is useful when you are sorting on an expression, such as in the example above.

### Test Your Knowledge

**Exercise 3-1:** Retrieve the actor ID, first name, and last name for all actors. Sort by last name and then by first name.

```sql
mysql> show tables;
+----------------------------+
| Tables_in_sakila           |
+----------------------------+
| actor                      |
| actor_info                 |
| address                    |
| category                   |
| city                       |
| country                    |
| cust_vw                    |
| customer                   |
| customer_list              |
| film                       |
| film_actor                 |
| film_category              |
| film_list                  |
| film_text                  |
| inventory                  |
| language                   |
| nicer_but_slower_film_list |
| payment                    |
| rental                     |
| sales_by_film_category     |
| sales_by_store             |
| staff                      |
| staff_list                 |
| store                      |
+----------------------------+
24 rows in set (0.00 sec)

mysql> desc actor;
+-------------+-------------------+------+-----+-------------------+-----------------------------------------------+
| Field       | Type              | Null | Key | Default           | Extra                                         |
+-------------+-------------------+------+-----+-------------------+-----------------------------------------------+
| actor_id    | smallint unsigned | NO   | PRI | NULL              | auto_increment                                |
| first_name  | varchar(45)       | NO   |     | NULL              |                                               |
| last_name   | varchar(45)       | NO   | MUL | NULL              |                                               |
| last_update | timestamp         | NO   |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |
+-------------+-------------------+------+-----+-------------------+-----------------------------------------------+
4 rows in set (0.00 sec)

mysql> SELECT actor_id, first_name, last_name
    -> FROM actor
    -> ORDER BY last_name, first_name;
+----------+-------------+--------------+
| actor_id | first_name  | last_name    |
+----------+-------------+--------------+
|       58 | CHRISTIAN   | AKROYD       |
|      182 | DEBBIE      | AKROYD       |
|       92 | KIRSTEN     | AKROYD       |
|...                                    |
|      111 | CAMERON     | ZELLWEGER    |
|      186 | JULIA       | ZELLWEGER    |
|       85 | MINNIE      | ZELLWEGER    |
+----------+-------------+--------------+
200 rows in set (0.00 sec)
```

**Exercise 3-2:** Retrieve the actor ID, first name, and last name for all actors whose last name equals 'WILLIAMS' or 'DAVIS'.

```sql
mysql> SELECT actor_id, first_name, last_name
    -> FROM actor
    -> WHERE (last_name = 'WILLIAMS') OR (last_name = 'DAVIS');
+----------+------------+-----------+
| actor_id | first_name | last_name |
+----------+------------+-----------+
|        4 | JENNIFER   | DAVIS     |
|      101 | SUSAN      | DAVIS     |
|      110 | SUSAN      | DAVIS     |
|       72 | SEAN       | WILLIAMS  |
|      137 | MORGAN     | WILLIAMS  |
|      172 | GROUCHO    | WILLIAMS  |
+----------+------------+-----------+
6 rows in set (0.00 sec)
```

**Exercise 3-3:** Write a query against the rental table that returns the IDs of the customers who rented a film on July 5, 2005 (use the rental.rental_date column, and you can use the date() function to ignore the time component). Include a single row for each distinct customer ID.

```sql
mysql> SELECT DISTINCT customer_id
    -> FROM rental
    -> WHERE date(rental_date) = '2005-07-05';
+-------------+
| customer_id |
+-------------+
|           8 |
|          37 |
|          60 |
|         111 |
|         114 |
|         138 |
|         142 |
|         169 |
|         242 |
|         295 |
|         296 |
|         298 |
|         322 |
|         348 |
|         349 |
|         369 |
|         382 |
|         397 |
|         421 |
|         476 |
|         490 |
|         520 |
|         536 |
|         553 |
|         565 |
|         586 |
|         594 |
+-------------+
27 rows in set (0.01 sec)
```

**Exercise 3-4:** Fill in the blanks (denoted by <#>) for this multitable query to achieve the following results: 

```sql
mysql> SELECT c.email, r.return_date
    -> FROM customer c
    ->   INNER JOIN rental <1>
    ->   ON c.customer_id = <2>
    -> WHERE date(r.rental_date) = '2005-06-14'
    -> ORDER BY <3> <4>;
+---------------------------------------+---------------------+
| email                                 | return_date         |
+---------------------------------------+---------------------+
| DANIEL.CABRAL@sakilacustomer.org      | 2005-06-23 22:00:38 |
| TERRANCE.ROUSH@sakilacustomer.org     | 2005-06-23 21:53:46 |
| MIRIAM.MCKINNEY@sakilacustomer.org    | 2005-06-21 17:12:08 |
| GWENDOLYN.MAY@sakilacustomer.org      | 2005-06-20 02:40:27 |
| JEANETTE.GREENE@sakilacustomer.org    | 2005-06-19 23:26:46 |
| HERMAN.DEVORE@sakilacustomer.org      | 2005-06-19 03:20:09 |
| JEFFERY.PINSON@sakilacustomer.org     | 2005-06-18 21:37:33 |
| MATTHEW.MAHAN@sakilacustomer.org      | 2005-06-18 05:18:58 |
| MINNIE.ROMERO@sakilacustomer.org      | 2005-06-18 01:58:34 |
| SONIA.GREGORY@sakilacustomer.org      | 2005-06-17 21:44:11 |
| TERRENCE.GUNDERSON@sakilacustomer.org | 2005-06-17 05:28:35 |
| ELMER.NOE@sakilacustomer.org          | 2005-06-17 02:11:13 |
| JOYCE.EDWARDS@sakilacustomer.org      | 2005-06-16 21:00:26 |
| AMBER.DIXON@sakilacustomer.org        | 2005-06-16 04:02:56 |
| CHARLES.KOWALSKI@sakilacustomer.org   | 2005-06-16 02:26:34 |
| CATHERINE.CAMPBELL@sakilacustomer.org | 2005-06-15 20:43:03 |
+---------------------------------------+---------------------+
16 rows in set (0.03 sec)
```
My solution:

```sql
mysql> SELECT c.email, r.return_date
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14'
    -> ORDER BY r.return_date desc, c.email desc;
+---------------------------------------+---------------------+
| email                                 | return_date         |
+---------------------------------------+---------------------+
| DANIEL.CABRAL@sakilacustomer.org      | 2005-06-23 22:00:38 |
| TERRANCE.ROUSH@sakilacustomer.org     | 2005-06-23 21:53:46 |
| MIRIAM.MCKINNEY@sakilacustomer.org    | 2005-06-21 17:12:08 |
| GWENDOLYN.MAY@sakilacustomer.org      | 2005-06-20 02:40:27 |
| JEANETTE.GREENE@sakilacustomer.org    | 2005-06-19 23:26:46 |
| HERMAN.DEVORE@sakilacustomer.org      | 2005-06-19 03:20:09 |
| JEFFERY.PINSON@sakilacustomer.org     | 2005-06-18 21:37:33 |
| MATTHEW.MAHAN@sakilacustomer.org      | 2005-06-18 05:18:58 |
| MINNIE.ROMERO@sakilacustomer.org      | 2005-06-18 01:58:34 |
| SONIA.GREGORY@sakilacustomer.org      | 2005-06-17 21:44:11 |
| TERRENCE.GUNDERSON@sakilacustomer.org | 2005-06-17 05:28:35 |
| ELMER.NOE@sakilacustomer.org          | 2005-06-17 02:11:13 |
| JOYCE.EDWARDS@sakilacustomer.org      | 2005-06-16 21:00:26 |
| AMBER.DIXON@sakilacustomer.org        | 2005-06-16 04:02:56 |
| CHARLES.KOWALSKI@sakilacustomer.org   | 2005-06-16 02:26:34 |
| CATHERINE.CAMPBELL@sakilacustomer.org | 2005-06-15 20:43:03 |
+---------------------------------------+---------------------+
16 rows in set (0.01 sec)
```

## Chapter 4: Filtering

All SQL data statements (except the `insert` command) include an optional `where` clause containing one or more *filter conditions* used to restrict the number of rows acted on by the SQL statement.

The `select` statement also includes a `having` clause in which filter conditions pertaining to grouped data may be included.

### Condition Evaluation

A `where` clause may have one or more `conditions` separated by operators `and` or `or`.

```sql
WHERE first_name = 'STEVEN' and create_date > '2006-01-01'
WHERE first_name = 'STEVEN' or create_date > '2006-01-01'
```

Using parentheses:

```sql
WHERE (first_name = 'STEVEN' or last_name = 'YOUNG') AND create_date > '2006-01-01'
```

Using the `not` operator:

```sql
WHERE NOT (first_name = 'STEVEN' or last_name = 'YOUNG') AND create_date > '2006-01-01'
```
It is difficult for a person to evaluate a `where` clause that includes the `not` operator, so you won't encounter it often. Instead, you will see the following style:

```sql
WHERE first_name <> 'STEVEN' AND last_name <> 'YOUNG' AND create_date > '2006-01-01'
```

### Building a Condition

A condition is made up of one or more *expressions* combined with one or more *operators*. 

An expression can be any of the following:
- A number
- A column in a table or view
- A string literal, such as 'Maple Street'
- A built-in function, such as concat('Learning', ' ', 'SQL')
- A subquery
- A list of expressions, such as ('Boston', 'New York', 'Chicago')

The operators used within conditions include:
- Comparison operators, such as `=`, `!=`, `<>`, `like`, `in`, and `between`
- Arithmetic operators, such as `+`, `-`, `*`, and `/`

### Condition Types

#### Equality Conditions

A large percentage of the filter conditions you write will be in the form `column = expression`:

```sql
title = 'RIVER OUTLAW'
fed_id = '111-11-1111'
amount = 375.25
film_id = (SELECT film_id FROM film WHERE title = 'RIVER OUTLAW')
```

The following query uses two equality conditions, one in the `on` clause (a join condition) and one in the `where` clause (a filter condition):

```sql
mysql> SELECT c.email
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) = '2005-06-14';

+---------------------------------------+
| email                                 |
+---------------------------------------+
| CATHERINE.CAMPBELL@sakilacustomer.org |
| JOYCE.EDWARDS@sakilacustomer.org      |
| AMBER.DIXON@sakilacustomer.org        |
| JEANETTE.GREENE@sakilacustomer.org    |
| MINNIE.ROMERO@sakilacustomer.org      |
| GWENDOLYN.MAY@sakilacustomer.org      |
| SONIA.GREGORY@sakilacustomer.org      |
| MIRIAM.MCKINNEY@sakilacustomer.org    |
| CHARLES.KOWALSKI@sakilacustomer.org   |
| DANIEL.CABRAL@sakilacustomer.org      |
| MATTHEW.MAHAN@sakilacustomer.org      |
| JEFFERY.PINSON@sakilacustomer.org     |
| HERMAN.DEVORE@sakilacustomer.org      |
| ELMER.NOE@sakilacustomer.org          |
| TERRANCE.ROUSH@sakilacustomer.org     |
| TERRENCE.GUNDERSON@sakilacustomer.org |
+---------------------------------------+
16 rows in set (0.02 sec)
```

##### Inequality conditions

The *inequality condition* asserts that two expressions are not equal:

```sql
mysql> SELECT c.email
    -> FROM customer c
    ->   INNER JOIN rental r
    ->   ON c.customer_id = r.customer_id
    -> WHERE date(r.rental_date) <> '2005-06-14';
```

When building inequality conditions, you can use the `!=` operator or the `<>` operator. Both operators are equivalent, but the `!=` operator is not ANSI SQL compliant.

##### Data modification using equality conditions

Equality/inequality conditions are commonly used when modifying data. 

```sql
mysql> DELETE FROM rental
    -> WHERE year(rental_date) <> 2005 AND year(rental_date) <> 2006;
```

#### Range Conditions

You can build conditions that check whether an expression is within a certain range.

```sql
mysql> SELECT customer_id, rental_date
    -> FROM rental
    -> WHERE rental_date <= '2005-05-16'
    ->   AND rental_date >= '2005-06-14';
```

##### The `between` Operator

When you have both a lower and upper bound for a range, you can use the `between` operator to simplify your query:

```sql
mysql> SELECT customer_id, rental_date
    -> FROM rental
    -> WHERE rental_date BETWEEN '2005-06-14' AND '2005-06-16';
```
When using the `between` operator, always specify the lower bound first, followed by the upper bound. 

The `between` operator is inclusive, meaning that the values specified in the range are included in the result set.

```sql
mysql> SELECT customer_id, payment_date, amount
    -> FROM payment
    -> WHERE amount BETWEEN 10.0 AND 11.99;
+-------------+---------------------+--------+
| customer_id | payment_date        | amount |
+-------------+---------------------+--------+
|           2 | 2005-07-30 13:47:43 |  10.99 |
|           3 | 2005-07-27 20:23:12 |  10.99 |
|          12 | 2005-08-01 06:50:26 |  10.99 |
---
|         591 | 2005-07-07 20:45:51 |  11.99 |
|         592 | 2005-07-06 22:58:31 |  11.99 |
|         595 | 2005-07-31 11:51:46 |  10.99 |
+-------------+---------------------+--------+
114 rows in set (0.01 sec)
```

##### String ranges

You can also build conditions that search for ranges in strings:

```sql
mysql> SELECT last_name, first_name
    -> FROM customer
    -> WHERE last_name BETWEEN 'FA' and 'FR';
+------------+------------+
| last_name  | first_name |
+------------+------------+
| FARNSWORTH | JOHN       |
| FENNELL    | ALEXANDER  |
| FERGUSON   | BERTHA     |
---
| FOUST      | JACK       |
| FOWLER     | JO         |
| FOX        | HOLLY      |
+------------+------------+
18 rows in set (0.00 sec)
```

There are five customers whose last names starts with 'FR'. They are not included in the result set since a name like 'FRANKLIN' is not between 'FA' and 'FR'. However, you can pick up four of the five customers by extending the right-hand range to 'FRB':

```sql
mysql> SELECT last_name, first_name
    -> FROM customer
    -> WHERE last_name BETWEEN 'FA' AND 'FRB';
+------------+------------+
| last_name  | first_name |
+------------+------------+
| FARNSWORTH | JOHN       |
| FENNELL    | ALEXANDER  |
| FERGUSON   | BERTHA     |
...
| FRANCISCO  | JOEL       |
| FRANKLIN   | BETH       |
| FRAZIER    | GLENDA     |
+------------+------------+
22 rows in set (0.00 sec)
```

To work with string ranges, you need to know the order of the characters within your character set. This order is called *collation*.

#### Membership Conditions (`in` Operator)

In some cases, you want to check whether an expression is a member of a set of values. 

```sql
mysql> SELECT title, rating
    -> FROM film
    -> WHERE rating IN ('G', 'PG');
```

##### Using subqueries

You can use a subquery to generate a set for you on the fly:

```sql
mysql> SELECT title, rating
    -> FROM film
    -> WHERE rating IN (SELECT rating FROM film WHERE title LIKE '%PET%');

+---------------------------+--------+
| title                     | rating |
+---------------------------+--------+
| ACADEMY DINOSAUR          | PG     |
| ACE GOLDFINGER            | G      |
| AFFAIR PREJUDICE          | G      |
...
| WORDS HUNTER              | PG     |
| WORST BANGER              | PG     |
| YOUNG LANGUAGE            | G      |
+---------------------------+--------+
372 rows in set (0.00 sec)
```

##### Using `not in`

You can also use the `not in` operator to check whether an expression is not a member of a set of values:

```sql
mysql> SELECT title, rating
    -> FROM film
    -> WHERE rating NOT IN ('PG-13', 'R', 'NC-17');

+---------------------------+--------+
| title                     | rating |
+---------------------------+--------+
| ACADEMY DINOSAUR          | PG     |
| ACE GOLDFINGER            | G      |
| AFFAIR PREJUDICE          | G      |
...
| WORDS HUNTER              | PG     |
| WORST BANGER              | PG     |
| YOUNG LANGUAGE            | G      |
+---------------------------+--------+
372 rows in set (0.00 sec)
```

#### Matching Conditions
