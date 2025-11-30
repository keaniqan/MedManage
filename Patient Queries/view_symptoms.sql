USE medmanagedb;

DROP PROCEDURE IF EXISTS ViewPatientSymptoms;

DELIMITER //

CREATE PROCEDURE ViewPatientSymptoms(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        s.SymptomID,
        s.Name AS SymptomName,
        s.Description AS SymptomDescription,
        spd.Onset AS StartedOn,
        spd.Remitted AS RemittedOn,
        CASE 
            WHEN spd.Remitted IS NULL THEN 'Active'
            ELSE 'Resolved'
        END AS Status,
        CASE 
            WHEN spd.Remitted IS NULL 
            THEN CONCAT(TIMESTAMPDIFF(DAY, spd.Onset, NOW()), ' days')
            ELSE CONCAT(TIMESTAMPDIFF(DAY, spd.Onset, spd.Remitted), ' days')
        END AS Duration
    FROM Symptom_PatientDetails spd
    INNER JOIN Symptom s ON spd.SymptomID = s.SymptomID
    INNER JOIN PatientDetails pd ON spd.PatientDetailsID = pd.PatientDetailsID
    WHERE pd.UserID = p_PatientUserID
    ORDER BY spd.Onset DESC;
END //

DELIMITER ;

-- CALL ViewPatientSymptoms(1);