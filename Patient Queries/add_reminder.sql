Use medmanagedb;
DROP PROCEDURE IF EXISTS AddPrescriptionReminder;

DELIMITER //

CREATE PROCEDURE AddPrescriptionReminder(
    IN p_PatientUserID INT,
    IN p_PrescriptionDetailID INT,
    IN p_StartOn DATETIME,
    IN p_EndOn DATETIME,
    IN p_IntervalMinutes INT
)
BEGIN
    DECLARE v_PatientDetailsID INT;
    DECLARE v_PrescriptionID INT;
    DECLARE v_OwnerUserID INT;

    -- Get the patient's PatientDetailsID
    SELECT PatientDetailsID INTO v_PatientDetailsID
    FROM PatientDetails
    WHERE UserID = p_PatientUserID;

    -- Get the PrescriptionID linked to this PrescriptionDetail
    SELECT PrescriptionID INTO v_PrescriptionID
    FROM PrescriptionDetail
    WHERE PrescriptionDetailID = p_PrescriptionDetailID;

    -- Get the owner of this prescription
    SELECT PatientUserID INTO v_OwnerUserID
    FROM Prescription
    WHERE PrescriptionID = v_PrescriptionID;

    -- Check if the prescription belongs to the patient
    IF v_OwnerUserID = p_PatientUserID THEN
        -- Insert the reminder
        INSERT INTO Reminder (StartOn, EndOn, IntervalMinutes, PrescriptionDetailID)
        VALUES (p_StartOn, p_EndOn, p_IntervalMinutes, p_PrescriptionDetailID);

        -- Log the action
        INSERT INTO log (ActionType, TableName, Query, PerformedBy)
        VALUES (
            'INSERT',
            'Reminder',
            CONCAT('CALL AddPrescriptionReminder(', p_PatientUserID, ', ', p_PrescriptionDetailID, ', ''', 
                   p_StartOn, ''', ''', p_EndOn, ''', ', p_IntervalMinutes, ');'),
            (SELECT Username FROM Users WHERE UserID = p_PatientUserID)
        );

        -- Return the inserted ReminderID
        SELECT LAST_INSERT_ID() AS ReminderID;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Prescription does not belong to this patient';
    END IF;

END //

DELIMITER ;

--CALL AddPrescriptionReminder(5, 10, '2025-12-01 08:00:00', '2025-12-10 08:00:00', 720);