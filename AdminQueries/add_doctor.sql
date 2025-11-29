set FOREIGN_KEY_CHECKS=0;
use medmanagedb;

-- Procedure 1: Insert doctor data with transaction control
DROP PROCEDURE IF EXISTS AddDoctorData;
CREATE PROCEDURE AddDoctorData(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_Specialization VARCHAR(100),
    IN p_MedicalLicenceNumber VARCHAR(50),
    IN p_YearsOfExperience INT,
    IN p_MedicalSchool VARCHAR(100),
    IN p_Certificates VARCHAR(100),
    IN p_LanguagesSpoken JSON,
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
        p_Username, p_Email, 'doctor',
        p_FirstName, p_LastName, p_Phone,
        SHA2(p_Password, 256),
        p_Identification, p_Gender, p_InstituteID
    );

    SET p_UserID = LAST_INSERT_ID();

    INSERT INTO doctordetails (
        UserID, Specialist, MedicalLicenceNumber, YearsOfExperience,
        MedicalSchool, Certificates, LanguagesSpoken
    ) VALUES (
        p_UserID, p_Specialization, p_MedicalLicenceNumber, p_YearsOfExperience,
        p_MedicalSchool, p_Certificates, p_LanguagesSpoken
    );

    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddDoctor(''', p_Username, ''',''', p_Email, ''',''', 
               p_FirstName, ''',''', p_LastName, ''',''', p_Phone, ''',''',
               p_Password, ''',''', p_Identification, ''',''', p_Gender, ''',',
               p_InstituteID, ');')
    );
    
    COMMIT;
    SET p_Success = TRUE;
END;

-- Procedure 2: Create MySQL account (only if data insert succeeded)
DROP PROCEDURE IF EXISTS CreateDoctorMySQLAccount;
CREATE PROCEDURE CreateDoctorMySQLAccount(
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

    SET @grant_sql2 = CONCAT(
        'GRANT SELECT, INSERT, UPDATE ON `medmanagedb`.`doctordetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt3 FROM @grant_sql2;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    FLUSH PRIVILEGES;
END;

-- Main Procedure: Orchestrates both operations
DROP PROCEDURE IF EXISTS AddDoctor;
CREATE PROCEDURE AddDoctor(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_Specialization VARCHAR(100),
    IN p_MedicalLicenceNumber VARCHAR(50),
    IN p_YearsOfExperience INT,
    IN p_MedicalSchool VARCHAR(100),
    IN p_Certificates VARCHAR(100),
    IN p_LanguagesSpoken JSON
)
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success BOOLEAN DEFAULT FALSE;
    
    -- Step 1: Insert data with transaction protection
    CALL AddDoctorData(
        p_Username, p_Email, p_FirstName, p_LastName,
        p_Phone, p_Password, p_Identification, p_Gender,
        p_InstituteID, p_Specialization, p_MedicalLicenceNumber,
        p_YearsOfExperience, p_MedicalSchool, p_Certificates,
        p_LanguagesSpoken, v_UserID, v_Success
    );
    
    -- Step 2: Only create MySQL account if data insert succeeded
    IF v_Success THEN
        CALL CreateDoctorMySQLAccount(p_Username, p_Password);
        SELECT v_UserID AS UserID, 'Doctor added successfully with MySQL account' AS Message;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Failed to add doctor data. MySQL account not created.';
    END IF;
END;

-- Test the procedure
-- CALL AddDoctor('doc7','dr.smith@example.com','John','Smith','0987654321','doc7','IC7654321','M',1,'Cardiology','ML123456',10,'Harvard Medical School','Board Certified','["English", "Malay"]');

CREATE USER IF NOT EXISTS 'doc7'@'localhost' IDENTIFIED BY 'doc7';
GRANT SELECT, INSERT, UPDATE ON medmanagedb.users TO 'doc7'@'localhost';
GRANT SELECT, INSERT, UPDATE ON medmanagedb.doctordetails TO 'doc7'@'localhost';
FLUSH PRIVILEGES;