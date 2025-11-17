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
    IN p_InstituteID SMALLINT
)

BEGIN
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

    FLUSH PRIVILEGES;
END;

CALL AddDoctor('doc4','dr.jones@example.com','Sarah','Jones','0123456789','doc1','IC1234567','F',1);
CALL AddDoctor('doc3','dr.smith@example.com','John','Smith','0987654321','doc2','IC7654321','M',1);
 
