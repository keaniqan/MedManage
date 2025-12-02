USE medmanagedb;

DROP PROCEDURE IF EXISTS FilterAppointment;
CREATE PROCEDURE FilterAppointment(
    IN p_AppointmentID INT,
    IN p_PatientUserID INT,
    IN p_DoctorUserID INT,
    IN p_AppointmentOn DATETIME,
    IN p_Details VARCHAR(500),
    IN p_IsDoctorAccept BOOLEAN,
    IN p_IsPatientAccept BOOLEAN
)
BEGIN
    SELECT *
    FROM Appointment
    WHERE (p_AppointmentID IS NULL OR AppointmentID = AppointmentID)
		AND (p_PatientUserID IS NULL OR PatientUserID = p_PatientUserID)
        AND (p_DoctorUserID IS NULL OR DoctorUserID = p_DoctorUserID)
        AND (p_AppointmentOn IS NULL OR AppointmentOn = AppointmentOn)
        AND (p_Details IS NULL OR Details LIKE CONCAT('%', p_Details, '%'))
        AND (p_IsDoctorAccept IS NULL OR IsDoctorAccept = p_IsDoctorAccept)
        AND (p_IsPatientAccept IS NULL OR IsPatientAccept = p_IsPatientAccept)
    ORDER BY AppointmentID;
END

-- Usage examples:
-- Filter by AppointmentID
-- CALL FilterAppointment(1, NULL, NULL, NULL, NULL, NULL, NULL);

-- Filter by PatientUserID
-- CALL FilterAppointment(NULL, 1, NULL, NULL, NULL, NULL, NULL);