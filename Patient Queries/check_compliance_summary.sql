USE medmanagedb;

DROP PROCEDURE IF EXISTS CheckComplianceSummary;

DELIMITER //

CREATE PROCEDURE CheckComplianceSummary(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        p.PrescriptionID,
        m.Name AS MedicineName,
        m.Brand AS MedicineBrand,
        p.TotalDose,
        pd.Dose AS SingleDose,
        pd.IntervalMinutes,
        pd.StartOn,
        pd.EndOn,
        COUNT(c.ComplianceID) AS TotalDosesTaken,
        CASE 
            WHEN pd.IntervalMinutes > 0 AND pd.EndOn IS NOT NULL THEN
                FLOOR(TIMESTAMPDIFF(MINUTE, pd.StartOn, IFNULL(pd.EndOn, NOW())) / pd.IntervalMinutes)
            ELSE 0
        END AS ExpectedDoses,
        CASE 
            WHEN pd.IntervalMinutes > 0 AND pd.EndOn IS NOT NULL THEN
                ROUND(
                    (COUNT(c.ComplianceID) / 
                    NULLIF(FLOOR(TIMESTAMPDIFF(MINUTE, pd.StartOn, IFNULL(pd.EndOn, NOW())) / pd.IntervalMinutes), 0)) * 100, 
                    2
                )
            ELSE NULL
        END AS CompliancePercentage,
        MAX(c.TakenOn) AS LastTakenOn,
        CONCAT(doc.FirstName, ' ', doc.LastName) AS PrescribedByDoctor
    FROM Prescription p
    INNER JOIN Medicine m ON p.MedicineID = m.MedicineId
    INNER JOIN Users doc ON p.DoctorUserID = doc.UserID
    LEFT JOIN PrescriptionDetail pd ON p.PrescriptionID = pd.PrescriptionID
    LEFT JOIN Compliance c ON p.PrescriptionID = c.PrescriptionID
    WHERE p.PatientUserID = p_PatientUserID
    GROUP BY p.PrescriptionID, m.Name, m.Brand, p.TotalDose, pd.Dose, 
             pd.IntervalMinutes, pd.StartOn, pd.EndOn, doc.FirstName, doc.LastName
    ORDER BY p.PrescribedOn DESC;
END //

DELIMITER ;

-- CALL CheckComplianceSummary(1);