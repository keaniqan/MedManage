USE medmanagedb;

DROP PROCEDURE IF EXISTS EditAppointment;
CREATE PROCEDURE EditAppointment(
    IN p_AppointmentId INT,
	IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    -- Update the apppintment table with the new values
    SET @sql = CONCAT('UPDATE Appointment SET ', p_FieldName, ' = ? WHERE AppointmentId = ?');
    PREPARE stmt FROM @sql;
    SET @NewValue = p_NewValue;
    SET @AppointmentId = p_AppointmentID;
    EXECUTE stmt USING @NewValue, @AppointmentId;
    DEALLOCATE PREPARE stmt;

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'Appointment',
        CONCAT('CALL EditAppointment(', p_AppointmentId, ', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
END 

-- Usage examples below
-- Edit ispatientaccepted
-- CALL EditAppointment(1, 'ispatientaccepted', '1');