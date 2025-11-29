Use medmanagedb;

DROP PROCEDURE IF EXISTS UpdatePatient;

DELIMITER //

CREATE PROCEDURE UpdatePatient(
    IN p_UserID INT,
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(255),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(25),
    IN p_Identification VARCHAR(20)
)
BEGIN
    -- Update patient info
    UPDATE Users
    SET
        Username = p_Username,
        Email = p_Email,
        FirstName = p_FirstName,
        LastName = p_LastName,
        Phone = p_Phone,
        Identification = p_Identification
    WHERE UserID = p_UserID AND UserType = 'patient';

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'UPDATE',
        'Users',
        CONCAT(
            'CALL UpdatePatient(',
            p_UserID, ', ''', p_Username, ''', ''', p_Email, ''', ''', 
            p_FirstName, ''', ''', p_LastName, ''', ''', p_Phone, ''', ''', 
            p_Identification, ''');'
        ),
        (SELECT Username FROM Users WHERE UserID = p_UserID)
    );
END //

DELIMITER ;

-- CALL UpdatePatient(5,'newusername', 'newemail@example.com', 'John', 'Doe', '+1234567890', 'ID987654321');
