USE medmanagedb;

DROP PROCEDURE IF EXISTS FilterReminder;

DELIMITER //

CREATE PROCEDURE FilterReminder(
    IN p_ReminderID INT,
    IN p_StartOn DATETIME,
    IN p_EndOn DATETIME,
    IN p_IntervalMinutes INT,
    IN p_PrescriptionDetailID INT,
    IN p_AppointmentID INT
)
BEGIN
    SELECT *
    FROM Reminder
    WHERE (p_ReminderID IS NULL OR ReminderID = ReminderID)
		AND (p_StartOn IS NULL OR StartOn = StartOn)
        AND (p_EndOn IS NULL OR p_EndOn = p_EndOn)
        AND (p_IntervalMinutes IS NULL OR IntervalMinutes = IntervalMinutes)
        AND (p_PrescriptionDetailID IS NULL OR PrescriptionDetailID = PrescriptionDetailID)
        AND (p_AppointmentID IS NULL OR AppointmentID = AppointmentID)
    ORDER BY ReminderID;
END //

DELIMITER ;

-- Usage examples:
-- Filter by ReminderID
CALL FilterReminder(1, NULL, NULL, NULL, NULL, NULL);

-- Filter by PrescriptionDetailID
CALL FilterReminder(NULL, NULL, NULL, NULL, 1, NULL);

-- Filter by AppointmentID
CALL FilterReminder(NULL, NULL, NULL, NULL, NULL, 1);