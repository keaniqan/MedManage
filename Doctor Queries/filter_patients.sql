USE medmanagedb;

DROP PROCEDURE IF EXISTS FilterPatients;

DELIMITER //

CREATE PROCEDURE FilterPatients(
    IN p_PatientDetailsID INT,
    IN p_UserID INT,
    IN p_ABOBloodType VARCHAR(2),
    IN p_RhBloodType VARCHAR(1),
    IN p_EmergencyContact VARCHAR(20),
    IN p_DOB DATE
)
BEGIN
    SELECT 
        pd.PatientDetailsID,
        pd.UserID,
        pd.ABOBloodType,
        pd.RhBloodType,
        CONCAT(pd.ABOBloodType, pd.RhBloodType) AS BloodType,
        pd.EmergencyContact,
        pd.DOB,
        TIMESTAMPDIFF(YEAR, pd.DOB, CURDATE()) AS Age
    FROM PatientDetails pd
    WHERE (p_PatientDetailsID IS NULL OR pd.PatientDetailsID = p_PatientDetailsID)
        AND (p_UserID IS NULL OR pd.UserID = p_UserID)
        AND (p_ABOBloodType IS NULL OR pd.ABOBloodType = p_ABOBloodType)
        AND (p_RhBloodType IS NULL OR pd.RhBloodType = p_RhBloodType)
        AND (p_EmergencyContact IS NULL OR pd.EmergencyContact LIKE CONCAT('%', p_EmergencyContact, '%'))
        AND (p_DOB IS NULL OR pd.DOB = p_DOB)
    ORDER BY pd.PatientDetailsID;
END //

DELIMITER ;