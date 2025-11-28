USE medmanagedb;
DELIMITER //

DROP PROCEDURE IF EXISTS CreateAppointment//

CREATE PROCEDURE CreateAppointment(
    IN p_PatientUserID INT,
    IN p_DoctorUserID INT,
    IN p_AppointmentOn DATETIME,
    IN p_Details VARCHAR(500),
    IN p_IsDoctorAccept BOOLEAN,
    IN p_IsPatientAccept BOOLEAN
)
BEGIN
    INSERT INTO Appointment (PatientUserID, DoctorUserID, AppointmentOn, Details, IsDoctorAccept, IsPatientAccept)
    VALUES (p_PatientUserID, p_DoctorUserID, p_AppointmentOn, p_Details, p_IsDoctorAccept, p_IsPatientAccept);
    
    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'Appointment',
        CONCAT('CALL CreateAppointment(''', p_PatientUserID, ''', ''', p_DoctorUserID, ''', ''', p_AppointmentOn, ''', ''', p_Details, ''', ''', p_IsDoctorAccept, ''', ''', p_IsPatientAccept, ''');')
    );
    
    -- Return the newly created appointment
    SELECT LAST_INSERT_ID() AS AppointmentId;
END//

DELIMITER ;

-- To create appointment (example below)
-- CALL CreateAppointment('1', '1', '2025-01-01 69:67:96', 'Blood Check', '1', '1');