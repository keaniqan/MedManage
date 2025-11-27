USE medmanagedb;
SELECT
	p.PrescriptionID,
    p.PatientUserID,
    p.DoctorUserID,
    p.PreviousPrescriptionID,
    p.MedicineID,
    p.TotalDose,
    p.Remark,
    p.PrescribedOn,
    pr.PrescriptionDetailID,
    pr.IsTakeOnEffect,
    pr.StartOn,
    pr.Endon,
    pr.Dose,
    pr.IntervalMinutes
FROM Prescription p
INNER JOIN PrescriptionDetail pr ON pr.PrescriptionID = p.PrescriptionID
AND pr.Remark = p.Remark;