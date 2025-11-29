USe medmanagedb;

DROP PROCEDURE IF EXISTS RequestAppointment;

DELIMITER //

CREATE PROCEDURE RequestAppointment(
    IN p_PatientUserID INT,
    IN p_DoctorUserID INT,
    IN p_AppointmentOn DATETIME,
    IN p_Details VARCHAR(500),
    IN p_ReminderStart DATETIME,
    IN p_ReminderEnd DATETIME,
    IN p_ReminderInterval INT
)
BEGIN
    DECLARE v_AppointmentID INT;

    -- Insert appointment (patient request)
    INSERT INTO Appointment (
        PatientUserID,
        DoctorUserID,
        AppointmentOn,
        Details,
        IsDoctorAccept,
        IsPatientAccept
    ) VALUES (
        p_PatientUserID,
        p_DoctorUserID,
        p_AppointmentOn,
        p_Details,
        NULL,
        1 -- Patient automatically accepts
    );

    SET v_AppointmentID = LAST_INSERT_ID();

    -- If reminder is provided, create it
    IF p_ReminderStart IS NOT NULL THEN
        INSERT INTO Reminder (
            StartOn,
            EndOn,
            IntervalMinutes,
            AppointmentID
        ) VALUES (
            p_ReminderStart,
            p_ReminderEnd,
            p_ReminderInterval,
            v_AppointmentID
        );
    END IF;

    -- Log the appointment creation
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'INSERT',
        'Appointment',
        CONCAT(
            'CALL RequestAppointment(', p_PatientUserID, ', ', p_DoctorUserID, ', ''',
            p_AppointmentOn, ''', ''', p_Details, ''', ''', p_ReminderStart, ''', ''',
            p_ReminderEnd, ''', ', p_ReminderInterval, ');'
        ),
        (SELECT Username FROM Users WHERE UserID = p_PatientUserID)
    );

    SELECT v_AppointmentID AS AppointmentID, 'Appointment requested successfully' AS Message;

END //

DELIMITER ;

-- CALL RequestAppointment(1, 3, '2024-07-20 14:00:00', 'Regular check-up', '2024-07-19 14:00:00', '2024-07-20 13:00:00', 1440); -- Example call to the procedure with reminder