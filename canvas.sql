-- =============================================
-- Trigger: After Insert on PrescriptionDetail
-- Purpose: Automatically create reminder when prescription detail is created
-- =============================================
DROP TRIGGER IF EXISTS after_prescriptiondetail_insert;

CREATE TRIGGER after_prescriptiondetail_insert
AFTER INSERT ON prescriptiondetail
FOR EACH ROW
BEGIN
    -- Call AddReminder procedure with the prescription detail information
    CALL AddReminder(
        NEW.StartOn,              -- Start date from prescription detail
        NEW.EndOn,                -- End date from prescription detail
        NEW.IntervalMinutes,      -- Interval from prescription detail
        NEW.PrescriptionDetailID  -- The newly created prescription detail ID
    );
END

-- Test the trigger (optional)
-- INSERT INTO prescriptiondetail (PrescriptionID, IsTakeOnEffect, StartOn, EndOn, Dose, IntervalMinutes, Remark)
-- VALUES (1, 0, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), '1 tablet', 480, 'Test reminder trigger');