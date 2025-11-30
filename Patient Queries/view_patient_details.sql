Use medmanagedb;
DROP PROCEDURE IF EXISTS ViewOwnPatientDetails;

DELIMITER //

CREATE PROCEDURE ViewOwnPatientDetails()
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
        u.InstituteID,
        pd.ABOBloodType,
        pd.RhBloodType,
        pd.EmergencyContact,
        pd.DOB
    FROM Users u
    JOIN PatientDetails pd ON u.UserID = pd.UserID
    WHERE u.UserType = 'patient'
      AND u.Username = SUBSTRING_INDEX(CURRENT_USER(),'@',1);  -- Assuming MySQL user = Username
END //

DELIMITER ;

-- CALL ViewOwnPatientDetails();
