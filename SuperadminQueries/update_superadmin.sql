DROP PROCEDURE IF EXISTS UpdateSuperadmin;
CREATE PROCEDURE UpdateSuperadmin(
    IN p_SuperadminID INT,
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255)
)BEGIN
    -- Update an existing superadmin's details
    UPDATE users
    SET
        Email = p_Email,
        FirstName = p_FirstName,
        LastName = p_LastName,
        Phone = p_Phone,
        PasswordHash = SHA2(p_Password, 256)
    WHERE UserID = p_SuperadminID AND UserType = 'superadmin';

    -- Updating user action log to keep track of changes
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'users',
        CONCAT('CALL UpdateSuperadmin(',
            p_SuperadminID, ', ', QUOTE(p_Email), ', ',
            QUOTE(p_FirstName), ', ', QUOTE(p_LastName), ', ',
            QUOTE(p_Phone), ', ', QUOTE(p_Password), ')'
        )
    );
END;

CALL UpdateSuperadmin(
    1,                          -- SuperadminID
    'NewEmail@mail.com',        -- Email
    'NewFirstName',             -- FirstName
    'NewLastName',              -- LastName
    '0123456789',               -- Phone
    'NewSecurePassword'         -- Password
);