USE medmanagedb;

DROP PROCEDURE IF EXISTS UpdateDoctor;

CREATE PROCEDURE UpdateDoctor(
    IN p_UserID INT,
    IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    SET @sql = CONCAT('UPDATE users SET ', p_FieldName, ' = ? WHERE UserID = ? AND UserType = ''doctor''');
    PREPARE stmt FROM @sql;
    SET @newValue = p_NewValue;
    SET @userId = p_UserID;
    EXECUTE stmt USING @newValue, @userId;
    DEALLOCATE PREPARE stmt;

    INSERT INTO user_action_log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'users',
        CONCAT('CALL UpdateDoctor(', p_UserID, ', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
END;

-- Example calls (run these separately after creating the procedure):
-- Update FirstName
CALL UpdateDoctor(1, 'FirstName', 'Brian');
CALL UpdateDoctor(1, 'FirstName', 'Steve');
-- 
-- Update LastName
CALL UpdateDoctor(1, 'LastName', 'Smith');
CALL UpdateDoctor(1, 'LastName', 'Johnson');
-- 
-- Update Email
CALL UpdateDoctor(1, 'Email', 'brian@example.com');
CALL UpdateDoctor(1, 'Email', 'steve@example.com');