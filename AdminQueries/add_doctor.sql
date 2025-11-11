DELIMITER //

CREATE PROCEDURE AddDoctor(
    IN p_UserID INT,
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(20),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender ENUM('M','F'),
    IN p_InstituteID SMALLINT
)
BEGIN
    INSERT INTO users (
        UserID, Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender, InstituteID
    ) VALUES (
        p_UserID, p_Username, p_Email, 'doctor',
        p_FirstName, p_LastName, p_Phone,
        SHA2(p_Password, 256),
        p_Identification, p_Gender, p_InstituteID
    );

    SET @sql1 = CONCAT('CREATE USER \'', p_Username, '\'@\'localhost\' IDENTIFIED BY \'', p_Password, '\';');
    PREPARE stmt1 FROM @sql1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;

    SET @sql2 = CONCAT('GRANT SELECT, INSERT, UPDATE ON medmanagedb.users TO \'', p_Username, '\'@\'localhost\';');
    PREPARE stmt2 FROM @sql2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

    FLUSH PRIVILEGES;
END //

DELIMITER ;

CALL AddDoctor(1, 'doc1', 'dr.jones@example.com', 'Sarah', 'Jones', '0123456789', 'doc1', 'IC1234567', 'F', 1);
