USE medmanagedb;

DROP PROCEDURE IF EXISTS DeleteAppointment;

DELIMITER //

CREATE PROCEDURE DeleteAppointment
(
IN p_AppointmentID INT
)
BEGIN
    DELETE FROM Appointment
    WHERE AppointmentID = p_AppointmentID;
    
    -- log user action
    INSERT INTO log(ActionType, TableName, Query) 
    VALUES (
    'DROP', 
    'Appointment',
    CONCAT('CALL DeleteAppointment(', p_AppointmentID, ');')
    );
END //

DELIMITER ;

-- Usage example to delete appointment by AppointmentID
-- CALL DeleteAppointment(5)