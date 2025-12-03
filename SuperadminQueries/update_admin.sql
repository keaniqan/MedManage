DROP PROCEDURE IF EXISTS UpdateAdmin;
CREATE PROCEDURE UpdateAdmin(
    IN p_AdminID INT,
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255)
)BEGIN
    -- Update an existing admin's details. 
    UPDATE users
    SET
        Email = p_Email,
        FirstName = p_FirstName,
        LastName = p_LastName,
        Phone = p_Phone,
        PasswordHash = SHA2(p_Password, 256)
    WHERE UserID = p_AdminID AND UserType = 'admin';

    -- Updating user action log to keep track of changes
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'users',
        CONCAT('CALL UpdateAdmin(',
            p_AdminID, ', ', QUOTE(p_Email), ', ',
            QUOTE(p_FirstName), ', ', QUOTE(p_LastName), ', ',
            QUOTE(p_Phone), ', ', QUOTE(p_Password), ')'
        )
    );
END;

CALL UpdateAdmin(
    2,                          -- AdminID
    'NewEmail@mail.com',        -- Email
    'NewFirstName',             -- FirstName
    'NewLastName',              -- LastName
    '0123456789',               -- Phone
    'NewSecurePassword'         -- Password
);