-- add_compliance.sql
Use medmanagedb;

DELIMITER //

DROP PROCEDURE IF EXISTS AddCompliance//
CREATE PROCEDURE AddCompliance(
    IN p_PrescriptionID INT,
    IN p_TakenOn DATETIME,
    IN p_DoseTaken VARCHAR(50)
)
BEGIN
    DECLARE v_PrescriptionExists INT DEFAULT 0;
    DECLARE v_ComplianceID INT;
    
    -- Check if the prescription exists
    SELECT COUNT(*) INTO v_PrescriptionExists
    FROM Prescription
    WHERE PrescriptionID = p_PrescriptionID;
    
    IF v_PrescriptionExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Prescription does not exist';
    ELSE
        INSERT INTO Compliance (
            PrescriptionID,
            TakenOn,
            DoseTaken
        )
        VALUES (
            p_PrescriptionID,
            p_TakenOn,
            p_DoseTaken
        );
        
        SET v_ComplianceID = LAST_INSERT_ID();
        
        SELECT v_ComplianceID AS ComplianceID, 
               'Compliance record created successfully' AS Message;
    END IF;
END //

DELIMITER ;

-- Call the procedure to create a compliance record
CALL AddCompliance(1, '2024-11-28 10:30:00', 'Taken with food');