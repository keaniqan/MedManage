-- Removed an Superadmin from the user table based on the provided admin username. Remove
-- his/her mysql login credentials and log the deletion action.
DROP PROCEDURE IF EXISTS DeactivateSuperAdmin;
CREATE PROCEDURE DeactivateSuperAdmin(
    IN p_SuperAdminUsername VARCHAR(50)
)BEGIN
    START TRANSACTION;
    -- Throw an error if admin user by that name does not exist
    IF NOT EXISTS (
        SELECT 1 FROM Users WHERE Username = p_SuperAdminUsername AND UserType = 'superadmin'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SuperAdmin user not found';
    END IF;

    -- Delete the admin from the User table
    UPDATE `Users` SET `DeletedOn` = NOW() WHERE `Username` = p_SuperAdminUsername AND `UserType` = 'superadmin';

    -- Drop the MySQL user if it exists
    SET @dropUserQuery = CONCAT('DROP USER IF EXISTS \'', p_SuperAdminUsername, '\'@\'%\';');
    PREPARE stmt FROM @dropUserQuery;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Log the deletion action
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'DELETE',
        'User',
        CONCAT('CALL DeactivateSuperadmin(''', p_SuperAdminUsername, ''');')
    );
    COMMIT;
END;

CALL DeactivateSuperAdmin('Chong');