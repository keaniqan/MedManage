-- Create a new superadmin. Stored procedure is used to encapsulate the logic for creating a superadmin user.
DROP PROCEDURE IF EXISTS AddSuperadmin;
CREATE PROCEDURE AddSuperadmin(
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
        p_Username, p_Email, 'superadmin',
        p_FirstName, p_LastName, p_Phone, SHA2(p_Password, 256),
        p_Identification, p_Gender,
        NULL
    );

    -- Create MySQL account (requires proper privileges; remove if not needed)
    SET @create_sql = CONCAT('CREATE USER \'', p_Username, '\'@\'%\' IDENTIFIED BY \'', p_Password, '\';');
    PREPARE stmt FROM @create_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @grant_sql = CONCAT('GRANT ALL PRIVILEGES ON medmanagedb.* TO \'', p_Username, '\'@\'%\';');
    PREPARE stmt FROM @grant_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Updating user action log to keep track of changes
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddSuperadmin(',
            QUOTE(p_Username), ', ',QUOTE(p_Email), ', ',
            QUOTE(p_FirstName), ', ',QUOTE(p_LastName), ', ',QUOTE(p_Phone), ', ',QUOTE(p_Password), ', ',
            QUOTE(p_Identification), ', ',QUOTE(p_Gender),')'
        )
    );
END;

-- Example usage:
-- CALL AddSuperadmin('John','JohnDatabase@gmail.com','John','Database','+1234567890','SuperSecurePassword!','SA123456','M');
