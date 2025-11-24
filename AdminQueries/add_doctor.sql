set FOREIGN_KEY_CHECKS=0;
use medmanagedb;
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

    SET v_UserID = LAST_INSERT_ID();

    INSERT INTO doctordetails (
        UserID, Specialist, MedicalLicenceNumber, YearsOfExperience,
        MedicalSchool, Certificates, LanguagesSpoken
    ) VALUES (
        v_UserID, p_Specialization, p_MedicalLicenceNumber, p_YearsOfExperience,
        p_MedicalSchool, p_Certificates, p_LanguagesSpoken
    );

    -- Create MySQL account (requires proper privileges; remove if not needed)
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

     -- Grant privileges on doctordetails as well
    SET @grant_sql2 = CONCAT(
        'GRANT SELECT, INSERT, UPDATE ON `medmanagedb`.`doctordetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt3 FROM @grant_sql2;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    FLUSH PRIVILEGES;

    INSERT INTO user_action_log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddDoctor(''', p_Username, ''',''', p_Email, ''',''', 
               p_FirstName, ''',''', p_LastName, ''',''', p_Phone, ''',''',
               p_Password, ''',''', p_Identification, ''',''', p_Gender, ''',',
               p_InstituteID, ');')
    );
END;


