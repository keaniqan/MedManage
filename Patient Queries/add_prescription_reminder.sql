Use medmanagedb;
DROP PROCEDURE IF EXISTS AddPrescriptionReminder; 
DELIMITER //

CREATE PROCEDURE AddPrescriptionReminder(
    IN p_StartOn DATETIME,
    IN p_EndOn DATETIME,
    IN p_IntervalMinutes INT,
    IN p_PrescriptionDetailID INT
)
BEGIN
    -- Insert the reminder
    INSERT INTO Reminder (StartOn, EndOn, IntervalMinutes, PrescriptionDetailID)
    VALUES (p_StartOn, p_EndOn, p_IntervalMinutes, p_PrescriptionDetailID);

    -- Simple log (because triggers do not have user context)
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'INSERT',
        'Reminder',
        CONCAT(
            'Auto reminder created for PrescriptionDetailID = ',
            p_PrescriptionDetailID
        ),
        'SYSTEM'
    );
END //

DELIMITER ;

-- CALL AddPatientReminder(1, '2024-07-01 09:00:00', '2024-07-10 09:00:00', 240, 5, NULL); -- Example call to the procedure for prescription reminder
-- CALL AddPatientReminder(1, '2024-07-15 10:00 :00', '2024-07-15 11:00:00', 0, NULL, 3); -- Example call to the procedure for appointment reminder