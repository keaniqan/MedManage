USE medmanagedb;

-- Procedure to view prescription history recursively
DROP PROCEDURE IF EXISTS ViewPrescriptionHistory;
CREATE PROCEDURE ViewPrescriptionHistory(
    IN p_PrescriptionID INT
)
BEGIN
    -- Using recursive CTE to get the entire prescription chain
    WITH RECURSIVE PrescriptionHistory AS (
        -- Base case: Start with the given prescription
        SELECT 
            PrescriptionID,
            PatientUserID,
            DoctorUserID,
            PreviousPrescriptionID,
            MedicineID,
            TotalDose,
            Remark,
            PrescribedOn,
            1 AS Level  -- Track how many revisions back
        FROM prescription
        WHERE PrescriptionID = p_PrescriptionID
        
        UNION ALL
        
        -- Recursive case: Get previous prescriptions
        SELECT 
            p.PrescriptionID,
            p.PatientUserID,
            p.DoctorUserID,
            p.PreviousPrescriptionID,
            p.MedicineID,
            p.TotalDose,
            p.Remark,
            p.PrescribedOn,
            ph.Level + 1
        FROM prescription p
        INNER JOIN PrescriptionHistory ph ON p.PrescriptionID = ph.PreviousPrescriptionID
    )
    SELECT 
        ph.PrescriptionID,
        ph.PatientUserID,
        ph.DoctorUserID,
        ph.PreviousPrescriptionID,
        ph.MedicineID,
        ph.TotalDose,
        ph.Remark,
        ph.PrescribedOn,
        ph.Level AS RevisionLevel,
        CASE 
            WHEN ph.Level = 1 THEN 'Current'
            ELSE CONCAT('Revision -', ph.Level - 1)
        END AS PrescriptionStatus
    FROM PrescriptionHistory ph
    ORDER BY ph.Level ASC;  -- Order from current to oldest
END;

-- Example usage:
-- CALL ViewPrescriptionHistory(10);
-- This will show the prescription with ID 10 and all its previous versions
