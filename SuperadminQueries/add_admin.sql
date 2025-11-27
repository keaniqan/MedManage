-- Procedure to create a new admin user. Since admins belongs to a specific institute the name of 
-- the institute needs to be passed in. If the institute does not exist, an exception will be raised.
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
    IN p_InstituteName VARCHAR(255),
)BEGIN
    DECLARE v_InstituteID INT;

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
        Identification, Gender, InstituteID)
    VALUES (
        p_Username, p_Email, 'admin',
        p_FirstName, p_LastName, p_Phone, SHA2(p_Password),
        p_Identification, p_Gender, v_InstituteID
    ); 
    -- Updating log to keep track of changes
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddAdmin(',
            QUOTE(p_Username), ', ',QUOTE(p_Email), ', ',
            QUOTE(p_FirstName), ', ',QUOTE(p_LastName), ', ',QUOTE(p_Phone), ', ',QUOTE(p_Password), ', ',
            QUOTE(p_Identification), ', ',QUOTE(p_Gender), ', ',QUOTE(p_InstituteName),')'
        )
    );
END;