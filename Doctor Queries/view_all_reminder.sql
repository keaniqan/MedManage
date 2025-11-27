USE medmanagedb;
SELECT
	r.ReminderID,
    r.StartOn,
    r.EndOn,
    r.IntervalMinutes,
    r.PrescriptionDetailID,
    r.AppointmentID
FROM Reminder r
INNER JOIN Appointment a ON a.AppointmentID = r.AppointmentID;