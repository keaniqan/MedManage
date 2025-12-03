USE medmanagedb;

DROP PROCEDURE IF EXISTS EditPrescription;

DELIMITER //

CREATE PROCEDURE EditPrescription(
    IN p_PrescriptionId INT,
	IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    SET @sql = CONCAT('UPDATE Prescription SET ', p_FieldName, ' = ? WHERE PrescriptionId = ?');
    PREPARE stmt FROM @sql;
    SET @NewValue = p_NewValue;
    SET @PrescriptionId = p_PrescriptionID;
    EXECUTE stmt USING @NewValue, @PrescriptionId;
    DEALLOCATE PREPARE stmt;

    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'Prescription',
        CONCAT('CALL EditPrescription(', p_PrescriptionId, ', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
END //

-- Usage examples below
-- Edit TotalDose
-- CALL EditPrescription(1, 'TotalDose', '2');

-- Edit Remark
-- CALL EditPrescription(1, 'Remark', 'Consume before sleep');