-- add_compliance.sql
Use medmanagedb;

DELIMITER //

DROP PROCEDURE IF EXISTS AddCompliance//
CREATE PROCEDURE AddCompliance(
    IN p_PrescriptionID INT,
    IN p_TakenOn DATETIME,
    IN p_OtherData VARCHAR(50)
)
BEGIN
    -- Declare variables for error handling
    DECLARE v_PrescriptionExists INT DEFAULT 0;
    DECLARE v_ComplianceID INT;
    
    -- Check if the prescription exists
    SELECT COUNT(*) INTO v_PrescriptionExists
    FROM Prescription
    WHERE PrescriptionID_INT = p_PrescriptionID;
    
    -- If prescription doesn't exist, signal an error
    IF v_PrescriptionExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Prescription does not exist';
    ELSE
        -- Insert the compliance record
        INSERT INTO Compliance (
            PrescriptionID_INT,
            TakenOn_DATETIME,
            OtherData_VARCHAR50
        )
        VALUES (
            p_PrescriptionID,
            p_TakenOn,
            p_OtherData
        );
        
        -- Get the newly created compliance ID
        SET v_ComplianceID = LAST_INSERT_ID();
        
        -- Return success message with the new ID
        SELECT v_ComplianceID AS ComplianceID, 
               'Compliance record created successfully' AS Message;
    END IF;
END //

DELIMITER ;

-- Call the procedure to create a compliance record
CALL AddCompliance(1, '2024-11-28 10:30:00', 'Taken with food');