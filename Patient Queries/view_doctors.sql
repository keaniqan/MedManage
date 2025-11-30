USE medmanagedb;

DROP PROCEDURE IF EXISTS ViewMyDoctors;

DELIMITER //

CREATE PROCEDURE ViewMyDoctors(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        u.UserID AS DoctorUserID,
        CONCAT(u.FirstName, ' ', u.LastName) AS DoctorName,
        u.Email AS DoctorEmail,
        u.Phone AS DoctorPhone,
        dd.DoctorDetailsID,
        dd.Specialist,
        dd.MedicalLicenceNumber,
        dd.YearsOfExperience,
        dd.MedicalSchool,
        dd.Certificates,
        dd.LanguagesSpoken,
        dp.IsPrimaryDoctor,
        i.Name AS InstituteName,
        i.AddressLine1,
        i.City,
        (SELECT COUNT(*) FROM Appointment a 
         WHERE a.PatientUserID = p_PatientUserID 
         AND a.DoctorUserID = u.UserID) AS TotalAppointments,
        (SELECT COUNT(*) FROM Prescription p 
         WHERE p.PatientUserID = p_PatientUserID 
         AND p.DoctorUserID = u.UserID) AS TotalPrescriptions
    FROM Doctor_Patient dp
    INNER JOIN PatientDetails pd ON dp.PatientDetailsID = pd.PatientDetailsID
    INNER JOIN DoctorDetails dd ON dp.DoctorDetailsID = dd.DoctorDetailsID
    INNER JOIN Users u ON dd.UserID = u.UserID
    LEFT JOIN Institute i ON u.InstituteID = i.InstituteID
    WHERE pd.UserID = p_PatientUserID
    ORDER BY dp.IsPrimaryDoctor DESC, u.LastName, u.FirstName;
END //

DELIMITER ;

-- CALL ViewMyDoctors(1);