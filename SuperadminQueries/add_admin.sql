DROP PROCEDURE IF EXISTS AddAdmin;
CREATE PROCEDURE AddAdmin(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1)
)BEGIN
    INSERT INTO users (
        Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender,
        InstituteID)
    VALUES (
        p_Username, p_Email, 'admin',
        p_FirstName, p_LastName, p_Phone, SHA2(p_Password, 256),
        p_Identification, p_Gender,
        NULL
    );

    -- Create MySQL account (requires proper privileges; 
    SET @create_sql = CONCAT(
        'CREATE USER IF NOT EXISTS `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost` IDENTIFIED BY ', QUOTE(p_Password), ';'
    );
    PREPARE stmt1 FROM @create_sql;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    SET @grant_sql = CONCAT(
        'GRANT SELECT, INSERT, UPDATE ON `medmanagedb`.`users` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt2 FROM @grant_sql;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    -- Updating user action log to keep track of changes
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddAdmin(',
            QUOTE(p_Username), ', ',QUOTE(p_Email), ', ',
            QUOTE(p_FirstName), ', ',QUOTE(p_LastName), ', ',QUOTE(p_Phone), ', ',QUOTE(p_Password), ', ',
            QUOTE(p_Identification), ', ',QUOTE(p_Gender),')'
        )
    );
END;

-- Example call to add an admin user
CALL AddAdmin('SteveAdmin','admin@gmail.com','Steve','Smith','123-456-7890','AdminPass123','ID987654321','M');