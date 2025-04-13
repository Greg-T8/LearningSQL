# My notes from "Learning SQL" by Alan Beaulieu

<img src='images/1744531821624.png' width='254'/>

## Book Resources
- [Example MySQL Databases](https://dev.mysql.com/doc/index-other.html)

## Helpful Commands

```bash
mysql -u <username> -p              -- login to mysql
mysql -u <username> -p <database>   -- login to mysql and use a specific database
```

```sql
-- General SQL statements
mysql> show databases;                     -- show all databases
mysql> use <database>;                     -- use a specific database
```


## Chapter 2: Creating and Populating a Database

### MySQL Data Types

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

There are four types of text data:
- `tinytext` - 255 bytes
- `text` - 65,535 bytes
- `mediumtext` - 16,777,215 bytes
- `longtext` - 4,294,967,295 bytes

Things to remember:
- If data being loaded is larger than the maximum size of the column, it will be truncated.
- Trailing spaces are not removed
- When using `text` columns for sorting or grouping, only the first 1,024 bytes are used
- The different text types above are unique to MySQL. SQL Server has a single text type for large character data
- MySQL allows up to 65,535 bytes for `varchar` columns (it was limited to 255 bytes in earlier versions), so there isn't any particular need to use the `tinytext` or `text` types.
