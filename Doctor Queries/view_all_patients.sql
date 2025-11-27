USE medmanagedb;
SELECT
    u.UserID,
    u.Username,
    u.FirstName,
    u.LastName,
    u.Email,
    u.Phone,
    u.Gender,
    pd.PatientDetailsID,
    pd.ABOBloodType,
    pd.RhBloodType,
    CONCAT(pd.ABOBloodType, pd.RhBloodType) AS BloodType,
    pd.DOB,
    TIMESTAMPDIFF(YEAR, pd.DOB, CURDATE()) AS Age,
    pd.EmergencyContact,
    dp.IsPrimaryDoctor,
    i.Name AS InstituteName
FROM Doctor_Patient dp
INNER JOIN DoctorDetails dd ON dp.DoctorDetailsID = dd.DoctorDetailsID
INNER JOIN PatientDetails pd ON dp.PatientDetailsID = pd.PatientDetailsID
INNER JOIN Users u ON pd.UserID = u.UserID
LEFT JOIN Institute i ON u.InstituteID = i.InstituteID
WHERE dd.UserID = 1
ORDER BY dp.IsPrimaryDoctor DESC, u.LastName, u.FirstName;