CREATE DATABASE IF NOT EXISTS systemlogdb;
USE systemlogdb;

CREATE TABLE IF NOT EXISTS user_action_log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    ActionType VARCHAR(50) NOT NULL,
    ActionTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PerformedBy VARCHAR(100) NULL
) ENGINE=InnoDB;

DROP TRIGGER IF EXISTS before_insert_user_action_log;
CREATE TRIGGER before_insert_user_action_log
BEFORE INSERT ON user_action_log
FOR EACH ROW
BEGIN
    IF NEW.PerformedBy IS NULL OR NEW.PerformedBy = '' THEN
        SET NEW.PerformedBy = CURRENT_USER();
    END IF;
END;

