USE medmanagedb;

DROP PROCEDURE IF EXISTS DeleteDoctor;

CREATE PROCEDURE DeleteDoctor(
    IN p_UserID INT
)
BEGIN
    DECLARE v_Username VARCHAR(100);
    
    START TRANSACTION;
    
    -- Throw an error if doctor user by that ID does not exist
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE UserID = p_UserID AND UserType = 'doctor'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor user not found';
    END IF;

    -- Get the doctor's username
    SELECT Username INTO v_Username 
    FROM users
    WHERE UserID = p_UserID AND UserType = 'doctor';

    -- Soft delete the doctor from the User table
    UPDATE users SET DeletedOn = NOW() WHERE UserID = p_UserID AND UserType = 'doctor';

    -- Drop the MySQL user if it exists
    IF v_Username IS NOT NULL THEN
        SET @dropUserQuery = CONCAT('DROP USER IF EXISTS \'', v_Username, '\'@\'%\';');
        PREPARE stmt FROM @dropUserQuery;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;

    -- Log the deletion action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'DROP',
        'users',
        CONCAT('CALL DeleteDoctor(', p_UserID, ');')
    );
    
    COMMIT;
END;

-- Example call (run this separately after creating the procedure):
CALL DeleteDoctor(2);