USE medmanagedb;

DROP PROCEDURE IF EXISTS UpdateDoctor;

CREATE PROCEDURE UpdateDoctor(
    IN p_UserID INT,
    IN p_TableName VARCHAR(50),
    IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    START TRANSACTION;
    
    -- Check if doctor exists
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE UserID = p_UserID AND UserType = 'doctor'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor user not found';
    END IF;
    
    -- Update the specified table
    IF p_TableName = 'users' THEN
        SET @sql = CONCAT('UPDATE users SET ', p_FieldName, ' = ? WHERE UserID = ? AND UserType = ''doctor''');
    ELSEIF p_TableName = 'doctordetails' THEN
        SET @sql = CONCAT('UPDATE doctordetails SET ', p_FieldName, ' = ? WHERE DoctorID = ?');
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid table name. Use ''users'' or ''doctordetails''';
    END IF;
    
    PREPARE stmt FROM @sql;
    SET @newValue = p_NewValue;
    SET @userId = p_UserID;
    EXECUTE stmt USING @newValue, @userId;
    DEALLOCATE PREPARE stmt;

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        p_TableName,
        CONCAT('CALL UpdateDoctor(', p_UserID, ', ''', p_TableName, ''', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
    
    COMMIT;
END;

-- Example calls (run these separately after creating the procedure):
-- Update users table fields
CALL UpdateDoctor(1, 'users', 'FirstName', 'Brian');
CALL UpdateDoctor(1, 'users', 'LastName', 'Smith');
CALL UpdateDoctor(1, 'users', 'Email', 'brian@example.com');
-- 
-- Update doctordetails table fields
CALL UpdateDoctor(1, 'doctordetails', 'Specialization', 'Cardiology');
CALL UpdateDoctor(1, 'doctordetails', 'LicenseNumber', 'LIC123456');
CALL UpdateDoctor(1, 'doctordetails', 'YearsOfExperience', '10');
CALL UpdateDoctor(1, 'doctordetails', 'ContactNumber', '+60123456789');