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

-- Test Prescription Chain below

-- Raw inserts to create a chain of 10 test prescriptions
-- Replace PatientUserID (5), DoctorUserID (2), and MedicineID (1) with valid IDs from your database

-- Prescription 1 (Original) - No previous prescription
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, NULL, 1, '100mg', 'Version 1 - Initial prescription', DATE_ADD(NOW(), INTERVAL -9 DAY));

-- SET @prescription_1 = LAST_INSERT_ID();

-- Prescription 2 - References Prescription 1
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_1, 1, '200mg', 'Version 2 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -8 DAY));

-- SET @prescription_2 = LAST_INSERT_ID();

-- Prescription 3 - References Prescription 2
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_2, 1, '300mg', 'Version 3 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -7 DAY));

-- SET @prescription_3 = LAST_INSERT_ID();

-- Prescription 4 - References Prescription 3
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_3, 1, '400mg', 'Version 4 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -6 DAY));

-- SET @prescription_4 = LAST_INSERT_ID();

-- Prescription 5 - References Prescription 4
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_4, 1, '500mg', 'Version 5 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -5 DAY));

-- SET @prescription_5 = LAST_INSERT_ID();

-- Prescription 6 - References Prescription 5
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_5, 1, '600mg', 'Version 6 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -4 DAY));

-- SET @prescription_6 = LAST_INSERT_ID();

-- Prescription 7 - References Prescription 6
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_6, 1, '700mg', 'Version 7 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -3 DAY));

-- SET @prescription_7 = LAST_INSERT_ID();

-- Prescription 8 - References Prescription 7
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_7, 1, '800mg', 'Version 8 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -2 DAY));

-- SET @prescription_8 = LAST_INSERT_ID();

-- Prescription 9 - References Prescription 8
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_8, 1, '900mg', 'Version 9 - Adjusted dosage based on patient response', DATE_ADD(NOW(), INTERVAL -1 DAY));

-- SET @prescription_9 = LAST_INSERT_ID();

-- Prescription 10 (Most Recent) - References Prescription 9
-- INSERT INTO prescription (PatientUserID, DoctorUserID, PreviousPrescriptionID, MedicineID, TotalDose, Remark, PrescribedOn)
-- VALUES (5, 2, @prescription_9, 1, '1000mg', 'Version 10 - Adjusted dosage based on patient response', NOW());

-- SET @prescription_10 = LAST_INSERT_ID();

-- Display the final prescription ID
-- SELECT @prescription_10 AS FinalPrescriptionID, 'Successfully created 10 prescription chain' AS Message;

-- To view the prescription history chain, run:
-- CALL ViewPrescriptionHistory(@prescription_10);
