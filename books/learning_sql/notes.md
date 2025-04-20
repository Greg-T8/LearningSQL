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
