USE medmanagedb;

-- Procedure 1: Insert patient data with transaction control
DROP PROCEDURE IF EXISTS AddPatientData;
CREATE PROCEDURE AddPatientData(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(255),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(25),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_ABOBloodType ENUM('A','B','AB','O'),
    IN p_RhBloodType ENUM('+','-'),
    IN p_EmergencyContact VARCHAR(20),
    IN p_DOB DATE,
    OUT p_UserID INT,
    OUT p_Success BOOLEAN
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Success = FALSE;
        SET p_UserID = NULL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO users (
        Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender, InstituteID
    ) VALUES (
        p_Username, p_Email, 'patient',
        p_FirstName, p_LastName, p_Phone,
        SHA2(p_Password, 256),
        p_Identification, p_Gender, p_InstituteID
    );

    SET p_UserID = LAST_INSERT_ID();

    INSERT INTO patientdetails (
        UserID, ABOBloodType, RhBloodType, EmergencyContact, DOB
    ) VALUES (
        p_UserID, p_ABOBloodType, p_RhBloodType, p_EmergencyContact, p_DOB
    );

    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddPatient(''', p_Username, ''',''', p_Email, ''',''', 
               p_FirstName, ''',''', p_LastName, ''',''', p_Phone, ''',''',
               p_Password, ''',''', p_Identification, ''',''', p_Gender, ''',',
               p_InstituteID, ',''', p_ABOBloodType, ''',''', p_RhBloodType, ''',''',
               p_EmergencyContact, ''',''', p_DOB, ''');')
    );
    
    COMMIT;
    SET p_Success = TRUE;
END;

-- Procedure 2: Create MySQL account (only if data insert succeeded)
DROP PROCEDURE IF EXISTS CreatePatientMySQLAccount;
CREATE PROCEDURE CreatePatientMySQLAccount(
    IN p_Username VARCHAR(100),
    IN p_Password VARCHAR(255)
)
BEGIN
    -- Create MySQL account
    SET @create_sql = CONCAT(
        'CREATE USER IF NOT EXISTS `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost` IDENTIFIED BY ', QUOTE(p_Password), ';'
    );
    PREPARE stmt1 FROM @create_sql;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- Grant SELECT and UPDATE on users table (so they can edit their own user info)
    SET @grant_sql = CONCAT(
        'GRANT SELECT, UPDATE ON `medmanagedb`.`users` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt2 FROM @grant_sql;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    -- View their patient details (READ ONLY - cannot change blood type, DOB, etc.)
    SET @grant_sql2 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`patientdetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt3 FROM @grant_sql2;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    -- View their prescriptions (READ ONLY)
    SET @grant_sql3 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`prescription` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt4 FROM @grant_sql3;
    EXECUTE stmt4;
    DEALLOCATE PREPARE stmt4;

    -- View prescription details (READ ONLY)
    SET @grant_sql4 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`prescriptiondetail` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt5 FROM @grant_sql4;
    EXECUTE stmt5;
    DEALLOCATE PREPARE stmt5;

    -- View appointments (READ ONLY)
    SET @grant_sql5 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`appointment` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt6 FROM @grant_sql5;
    EXECUTE stmt6;
    DEALLOCATE PREPARE stmt6;

    -- View medicine information (READ ONLY)
    SET @grant_sql6 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`medicine` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt7 FROM @grant_sql6;
    EXECUTE stmt7;
    DEALLOCATE PREPARE stmt7;

    -- View compliance (their medication tracking) - READ ONLY
    SET @grant_sql7 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`compliance` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt8 FROM @grant_sql7;
    EXECUTE stmt8;
    DEALLOCATE PREPARE stmt8;

    -- View reminders (READ ONLY)
    SET @grant_sql8 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`reminder` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt9 FROM @grant_sql8;
    EXECUTE stmt9;
    DEALLOCATE PREPARE stmt9;

    -- View doctor details (to see their doctor's info) - READ ONLY
    SET @grant_sql9 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`doctordetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt10 FROM @grant_sql9;
    EXECUTE stmt10;
    DEALLOCATE PREPARE stmt10;

    FLUSH PRIVILEGES;
END;

-- Main Procedure: Orchestrates both operations
DROP PROCEDURE IF EXISTS AddPatient;
CREATE PROCEDURE AddPatient(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(255),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(25),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_ABOBloodType ENUM('A','B','AB','O'),
    IN p_RhBloodType ENUM('+','-'),
    IN p_EmergencyContact VARCHAR(20),
    IN p_DOB DATE
)
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success BOOLEAN DEFAULT FALSE;
    
    -- Step 1: Insert data with transaction protection
    CALL AddPatientData(
        p_Username, p_Email, p_FirstName, p_LastName,
        p_Phone, p_Password, p_Identification, p_Gender,
        p_InstituteID, p_ABOBloodType, p_RhBloodType,
        p_EmergencyContact, p_DOB, v_UserID, v_Success
    );
    
    -- Step 2: Only create MySQL account if data insert succeeded
    IF v_Success THEN
        CALL CreatePatientMySQLAccount(p_Username, p_Password);
        SELECT v_UserID AS UserID, 'Patient added successfully with MySQL account' AS Message;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Failed to add patient data. MySQL account not created.';
    END IF;
END;