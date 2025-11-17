-- Query to retrieve all patients of a specified doctor
-- Shows patient information with a flag indicating if the doctor is their primary doctor

SELECT 
    u.UserID,
    u.Username,
    u.FirstName,
    u.LastName,
    u.Email,
    u.Phone,
    pd.PatientDetailsID,
    pd.ABOBloodType,
    pd.RhBloodType,
    pd.DOB,
    pd.EmergencyContact,
    CASE 
        WHEN dp.IsPrimaryDoctor = 1 THEN 'Yes'
        ELSE 'No'
    END AS IsPrimaryDoctor
FROM 
    Doctor_Patient dp
    INNER JOIN PatientDetails pd ON dp.PatientDetailsID = pd.PatientDetailsID
    INNER JOIN Users u ON pd.UserID = u.UserID
WHERE 
    dp.DoctorDetailsID = ? -- Replace ? with the specific DoctorDetailsID parameter
ORDER BY 
    dp.IsPrimaryDoctor DESC, 
    u.LastName, 
    u.FirstName;
