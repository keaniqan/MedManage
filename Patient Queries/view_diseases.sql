USE medmanagedb;

DROP PROCEDURE IF EXISTS ViewPatientDiseases;

DELIMITER //

CREATE PROCEDURE ViewPatientDiseases(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        d.DiseaseID,
        d.Name AS DiseaseName,
        d.Description AS DiseaseDescription,
        dpd.Onset AS DiagnosedOn,
        dpd.Remitted AS RemittedOn,
        CASE 
            WHEN dpd.Remitted IS NULL THEN 'Active'
            ELSE 'Remitted'
        END AS Status,
        CASE 
            WHEN dpd.Remitted IS NULL 
            THEN CONCAT(TIMESTAMPDIFF(DAY, dpd.Onset, NOW()), ' days')
            ELSE CONCAT(TIMESTAMPDIFF(DAY, dpd.Onset, dpd.Remitted), ' days')
        END AS Duration
    FROM Disease_PatientDetails dpd
    INNER JOIN Disease d ON dpd.DiseaseID = d.DiseaseID
    INNER JOIN PatientDetails pd ON dpd.PatientDetailsID = pd.PatientDetailsID
    WHERE pd.UserID = p_PatientUserID
    ORDER BY dpd.Onset DESC;
END //

DELIMITER ;

-- CALL ViewPatientDiseases(1);