USE medmanagedb;

DROP PROCEDURE IF EXISTS EditMedication;
CREATE PROCEDURE EditMedication(
    IN p_MedicineId INT,
	IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    -- Update the medicine table with the new values
    SET @sql = CONCAT('UPDATE Medicine SET ', p_FieldName, ' = ? WHERE MedicineId = ?');
    PREPARE stmt FROM @sql;
    SET @NewValue = p_NewValue;
    SET @MedicineId = p_MedicineID;
    EXECUTE stmt USING @NewValue, @MedicineId;
    DEALLOCATE PREPARE stmt;

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'Medicine',
        CONCAT('CALL EditMedication(''', p_MedicineId, ''', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
END

-- Usage examples below
-- Edit Name
-- CALL EditMedication(1, 'Name', 'Paracetamol');

-- Edit Brand
-- CALL EditMedication(1, 'Brand', 'Panadol');