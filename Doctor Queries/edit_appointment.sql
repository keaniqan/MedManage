USE medmanagedb;

DROP PROCEDURE IF EXISTS EditAppointment;

DELIMITER //

CREATE PROCEDURE EditAppointment(
    IN p_AppointmentId INT,
	IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    SET @sql = CONCAT('UPDATE Appointment SET ', p_FieldName, ' = ? WHERE AppointmentId = ?');
    PREPARE stmt FROM @sql;
    SET @NewValue = p_NewValue;
    SET @AppointmentId = p_AppointmentID;
    EXECUTE stmt USING @NewValue, @AppointmentId;
    DEALLOCATE PREPARE stmt;

    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'Appointment',
        CONCAT('CALL EditAppointment(', p_AppointmentId, ', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
END //

-- Usage examples below
-- Edit PatientUserID
-- CALL EditAppointment(1, 'PatientUserID', '5');

-- Edit Details
-- CALL EditAppointment(1, 'Details', 'Blood test');