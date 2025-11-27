USE medmanagedb;
DELIMITER //

DROP PROCEDURE IF EXISTS AddMedicine//

CREATE PROCEDURE AddMedicine(
    IN p_Name VARCHAR(100),
    IN p_Brand VARCHAR(100),
    IN p_Description VARCHAR(500)
)
BEGIN
    INSERT INTO Medicine (Name, Brand, Description)
    VALUES (p_Name, p_Brand, p_Description);
    
    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'Medicine',
        CONCAT('CALL AddMedicine(''', p_Name, ''', ''', p_Brand, ''', ''', p_Description, ''');')
    );
    
    -- Return the newly created MedicineId
    SELECT LAST_INSERT_ID() AS MedicineId;
END//

DELIMITER ;

-- To add medicines (example below)
-- CALL AddMedicine('Ibuprofen', 'Advil', 'Anti-inflammatory and pain reliever');