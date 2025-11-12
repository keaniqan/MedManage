CREATE TRIGGER after_doctor_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    -- Only log when a doctor is created
    IF NEW.UserType = 'doctor' THEN
        INSERT INTO systemlogdb.user_action_log (ActionType, userID, Username, UserType)
        VALUES ('CREATE_DOCTOR', NEW.UserID, NEW.Username, NEW.UserType);
    END IF;
END 


