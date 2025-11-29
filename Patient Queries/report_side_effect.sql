Use medmanagedb;

DROP PROCEDURE IF EXISTS ReportSideEffectForPrescription;

DELIMITER //

CREATE PROCEDURE ReportSideEffectForPrescription(
    IN p_PatientUserID INT,
    IN p_PrescriptionID INT,
    IN p_SideEffectName VARCHAR(100),
    IN p_SideEffectDescription VARCHAR(500)
)
BEGIN
    DECLARE v_OwnerUserID INT;
    DECLARE v_SideEffectID INT;

    -- Check that prescription belongs to this patient
    SELECT PatientUserID INTO v_OwnerUserID
    FROM Prescription
    WHERE PrescriptionID = p_PrescriptionID;

    IF v_OwnerUserID != p_PatientUserID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prescription does not belong to this patient';
    END IF;

    -- If not exists, insert into SideEffect table
    IF v_SideEffectID IS NULL THEN
        INSERT INTO SideEffect (Name, Description)
        VALUES (p_SideEffectName, p_SideEffectDescription);
        SET v_SideEffectID = LAST_INSERT_ID();
    END IF;

    -- Link side effect to prescription
    INSERT INTO Prescription_SideEffect (PrescriptionID, SideEffectID, ReportedOn)
    VALUES (p_PrescriptionID, v_SideEffectID, NOW());

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'INSERT',
        'Prescription_SideEffect',
        CONCAT(
            'CALL ReportSideEffectForPrescription(', p_PatientUserID, ', ',
            p_PrescriptionID, ', ''', p_SideEffectName, ''', ''', p_SideEffectDescription, ''');'
        ),
        (SELECT Username FROM Users WHERE UserID = p_PatientUserID)
    );

    SELECT 'Side effect reported successfully' AS Message, v_SideEffectID AS SideEffectID;

END //

DELIMITER ;
