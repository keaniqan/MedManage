USE medmanagedb;

DROP PROCEDURE IF EXISTS ViewAppointmentSchedule;

DELIMITER //

CREATE PROCEDURE ViewAppointmentSchedule(
    IN p_PatientUserID INT
)
BEGIN
    SELECT 
        a.AppointmentID,
        a.AppointmentOn,
        DATE(a.AppointmentOn) AS AppointmentDate,
        TIME(a.AppointmentOn) AS AppointmentTime,
        a.Details,
        a.IsDoctorAccept,
        a.IsPatientAccept,
        CASE 
            WHEN a.IsDoctorAccept IS NULL AND a.IsPatientAccept = 1 THEN 'Pending Doctor Confirmation'
            WHEN a.IsDoctorAccept = 1 AND a.IsPatientAccept IS NULL THEN 'Pending Your Confirmation'
            WHEN a.IsDoctorAccept = 1 AND a.IsPatientAccept = 1 THEN 'Confirmed'
            WHEN a.IsDoctorAccept = 0 OR a.IsPatientAccept = 0 THEN 'Cancelled'
            ELSE 'Pending'
        END AS AppointmentStatus,
        CASE 
            WHEN a.AppointmentOn < NOW() THEN 'Past'
            WHEN a.AppointmentOn > NOW() THEN 'Upcoming'
            ELSE 'Today'
        END AS TimeStatus,
        CONCAT(doc.FirstName, ' ', doc.LastName) AS DoctorName,
        dd.Specialist AS DoctorSpecialist,
        dd.MedicalLicenceNumber,
        i.Name AS InstituteName,
        i.AddressLine1,
        i.City,
        r.ReminderID,
        r.StartOn AS ReminderStartOn,
        r.IntervalMinutes AS ReminderInterval
    FROM Appointment a
    INNER JOIN Users doc ON a.DoctorUserID = doc.UserID
    INNER JOIN DoctorDetails dd ON doc.UserID = dd.UserID
    LEFT JOIN Institute i ON doc.InstituteID = i.InstituteID
    LEFT JOIN Reminder r ON a.AppointmentID = r.AppointmentID
    WHERE a.PatientUserID = p_PatientUserID
    ORDER BY a.AppointmentOn DESC;
END //

DELIMITER ;

-- CALL ViewAppointmentSchedule(1);