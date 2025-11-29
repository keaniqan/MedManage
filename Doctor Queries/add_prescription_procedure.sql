-- add_prescription.sql
Use medmanagedb;
DROP PROCEDURE IF EXISTS AddPrescription//
CREATE PROCEDURE AddPrescription(
    IN p_PatientID INT,
    IN p_DoctorID INT,
    IN p_MedicineID INT,
    IN p_PreviousPrescriptionID INT,
    IN p_Dosage VARCHAR(50),
    IN p_TotalDose VARCHAR(50),
    IN p_Refunds VARCHAR(50),
    IN p_PrescribedOn DATETIME
)
BEGIN
    -- Declare variables
    DECLARE v_PatientExists INT DEFAULT 0;
    DECLARE v_DoctorExists INT DEFAULT 0;
    DECLARE v_MedicineExists INT DEFAULT 0;
    DECLARE v_PrescriptionID INT;
    
    -- Validate Patient exists
    SELECT COUNT(*) INTO v_PatientExists
    FROM Users
    WHERE UserID_INT = p_PatientID;
    
    -- Validate Doctor exists
    SELECT COUNT(*) INTO v_DoctorExists
    FROM Users
    WHERE UserID_INT = p_DoctorID;
    
    -- Validate Medicine exists
    SELECT COUNT(*) INTO v_MedicineExists
    FROM Medicine
    WHERE MedicineID_INT = p_MedicineID;
    
    -- Check all validations
    IF v_PatientExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Patient does not exist';
    ELSEIF v_DoctorExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Doctor does not exist';
    ELSEIF v_MedicineExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Medicine does not exist';
    ELSE
        -- Insert the prescription
        INSERT INTO Prescription (
            PatientID_INT,
            DoctorID_INT,
            MedicineID_INT,
            PreviousPrescriptionID_INT,
            Dosage_VARCHAR50,
            TotalDose_VARCHAR50,
            Refunds_VARCHAR50,
            PrescribedOn_DateTime
        )
        VALUES (
            p_PatientID,
            p_DoctorID,
            p_MedicineID,
            p_PreviousPrescriptionID,
            p_Dosage,
            p_TotalDose,
            p_Refunds,
            p_PrescribedOn
        );
        
        -- Get the newly created prescription ID
        SET v_PrescriptionID = LAST_INSERT_ID();
    END IF;
END //

-- Add a new prescription
CALL AddPrescription(1, 2, 5, NULL, '500mg twice daily', '30 tablets', '2 refills', '2024-11-28 14:30:00');