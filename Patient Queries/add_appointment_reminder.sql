USE medmanagedb;
DROP PROCEDURE IF EXISTS AddAppointmentReminder;
DELIMITER //

CREATE PROCEDURE AddAppointmentReminder(
    IN p_StartOn DATETIME,
    IN p_EndOn DATETIME,
    IN p_IntervalMinutes INT,
    IN p_AppointmentID INT
)
BEGIN
    -- Insert the reminder
    INSERT INTO Reminder (StartOn, EndOn, IntervalMinutes, AppointmentID)
    VALUES (p_StartOn, p_EndOn, p_IntervalMinutes, p_AppointmentID);

    -- Simple log entry
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'INSERT',
        'Reminder',
        CONCAT(
            'Auto appointment reminder created for AppointmentID = ',
            p_AppointmentID
        ),
        'SYSTEM'
    );
END //

DELIMITER ;

-- CALL AddAppointmentReminder('2024-07-15 10:00:00', '2024-07-15 11:00:00', 0, 3); -- Example call to the procedure for appointment reminder 
-- CALL AddAppointmentReminder('2024-07-01 09:00:00', '2024-07-10 09:00:00', 240, 5); -- Example call to the procedure for appointment reminder