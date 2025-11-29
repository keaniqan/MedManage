USE medmanagedb;

DROP PROCEDURE IF EXISTS DeleteMedication;

DELIMITER //

CREATE PROCEDURE DeleteMedication
(
IN p_MedicineID INT
)
BEGIN
    DELETE FROM Medicine
    WHERE MedicineID = p_MedicineID;
    
    -- log user action
    INSERT INTO log(ActionType, TableName, Query) 
    VALUES (
    'DROP', 
    'Medicine',
    CONCAT('CALL DeleteMedication(''', p_MedicineID, ''');')
    );
END //

DELIMITER ;

-- Usage example to delete medicine by MedicineID
-- CALL DeleteMedication(5)