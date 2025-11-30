USE medmanagedb;

DROP PROCEDURE IF EXISTS ViewPatientProfile;

DELIMITER //

CREATE PROCEDURE ViewPatientProfile(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        u.UserID,
        u.Username,
        u.Email,
        u.FirstName,
        u.LastName,
        u.Phone,
        u.Identification,
        u.Gender,
        i.Name AS InstituteName,
        i.City AS InstituteCity,
        pd.PatientDetailsID,
        pd.ABOBloodType,
        pd.RhBloodType,
        CONCAT(pd.ABOBloodType, pd.RhBloodType) AS BloodType,
        pd.EmergencyContact,
        pd.DOB,
        TIMESTAMPDIFF(YEAR, pd.DOB, CURDATE()) AS Age,
        (SELECT COUNT(*) FROM Prescription WHERE PatientUserID = u.UserID) AS TotalPrescriptions,
        (SELECT COUNT(*) FROM Appointment WHERE PatientUserID = u.UserID) AS TotalAppointments,
        (SELECT COUNT(*) FROM Disease_PatientDetails WHERE PatientDetailsID = pd.PatientDetailsID) AS TotalDiseases
    FROM Users u
    INNER JOIN PatientDetails pd ON u.UserID = pd.UserID
    LEFT JOIN Institute i ON u.InstituteID = i.InstituteID
    WHERE u.UserID = p_PatientUserID
        AND u.UserType = 'patient';
END //

DELIMITER ;

-- CALL ViewPatientProfile(1);