USE medmanagedb;

DROP PROCEDURE IF EXISTS DeleteDoctor;

CREATE PROCEDURE DeleteDoctor(
    IN p_UserID INT
)
BEGIN
    DECLARE v_Username VARCHAR(100);

    -- Get the doctor's username (only if the user is a doctor)
    SELECT Username INTO v_Username 
    FROM users
    WHERE UserID = p_UserID AND UserType = 'doctor';

    -- Delete user only if it exists and is a doctor
    SET @sql = 'DELETE FROM users WHERE UserID = ? AND UserType = ''doctor''';
    PREPARE stmt FROM @sql;
    SET @userId = p_UserID;
    EXECUTE stmt USING @userId;
    DEALLOCATE PREPARE stmt;

    -- Drop the MySQL login if the username exists
    IF v_Username IS NOT NULL THEN
        SET @drop_sql = CONCAT('DROP USER IF EXISTS `', REPLACE(v_Username,'`','``'), '`@''localhost'';');
        PREPARE stmt2 FROM @drop_sql;
        EXECUTE stmt2;
        DEALLOCATE PREPARE stmt2;
    END IF;

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'DROP',
        'users',
        CONCAT('CALL DeleteDoctor(', p_UserID, ');')
    );
END;

-- Example call (run this separately after creating the procedure):
CALL DeleteDoctor(2);