Use medmanagedb;
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
    p.ABOBloodType,
    p.RhBloodType,
    p.EmergencyContact,
    p.DOB
FROM Users u
JOIN PatientDetails p ON u.UserID = p.UserID
WHERE u.UserID = 1; -- Replace 1 with the specific Patient's UserID