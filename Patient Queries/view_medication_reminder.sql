USE medmanagedb;

DROP PROCEDURE IF EXISTS ViewMedicationReminders;

DELIMITER //

CREATE PROCEDURE ViewMedicationReminders(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        r.ReminderID,
        r.StartOn,
        r.EndOn,
        r.IntervalMinutes,
        CASE 
            WHEN r.IntervalMinutes IS NOT NULL 
            THEN CONCAT('Every ', r.IntervalMinutes DIV 60, ' hours ', r.IntervalMinutes MOD 60, ' minutes')
            ELSE 'One-time reminder'
        END AS FrequencyDescription,
        m.Name AS MedicineName,
        m.Brand AS MedicineBrand,
        pd.Dose,
        p.TotalDose,
        p.Remark AS PrescriptionRemark,
        CONCAT(doc.FirstName, ' ', doc.LastName) AS PrescribedByDoctor,
        CASE 
            WHEN r.EndOn < NOW() THEN 'Expired'
            WHEN r.StartOn > NOW() THEN 'Upcoming'
            ELSE 'Active'
        END AS ReminderStatus
    FROM Reminder r
    INNER JOIN PrescriptionDetail pd ON r.PrescriptionDetailID = pd.PrescriptionDetailID
    INNER JOIN Prescription p ON pd.PrescriptionID = p.PrescriptionID
    INNER JOIN Medicine m ON p.MedicineID = m.MedicineId
    INNER JOIN Users doc ON p.DoctorUserID = doc.UserID
    WHERE p.PatientUserID = p_PatientUserID
        AND r.PrescriptionDetailID IS NOT NULL
    ORDER BY r.StartOn DESC;
END //

DELIMITER ;

-- CALL ViewMedicationReminders(1);