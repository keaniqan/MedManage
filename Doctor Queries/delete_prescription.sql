USE medmanagedb;

DROP PROCEDURE IF EXISTS DeletePrescription;

DELIMITER //

CREATE PROCEDURE DeletePrescription
(
IN p_PrescriptionID INT
)
BEGIN
    DELETE FROM Prescription
    WHERE PrescriptionID = p_PrescriptionID;
    
    -- log user action
    INSERT INTO log(ActionType, TableName, Query) 
    VALUES (
    'DROP', 
    'Prescription',
    CONCAT('CALL DeletePrescription(', p_PrescriptionID, ');')
    );
END //

DELIMITER ;

-- Usage example to delete prescription by PrescriptionID
-- CALL DeletePrescription(5)