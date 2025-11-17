USE medmanagedb;

DROP PROCEDURE IF EXISTS DeleteDoctor;

CREATE PROCEDURE DeleteDoctor(
    IN p_UserID INT
)
BEGIN
    SET @sql = CONCAT('DELETE FROM users WHERE UserID = ? AND UserType = ''doctor''');
    PREPARE stmt FROM @sql;
    SET @userId = p_UserID;
    EXECUTE stmt USING @userId;
    DEALLOCATE PREPARE stmt;

    INSERT INTO user_action_log (ActionType, TableName, Query)
    VALUES (
        'DROP',
        'users',
        CONCAT('CALL DeleteDoctor(', p_UserID, ');')
    );
END;

-- Example call (run this separately after creating the procedure):
CALL DeleteDoctor(2);