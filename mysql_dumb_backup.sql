/*
Title: My Sql Dumb Backup Script
Author: LBell
Version: 1.0
Lisence: MIT

This script creates a "dumb" backup of your given database. What do I mean
by dumb? This:
    - No auto-increment unique keys (those are copied as just plain INTs)
    - No Foreign Key constraints
    - No Unique Keys
    - No Stored Procedures
    - No Triggers
In short, all of the data in each table becomes just regular old "dumb" fields 
in dumb tables.

Why?

Well, I needed it to place a READ ONLY version of a complex DB in a shared
location. Because it's read only, there's no need to keep things constrained
with keys.  When I need to update that READ ONLY version, I just run this script
do a database dump, and import it to that shared server.

Enjoy.
*/


/*
Edit these values for the master database (that which you want copied) and the
backup database (the name of the database where you want to be output)
*/
SET @MASTER_DB = 'my_original_db';
SET @BACKUP_DB = 'my_dumb_db';

----------------------------------
-- DO NOT EDIT BELOW THIS POINT --
----------------------------------
DELIMITER $$

/*
Create convenince procedure to execute prepared queries
*/
DROP PROCEDURE IF EXISTS `ex_q`$$
CREATE PROCEDURE `ex_q`(IN my_statement TEXT )
BEGIN
  SET @my_query = my_statement;
  PREPARE stmt FROM @my_query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END $$

/*
Create Procedure to export all tables in a database into a 'dumb' backup 
database.
*/
DROP PROCEDURE IF EXISTS `dumb_structure_export` $$
CREATE PROCEDURE `dumb_structure_export`(
	IN master_db TEXT, 
    IN backup_db TEXT
)
BEGIN
    DECLARE my_total INT DEFAULT NULL;
    DECLARE my_counter INT DEFAULT 0;
    DECLARE my_curr_table TEXT DEFAULT NULL;

    DECLARE table_cursor CURSOR FOR    
        SELECT TABLE_NAME 
        FROM information_schema.tables ist 
        WHERE ist.table_schema = master_db;

    OPEN table_cursor;

    SELECT FOUND_ROWS() INTO my_total;

    table_cursor_loop: LOOP
        SET my_curr_table = NULL;

        IF my_counter >= my_total THEN
            CLOSE table_cursor;
            LEAVE table_cursor_loop;
        END IF;

        FETCH table_cursor INTO my_curr_table;
            SET my_counter = my_counter + 1;
            CALL ex_q(
                CONCAT(
                    'CREATE TABLE ', backup_db, '.', my_curr_table,
                    ' SELECT * FROM ', master_db, '.', my_curr_table
                )
            );
    END LOOP;

END $$

DELIMITER ;

-- Drop and create the backup Database
CALL ex_q(CONCAT('DROP DATABASE IF EXISTS ', @BACKUP_DB));
CALL ex_q(CONCAT('CREATE DATABASE ', @BACKUP_DB));
-- Copy the master into the dumb backup
CALL dumb_structure_export(@MASTER_DB, @BACKUP_DB);
