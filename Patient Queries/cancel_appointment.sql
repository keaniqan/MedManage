USE medmanagedb;

DROP PROCEDURE IF EXISTS CancelAppointment;

DELIMITER //

CREATE PROCEDURE CancelAppointment(
    IN p_PatientUserID INT,
    IN p_AppointmentID INT
)
BEGIN
    DECLARE v_OwnerUserID INT;

    -- Check that appointment belongs to this patient
    SELECT PatientUserID INTO v_OwnerUserID
    FROM Appointment
    WHERE AppointmentID = p_AppointmentID;

    IF v_OwnerUserID != p_PatientUserID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment does not belong to this patient';
    END IF;

    -- Cancel the appointment by setting IsPatientAccept to 0
    UPDATE Appointment
    SET IsPatientAccept = 0
    WHERE AppointmentID = p_AppointmentID;

    -- Delete associated reminders
    DELETE FROM Reminder
    WHERE AppointmentID = p_AppointmentID;

    -- Log the action
    INSERT INTO Log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'UPDATE',
        'Appointment',
        CONCAT('CALL CancelAppointment(', p_PatientUserID, ', ', p_AppointmentID, ');'),
        (SELECT Username FROM Users WHERE UserID = p_PatientUserID)
    );

    SELECT 'Appointment cancelled successfully' AS Message;
END //

DELIMITER ;

-- CALL CancelAppointment(1, 5);