USE medmanagedb;

DROP PROCEDURE IF EXISTS TransferPatientToSecondaryDoctor;
CREATE PROCEDURE TransferPatientToSecondaryDoctor(
    IN p_PatientUserID INT,
    IN p_SecondaryDoctorUserID INT
)
BEGIN
    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Insert mapping: secondary doctor = IsPrimaryDoctor = 0
    INSERT INTO doctor_patient (PatientDetailsID, DoctorDetailsID, IsPrimaryDoctor)
    VALUES (p_PatientUserID, p_SecondaryDoctorUserID, 0);

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'doctor_patient',
        CONCAT('CALL TransferPatientToSecondaryDoctor(', 
               p_PatientUserID, ', ', p_SecondaryDoctorUserID, ');')
    );

    COMMIT;
END;

-- CALL TransferPatientToSecondaryDoctor(1, 7);