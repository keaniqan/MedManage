USE medmanagedb;

DROP PROCEDURE IF EXISTS FilterMedicine;

DELIMITER //

CREATE PROCEDURE FilterMedicine(
    IN p_MedicineID INT,
    IN p_Name INT,
    IN p_Brand VARCHAR(100),
    IN p_Description VARCHAR(500)
)
BEGIN
    SELECT *
    FROM Medicine
    WHERE (p_MedicineID IS NULL OR MedicineID = p_MedicineID)
        AND (p_Name IS NULL OR Name LIKE CONCAT('%', p_Name, '%'))
        AND (p_Brand IS NULL OR Brand LIKE CONCAT('%', p_Brand, '%'))
        AND (p_Description IS NULL OR Description LIKE CONCAT('%', p_Description, '%'))
    ORDER BY MedicineID;
END //

DELIMITER ;

-- Usage examples:
-- Filter by MedicineID
CALL FilterMedicine(1, NULL, NULL, NULL);

-- Filter by Name
CALL FilterMedicine(NULL, 'Paracetamol', NULL, NULL);