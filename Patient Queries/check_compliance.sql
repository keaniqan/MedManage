USE medmanagedb;

DROP PROCEDURE IF EXISTS CheckCompliance;

DELIMITER //

CREATE PROCEDURE CheckCompliance(
    IN p_PatientUserID INT
)
BEGIN
    -- View compliance records for patient's prescriptions
    SELECT 
        c.ComplianceID,
        c.TakenOn,
        DATE(c.TakenOn) AS TakenDate,
        TIME(c.TakenOn) AS TakenTime,
        c.DoseTaken,
        p.PrescriptionID,
        m.Name AS MedicineName,
        m.Brand AS MedicineBrand,
        p.TotalDose AS PrescribedTotalDose,
        pd.Dose AS PrescribedDose,
        pd.IntervalMinutes,
        CASE 
            WHEN pd.IntervalMinutes IS NOT NULL 
            THEN CONCAT('Every ', pd.IntervalMinutes DIV 60, ' hours')
            ELSE 'As needed'
        END AS ExpectedFrequency,
        CONCAT(doc.FirstName, ' ', doc.LastName) AS PrescribedByDoctor,
        p.PrescribedOn
    FROM Compliance c
    INNER JOIN Prescription p ON c.PrescriptionID = p.PrescriptionID
    INNER JOIN Medicine m ON p.MedicineID = m.MedicineId
    INNER JOIN Users doc ON p.DoctorUserID = doc.UserID
    LEFT JOIN PrescriptionDetail pd ON p.PrescriptionID = pd.PrescriptionID
    WHERE p.PatientUserID = p_PatientUserID
    ORDER BY c.TakenOn DESC;
END //

DELIMITER ;

-- CALL CheckCompliance(1);