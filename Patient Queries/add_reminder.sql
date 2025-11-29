Use medmanagedb;
DROP PROCEDURE IF EXISTS AddPatientReminder;

DELIMITER //

CREATE PROCEDURE AddPatientReminder(
    IN p_PatientUserID INT,
    IN p_StartOn DATETIME,
    IN p_EndOn DATETIME,
    IN p_IntervalMinutes INT,
    IN p_PrescriptionDetailID INT,
    IN p_AppointmentID INT
)
BEGIN
    DECLARE v_PatientDetailsID INT;

    -- Get the PatientDetailsID for the given UserID
    SELECT PatientDetailsID INTO v_PatientDetailsID
    FROM PatientDetails
    WHERE UserID = p_PatientUserID;

    -- Insert the reminder
    INSERT INTO Reminder (StartOn, EndOn, IntervalMinutes, PrescriptionDetailID, AppointmentID)
    VALUES (p_StartOn, p_EndOn, p_IntervalMinutes, p_PrescriptionDetailID, p_AppointmentID);

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'INSERT',
        'Reminder',
        CONCAT('CALL AddPatientReminder(', p_PatientUserID, ', ''', p_StartOn, ''', ''', 
               p_EndOn, ''', ', p_IntervalMinutes, ', ', p_PrescriptionDetailID, ', ', 
               p_AppointmentID, ');'),
        (SELECT Username FROM Users WHERE UserID = p_PatientUserID)
    );

    -- Return the inserted ReminderID
    SELECT LAST_INSERT_ID() AS ReminderID;
END //

DELIMITER ;

-- CALL AddPatientReminder(1, '2024-07-01 09:00:00', '2024-07-10 09:00:00', 240, 5, NULL); -- Example call to the procedure for prescription reminder
-- CALL AddPatientReminder(1, '2024-07-15 10:00 :00', '2024-07-15 11:00:00', 0, NULL, 3); -- Example call to the procedure for appointment reminder