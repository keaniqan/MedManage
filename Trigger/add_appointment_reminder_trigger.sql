USE medmanagedb;

-- Trigger to create reminder when appointment is fully accepted (both doctor and patient)
DROP TRIGGER IF EXISTS after_appointment_accepted;

CREATE TRIGGER after_appointment_accepted
AFTER UPDATE ON appointment
FOR EACH ROW
BEGIN
    -- Check if both doctor and patient have accepted (changed from NULL or 0 to 1)
    IF NEW.IsDoctorAccept = 1 AND NEW.IsPatientAccept = 1 THEN
        -- Check if a reminder doesn't already exist for this appointment
        IF NOT EXISTS (
            SELECT 1 FROM reminder 
            WHERE AppointmentID = NEW.AppointmentID
        ) THEN
            -- Insert reminder for the appointment
            -- StartOn is set to 1 day before appointment
            -- EndOn is set to the appointment time
            -- IntervalMinutes can be set to remind every few hours before appointment
            INSERT INTO reminder (
                StartOn,
                EndOn,
                IntervalMinutes,
                AppointmentID
            ) VALUES (
                DATE_SUB(NEW.AppointmentOn, INTERVAL 1 DAY),  -- Start reminding 1 day before
                NEW.AppointmentOn,                             -- Stop at appointment time
                360,                                            -- Remind every 6 hours
                NEW.AppointmentID
            );
            
            -- Log the action
            INSERT INTO log (ActionType, TableName, Query, PerformedBy)
            VALUES (
                'INSERT',
                'reminder',
                CONCAT('Auto reminder created for AppointmentID = ', NEW.AppointmentID),
                'SYSTEM'
            );
        END IF;
    END IF;
END;

-- CALL EditAppointment(3, 'isDoctorAccept', '1');
-- CALL EditAppointment(3, 'isPatientAccept', '1');