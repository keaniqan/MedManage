use medmanagedb;
DROP TRIGGER IF EXISTS after_doctor_insert;
CREATE TRIGGER after_doctor_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    -- Only log when a doctor is created
    IF NEW.UserType = 'doctor' THEN
        INSERT INTO medmanagedb.user_action_log (ActionType, TableName, Query)
        VALUES ('INSERT', 'users', CONCAT('Inserted doctor with Username: ', NEW.Username));
    END IF;
END 


