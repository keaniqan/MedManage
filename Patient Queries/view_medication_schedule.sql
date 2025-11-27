Use medmanagedb;
SELECT 
    p.PrescriptionID,
    m.Name AS MedicineName,
    m.Brand AS MedicineBrand,
    m.Description AS MedicineDescription,
    p.TotalDose,
    p.PrescribedOn,
    pd.PrescriptionDetailID,
    pd.Dose,
    pd.StartOn,
    pd.EndOn,
    pd.IntervalMinutes,
    CASE 
        WHEN pd.IntervalMinutes IS NOT NULL 
        THEN CONCAT('Every ', pd.IntervalMinutes DIV 60, ' hours ', pd.IntervalMinutes MOD 60, ' minutes')
        ELSE 'As needed'
    END AS FrequencyDescription,
    pd.IsTakeOnEffect,
    pd.Remark,
    CONCAT(doc.FirstName, ' ', doc.LastName) AS PrescribedByDoctor,
    dd.Specialist AS DoctorSpecialist
FROM Prescription p
INNER JOIN Medicine m ON p.MedicineID = m.MedicineId
INNER JOIN PrescriptionDetail pd ON p.PrescriptionID = pd.PrescriptionID
INNER JOIN Users doc ON p.DoctorUserID = doc.UserID
INNER JOIN DoctorDetails dd ON doc.UserID = dd.UserID
WHERE p.PatientUserID = 1  -- Replace with the patient's UserID
    AND (pd.EndOn IS NULL OR pd.EndOn >= CURDATE())  -- Only active prescriptions
ORDER BY pd.StartOn DESC, m.Name;