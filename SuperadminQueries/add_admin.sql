-- Procedure 1: Insert admin data with transaction control
DROP PROCEDURE IF EXISTS AddAdminData;
CREATE PROCEDURE AddAdminData(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteName VARCHAR(255),
    OUT p_UserID INT,
    OUT p_Success BOOLEAN
)
BEGIN
    DECLARE v_InstituteID INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Success = FALSE;
        SET p_UserID = NULL;
    END;
    
    START TRANSACTION;
    
    -- Retrieve the InstituteID based on the provided InstituteName
    SELECT InstituteID INTO v_InstituteID
    FROM institutes
    WHERE InstituteName = p_InstituteName;

    -- If no institute is found, raise an error
    IF v_InstituteID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Institute not found';
    END IF;

    INSERT INTO users (
        Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender, InstituteID
    ) VALUES (
        p_Username, p_Email, 'admin',
        p_FirstName, p_LastName, p_Phone, SHA2(p_Password, 256),
        p_Identification, p_Gender, v_InstituteID
    );
    
    SET p_UserID = LAST_INSERT_ID();

    -- Updating log to keep track of changes
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddAdmin(',
            QUOTE(p_Username), ', ', QUOTE(p_Email), ', ',
            QUOTE(p_FirstName), ', ', QUOTE(p_LastName), ', ', QUOTE(p_Phone), ', ', QUOTE(p_Password), ', ',
            QUOTE(p_Identification), ', ', QUOTE(p_Gender), ', ', QUOTE(p_InstituteName), ')'
        )
    );
    
    COMMIT;
    SET p_Success = TRUE;
END;

-- Procedure 2: Create MySQL account (only if data insert succeeded)
DROP PROCEDURE IF EXISTS CreateAdminMySQLAccount;
CREATE PROCEDURE CreateAdminMySQLAccount(
    IN p_Username VARCHAR(100),
    IN p_Password VARCHAR(255)
)
BEGIN
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

    FLUSH PRIVILEGES;
END;

-- Main Procedure: Orchestrates both operations
DROP PROCEDURE IF EXISTS AddAdmin;
CREATE PROCEDURE AddAdmin(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteName VARCHAR(255)
)
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success BOOLEAN DEFAULT FALSE;
    
    -- Step 1: Insert data with transaction protection
    CALL AddAdminData(
        p_Username, p_Email, p_FirstName, p_LastName,
        p_Phone, p_Password, p_Identification, p_Gender,
        p_InstituteName, v_UserID, v_Success
    );
    
    -- Step 2: Only create MySQL account if data insert succeeded
    IF v_Success THEN
        CALL CreateAdminMySQLAccount(p_Username, p_Password);
        SELECT v_UserID AS UserID, 'Admin added successfully with MySQL account' AS Message;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Failed to add admin data. MySQL account not created.';
    END IF;
END;