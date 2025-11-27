USE medmanagedb;

DROP PROCEDURE IF EXISTS FilterPrescription;

DELIMITER //

CREATE PROCEDURE FilterPrescription(
    IN p_PrescriptionID INT,
    IN p_PatientUserID INT,
    IN p_DoctorUserID INT,
    IN p_PreviousPrescriptionID INT,
    IN p_MedicineID INT,
    IN p_TotalDose VARCHAR(50),
    IN p_Remark VARCHAR(500),
    IN p_PrescribedOn DATETIME
)
BEGIN
    SELECT *
    FROM Prescription
    WHERE (p_PrescriptionID IS NULL OR PrescriptionID = p_PrescriptionID)
		AND (p_PatientUserID IS NULL OR PatientUserID = p_PatientUserID)
        AND (p_DoctorUserID IS NULL OR DoctorUserID = p_DoctorUserID)
        AND (p_PreviousPrescriptionID IS NULL OR PreviousPrescriptionID = PreviousPrescriptionID)
        AND (p_MedicineID IS NULL OR MedicineID = p_MedicineID)
        AND (p_TotalDose IS NULL OR TotalDose LIKE CONCAT('%', p_TotalDose, '%'))
        AND (p_Remark IS NULL OR Remark LIKE CONCAT('%', p_Remark, '%'))
        AND (p_PrescribedOn IS NULL OR PrescribedOn = p_PrescribedOn)
    ORDER BY PrescriptionID;
END //

DELIMITER ;

-- Usage examples:
-- Filter by PrescriptionID
CALL FilterPrescription(1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Filter by PatientUserID
CALL FilterPrescription(NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL);