CREATE TRIGGER after_prescriptiondetail_insert
AFTER INSERT ON prescriptiondetail
FOR EACH ROW
BEGIN
    -- Call AddReminder procedure with the prescription detail information
    CALL AddPrescriptionReminder(
        NEW.StartOn,              -- Start date from prescription detail
        NEW.EndOn,                -- End date from prescription detail
        NEW.IntervalMinutes,      -- Interval from prescription detail
        NEW.PrescriptionDetailID  -- The newly created prescription detail ID
    );
END;