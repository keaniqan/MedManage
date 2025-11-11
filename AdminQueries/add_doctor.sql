DELIMITER //
DROP PROCEDURE IF EXISTS AddDoctor;
CREATE PROCEDURE AddDoctor(
    IN p_UserID INT,
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
    -- Insert into app table
    INSERT INTO user (
        UserID, Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender, InstituteID
    ) VALUES (
        p_UserID, p_Username, p_Email, 'doctor',
        p_FirstName, p_LastName, p_Phone,
        SHA2(p_Password, 256),
        p_Identification, p_Gender, p_InstituteID
    );

    -- Build dynamic SQL for CREATE USER and GRANT
    SET @create_sql = CONCAT('CREATE USER IF NOT EXISTS \'', REPLACE(p_Username, '''', '\\'''), '\'@\'localhost\' IDENTIFIED BY \'', REPLACE(p_Password, '''', '\\'''), '\';');
    PREPARE stmt1 FROM @create_sql;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    SET @grant_sql = CONCAT('GRANT SELECT, INSERT, UPDATE ON medmanagedb.user TO \'', REPLACE(p_Username, '''', '\\'''), '\'@\'localhost\';');
    PREPARE stmt2 FROM @grant_sql;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    FLUSH PRIVILEGES;
END //

DELIMITER ;
