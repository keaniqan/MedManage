-- Removed an admin from the user table based on the provided admin username. Remove
-- his/her mysql login credentials and log the deletion action.
DROP PROCEDURE IF EXISTS DeactivateAdmin;
CREATE PROCEDURE DeactivateAdmin(
    IN p_AdminUsername VARCHAR(50)
)BEGIN
    START TRANSACTION;
    -- Throw an error if admin user by that name does not exist
    IF NOT EXISTS (
        SELECT 1 FROM Users WHERE Username = p_AdminUsername AND UserType = 'admin'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Admin user not found';
    END IF;

    -- Delete the admin from the User table
    UPDATE `Users` SET `DeletedOn` = NOW() WHERE `Username` = p_AdminUsername AND `UserType` = 'admin';

    -- Drop the MySQL user if it exists
    SET @dropUserQuery = CONCAT('DROP USER IF EXISTS \'', p_AdminUsername, '\'@\'%\';');
    PREPARE stmt FROM @dropUserQuery;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Log the deletion action
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'DELETE',
        'User',
        CONCAT('CALL DeleteAdmin(''', p_AdminUsername, ''');')
    );
    COMMIT;
END;

CALL DeleteAdmin('JohnAdmin');