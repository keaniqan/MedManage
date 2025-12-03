START TRANSACTION;

--
-- Database: `medmanagedb`
--
DROP DATABASE IF EXISTS `medmanagedb`;
CREATE DATABASE IF NOT EXISTS `medmanagedb`;
USE `medmanagedb`;

-- --------------------------------------------------------

--
-- Table structure for table `Appointment`
--

DROP TABLE IF EXISTS `Appointment`;
CREATE TABLE `Appointment` (
  `AppointmentID` int NOT NULL AUTO_INCREMENT,
  `PatientUserID` int NOT NULL,
  `DoctorUserID` int NOT NULL,
  `AppointmentOn` datetime NOT NULL,
  `Details` varchar(500)  NOT NULL,
  `IsDoctorAccept` tinyint(1) DEFAULT NULL,
  `IsPatientAccept` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`AppointmentID`),
  KEY `DoctorUserID` (`DoctorUserID`),
  KEY `PatientUserID` (`PatientUserID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Compliance`
--

DROP TABLE IF EXISTS `Compliance`;
CREATE TABLE `Compliance` (
  `ComplianceID` int NOT NULL AUTO_INCREMENT,
  `TakenOn` datetime NOT NULL,
  `PrescriptionID` int NOT NULL,
  `DoseTaken` varchar(50)  NOT NULL,
  PRIMARY KEY (`ComplianceID`),
  KEY `PrescriptionID` (`PrescriptionID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Disease`
--

DROP TABLE IF EXISTS `Disease`;
CREATE TABLE `Disease` (
  `DiseaseID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100)  NOT NULL,
  `Description` varchar(500)  NOT NULL,
  PRIMARY KEY (`DiseaseID`),
  UNIQUE `UnqName` (`Name`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Disease_PatientDetails`
--

DROP TABLE IF EXISTS `Disease_PatientDetails`;
CREATE TABLE `Disease_PatientDetails` (
  `DiseaseID` int NOT NULL,
  `PatientDetailsID` int NOT NULL,
  `Onset` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Remitted` datetime DEFAULT NULL,
  PRIMARY KEY (`DiseaseID`,`PatientDetailsID`),
  KEY `PatientDetailsID` (`PatientDetailsID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `DoctorDetails`
--

DROP TABLE IF EXISTS `DoctorDetails`;
CREATE TABLE `DoctorDetails` (
  `DoctorDetailsID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `Specialist` varchar(100)  NOT NULL,
  `MedicalLicenceNumber` varchar(50)  NOT NULL,
  `YearsOfExperience` int NOT NULL,
  `MedicalSchool` varchar(100)  NOT NULL,
  `Certificates` varchar(100)  NOT NULL,
  `LanguagesSpoken` json NOT NULL,
  PRIMARY KEY (`DoctorDetailsID`),
  KEY `UserID` (`UserID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Doctor_Patient`
--

DROP TABLE IF EXISTS `Doctor_Patient`;
CREATE TABLE `Doctor_Patient` (
  `PatientDetailsID` int NOT NULL,
  `DoctorDetailsID` int NOT NULL,
  `IsPrimaryDoctor` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`PatientDetailsID`,`DoctorDetailsID`),
  KEY `DoctorDetailsID` (`DoctorDetailsID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Institute`
--

DROP TABLE IF EXISTS `Institute`;
CREATE TABLE `Institute` (
  `InstituteID` smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` varchar(100)  NOT NULL,
  `AddressLine1` varchar(60)  NOT NULL,
  `AddressLine2` varchar(60)  DEFAULT NULL,
  `City` varchar(30)  NOT NULL,
  `StateProvinceCode` varchar(3)  NOT NULL,
  `Country` varchar(2)  NOT NULL,
  `PostalCode` varchar(15)  NOT NULL,
  `DeletedOn` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`InstituteID`),
  UNIQUE `UnqName` (`Name`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Log`
--

DROP TABLE IF EXISTS `Log`;
CREATE TABLE `Log` (
  `LogID` INT NOT NULL AUTO_INCREMENT,
  `ActionType` VARCHAR(50) NOT NULL,
  `TableName` VARCHAR(100) NULL,
  `Query` TEXT NULL,
  `ActionTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `PerformedBy` VARCHAR(100) NULL,
  PRIMARY KEY (`LogID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Medicine`
--

DROP TABLE IF EXISTS `Medicine`;
CREATE TABLE `Medicine` (
  `MedicineId` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100)  NOT NULL,
  `Brand` varchar(100)  NOT NULL,
  `Description` varchar(500)  NOT NULL,
  PRIMARY KEY (`MedicineId`),
  UNIQUE `UnqName` (`Name`)
);

-- --------------------------------------------------------

--
-- Table structure for table `PatientDetails`
--

DROP TABLE IF EXISTS `PatientDetails`;
CREATE TABLE `PatientDetails` (
  `PatientDetailsID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `ABOBloodType` enum('A','B','AB','O')  NOT NULL,
  `RhBloodType` enum('+','-')  NOT NULL,
  `EmergencyContact` varchar(20)  NOT NULL,
  `DOB` date NOT NULL,
  PRIMARY KEY (`PatientDetailsID`),
  KEY `UserID` (`UserID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Prescription`
--

DROP TABLE IF EXISTS `Prescription`;
CREATE TABLE `Prescription` (
  `PrescriptionID` int NOT NULL AUTO_INCREMENT,
  `PatientUserID` int NOT NULL,
  `DoctorUserID` int NOT NULL,
  `PreviousPrescriptionID` int DEFAULT NULL,
  `MedicineID` int NOT NULL,
  `TotalDose` varchar(50)  NOT NULL,
  `Remark` varchar(500)  NOT NULL,
  `PrescribedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`PrescriptionID`),
  KEY `PatientID` (`PatientUserID`),
  KEY `DoctorID` (`DoctorUserID`),
  KEY `MedicineID` (`MedicineID`),
  KEY `PreviousPrescriptionID` (`PreviousPrescriptionID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `PrescriptionDetail`
--

DROP TABLE IF EXISTS `PrescriptionDetail`;
CREATE TABLE `PrescriptionDetail` (
  `PrescriptionDetailID` int NOT NULL AUTO_INCREMENT,
  `PrescriptionID` int NOT NULL,
  `IsTakeOnEffect` tinyint(1) NOT NULL DEFAULT '0',
  `StartOn` datetime DEFAULT NULL,
  `EndOn` datetime DEFAULT NULL,
  `Dose` varchar(50)  NOT NULL,
  `IntervalMinutes` int DEFAULT NULL,
  `Remark` varchar(500)  NOT NULL,
  PRIMARY KEY (`PrescriptionDetailID`),
  KEY `PrescriptionID` (`PrescriptionID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Prescription_SideEffect`
--

DROP TABLE IF EXISTS `Prescription_SideEffect`;
CREATE TABLE `Prescription_SideEffect` (
  `PrescriptionID` int NOT NULL,
  `SideEffectID` int NOT NULL,
  `ReportedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`PrescriptionID`,`SideEffectID`),
  KEY `SideEffectID` (`SideEffectID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Reminder`
--

DROP TABLE IF EXISTS `Reminder`;
CREATE TABLE `Reminder` (
  `ReminderID` int NOT NULL AUTO_INCREMENT,
  `StartOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `EndOn` datetime DEFAULT NULL,
  `IntervalMinutes` int DEFAULT NULL,
  `PrescriptionDetailID` int DEFAULT NULL,
  `AppointmentID` int DEFAULT NULL,
  PRIMARY KEY (`ReminderID`),
  KEY `PrescriptionDetailID` (`PrescriptionDetailID`),
  KEY `AppointmentID` (`AppointmentID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `SideEffect`
--

DROP TABLE IF EXISTS `SideEffect`;
CREATE TABLE `SideEffect` (
  `SideEffectID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100)  NOT NULL,
  `Description` varchar(500)  NOT NULL,
  PRIMARY KEY (`SideEffectID`),
  UNIQUE `UnqName` (`Name`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Symptom`
--

DROP TABLE IF EXISTS `Symptom`;
CREATE TABLE `Symptom` (
  `SymptomID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`SymptomID`),
  UNIQUE `UnqName` (`Name`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Symptom_PatientDetails`
--

DROP TABLE IF EXISTS `Symptom_PatientDetails`;
CREATE TABLE `Symptom_PatientDetails` (
  `SymptomID` int NOT NULL,
  `PatientDetailsID` int NOT NULL,
  `Onset` datetime NOT NULL,
  `Remitted` datetime DEFAULT NULL,
  PRIMARY KEY (`SymptomID`,`PatientDetailsID`),
  KEY `PatientDetailsID` (`PatientDetailsID`)
);

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(100) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `UserType` enum('superadmin','admin','doctor','patient') NOT NULL,
  `FirstName` varchar(100) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `Phone` varchar(25) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `Identification` varchar(20) NOT NULL,
  `Gender` enum('M','F') NOT NULL,
  `InstituteID` smallint UNSIGNED DEFAULT NULL,
  `DeletedOn` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE `UnqUsername` (`Username`),
  KEY `InstituteID` (`InstituteID`)
);

-- 
-- Constraints for table relations
-- 
ALTER table `Appointment`
  ADD CONSTRAINT `Appointment_ibfk_1` FOREIGN KEY (`PatientUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Appointment_ibfk_2` FOREIGN KEY (`DoctorUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Compliance`
  ADD CONSTRAINT `Compliance_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Disease_PatientDetails`
  ADD CONSTRAINT `Disease_PatientDetails_ibfk_1` FOREIGN KEY (`DiseaseID`) REFERENCES `Disease` (`DiseaseID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Disease_PatientDetails_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `PatientDetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `DoctorDetails`
  ADD CONSTRAINT `DoctorDetails_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Doctor_Patient`
  ADD CONSTRAINT `Doctor_Patient_ibfk_1` FOREIGN KEY (`DoctorDetailsID`) REFERENCES `DoctorDetails` (`DoctorDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Doctor_Patient_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `PatientDetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `PatientDetails`
  ADD CONSTRAINT `PatientDetails_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `PatientDetails_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `Prescription`
  ADD CONSTRAINT `Prescription_ibfk_2` FOREIGN KEY (`DoctorUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_ibfk_3` FOREIGN KEY (`PreviousPrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_ibfk_4` FOREIGN KEY (`MedicineID`) REFERENCES `Medicine` (`MedicineId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_ibfk_5` FOREIGN KEY (`PatientUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `PrescriptionDetail`
  ADD CONSTRAINT `PrescriptionDetail_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Prescription_SideEffect`
  ADD CONSTRAINT `Prescription_SideEffect_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_SideEffect_ibfk_2` FOREIGN KEY (`SideEffectID`) REFERENCES `SideEffect` (`SideEffectID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Reminder`
  ADD CONSTRAINT `Reminder_ibfk_1` FOREIGN KEY (`PrescriptionDetailID`) REFERENCES `PrescriptionDetail` (`PrescriptionDetailID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Reminder_ibfk_2` FOREIGN KEY (`AppointmentID`) REFERENCES `Appointment` (`AppointmentID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Symptom_PatientDetails`
  ADD CONSTRAINT `Symptom_PatientDetails_ibfk_1` FOREIGN KEY (`SymptomID`) REFERENCES `Symptom` (`SymptomID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Symptom_PatientDetails_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `PatientDetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Users`
  ADD CONSTRAINT `Users_ibfk_1` FOREIGN KEY (`InstituteID`) REFERENCES `Institute` (`InstituteID`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

-- -Triggers and procedures below

DROP TRIGGER IF EXISTS before_insert_user_action_log;
CREATE TRIGGER before_insert_user_action_log
BEFORE INSERT ON log
FOR EACH ROW
BEGIN
    IF NEW.PerformedBy IS NULL OR NEW.PerformedBy = '' THEN
        SET NEW.PerformedBy = CURRENT_USER();
    END IF;
END;

DROP TRIGGER IF EXISTS after_prescriptiondetail_insert;

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

-- ------------------------------
-- Add Doctor Stored Procedure --
-- ------------------------------
DROP PROCEDURE IF EXISTS AddDoctorData;
CREATE PROCEDURE AddDoctorData(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_Specialization VARCHAR(100),
    IN p_MedicalLicenceNumber VARCHAR(50),
    IN p_YearsOfExperience INT,
    IN p_MedicalSchool VARCHAR(100),
    IN p_Certificates VARCHAR(100),
    IN p_LanguagesSpoken JSON,
    OUT p_UserID INT,
    OUT p_Success BOOLEAN
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Success = FALSE;
        SET p_UserID = NULL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO users (
        Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender, InstituteID
    ) VALUES (
        p_Username, p_Email, 'doctor',
        p_FirstName, p_LastName, p_Phone,
        SHA2(p_Password, 256),
        p_Identification, p_Gender, p_InstituteID
    );

    SET p_UserID = LAST_INSERT_ID();
            
    INSERT INTO doctordetails (
        UserID, Specialist, MedicalLicenceNumber, YearsOfExperience,
        MedicalSchool, Certificates, LanguagesSpoken
    ) VALUES (
        p_UserID, p_Specialization, p_MedicalLicenceNumber, p_YearsOfExperience,
        p_MedicalSchool, p_Certificates, p_LanguagesSpoken
    );

    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddDoctor(''', p_Username, ''',''', p_Email, ''',''', 
               p_FirstName, ''',''', p_LastName, ''',''', p_Phone, ''',''',
               p_Password, ''',''', p_Identification, ''',''', p_Gender, ''',',
               p_InstituteID, ');')
    );
    
    COMMIT;
    SET p_Success = TRUE;
END;

-- Procedure 2: Create MySQL account (only if data insert succeeded)
DROP PROCEDURE IF EXISTS CreateDoctorMySQLAccount;
CREATE PROCEDURE CreateDoctorMySQLAccount(
    IN p_Username VARCHAR(100),
    IN p_Password VARCHAR(255)
)
BEGIN
    SET @create_sql = CONCAT(
        'CREATE USER IF NOT EXISTS `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost` IDENTIFIED BY ', QUOTE(p_Password), ';'
    );
    PREPARE stmt1 FROM @create_sql;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    SET @grant_sql = CONCAT(
        'GRANT SELECT, INSERT, UPDATE ON `medmanagedb`.`users` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt2 FROM @grant_sql;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    SET @grant_sql2 = CONCAT(
        'GRANT SELECT, INSERT, UPDATE ON `medmanagedb`.`doctordetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt3 FROM @grant_sql2;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    FLUSH PRIVILEGES;
END;

-- Main Procedure: Orchestrates both operations
DROP PROCEDURE IF EXISTS AddDoctor;
CREATE PROCEDURE AddDoctor(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(259),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_Specialization VARCHAR(100),
    IN p_MedicalLicenceNumber VARCHAR(50),
    IN p_YearsOfExperience INT,
    IN p_MedicalSchool VARCHAR(100),
    IN p_Certificates VARCHAR(100),
    IN p_LanguagesSpoken JSON
)
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success BOOLEAN DEFAULT FALSE;
    
    -- Step 1: Insert data with transaction protection
    CALL AddDoctorData(
        p_Username, p_Email, p_FirstName, p_LastName,
        p_Phone, p_Password, p_Identification, p_Gender,
        p_InstituteID, p_Specialization, p_MedicalLicenceNumber,
        p_YearsOfExperience, p_MedicalSchool, p_Certificates,
        p_LanguagesSpoken, v_UserID, v_Success
    );
    
    -- Step 2: Only create MySQL account if data insert succeeded
    IF v_Success THEN
        CALL CreateDoctorMySQLAccount(p_Username, p_Password);
        SELECT v_UserID AS UserID, 'Doctor added successfully with MySQL account' AS Message;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Failed to add doctor data. MySQL account not created.';
    END IF;
END;

-- ---------------------------------
-- Delete Doctor Stored Procedure --
-- ---------------------------------

DROP PROCEDURE IF EXISTS DeleteDoctor;

CREATE PROCEDURE DeleteDoctor(
    IN p_UserID INT
)
BEGIN
    DECLARE v_Username VARCHAR(100);
    
    START TRANSACTION;
    
    -- Throw an error if doctor user by that ID does not exist
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE UserID = p_UserID AND UserType = 'doctor'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor user not found';
    END IF;

    -- Get the doctor's username
    SELECT Username INTO v_Username 
    FROM users
    WHERE UserID = p_UserID AND UserType = 'doctor';

    -- Soft delete the doctor from the User table
    UPDATE users SET DeletedOn = NOW() WHERE UserID = p_UserID AND UserType = 'doctor';

    -- Drop the MySQL user if it exists
    IF v_Username IS NOT NULL THEN
        SET @dropUserQuery = CONCAT('DROP USER IF EXISTS \'', v_Username, '\'@\'%\';');
        PREPARE stmt FROM @dropUserQuery;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;

    -- Log the deletion action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'DROP',
        'users',
        CONCAT('CALL DeleteDoctor(', p_UserID, ');')
    );
    
    COMMIT;
END;

-- -------------------------------
-- Edit Doctor Stored Procedure --
-- -------------------------------

DROP PROCEDURE IF EXISTS UpdateDoctor;

CREATE PROCEDURE UpdateDoctor(
    IN p_UserID INT,
    IN p_TableName VARCHAR(50),
    IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    START TRANSACTION;
    
    -- Check if doctor exists
    IF NOT EXISTS (
        SELECT 1 FROM users WHERE UserID = p_UserID AND UserType = 'doctor'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor user not found';
    END IF;
    
    -- Update the specified table
    IF p_TableName = 'users' THEN
        SET @sql = CONCAT('UPDATE users SET ', p_FieldName, ' = ? WHERE UserID = ? AND UserType = ''doctor''');
    ELSEIF p_TableName = 'doctordetails' THEN
        SET @sql = CONCAT('UPDATE doctordetails SET ', p_FieldName, ' = ? WHERE DoctorID = ?');
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid table name. Use ''users'' or ''doctordetails''';
    END IF;
    
    PREPARE stmt FROM @sql;
    SET @newValue = p_NewValue;
    SET @userId = p_UserID;
    EXECUTE stmt USING @newValue, @userId;
    DEALLOCATE PREPARE stmt;

    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        p_TableName,
        CONCAT('CALL UpdateDoctor(', p_UserID, ', ''', p_TableName, ''', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
    
    COMMIT;
END;

-- ---------------------------------
-- Filter Doctor Stored Procedure --
-- ---------------------------------
DROP PROCEDURE IF EXISTS FilterDoctors;
CREATE PROCEDURE FilterDoctors(
    IN p_DoctorDetailsID INT,
    IN p_UserID INT,
    IN p_Specialist VARCHAR(100),
    IN p_MedicalLicenceNumber VARCHAR(50),
    IN p_YearsOfExperience INT,
    IN p_MedicalSchool VARCHAR(100),
    IN p_Certificates VARCHAR(100),
    IN p_LanguagesSpoken VARCHAR(100)
)
BEGIN
    SELECT *
    FROM DoctorDetails
    WHERE (p_DoctorDetailsID IS NULL OR DoctorDetailsID = p_DoctorDetailsID)
        AND (p_UserID IS NULL OR UserID = p_UserID)
        AND (p_Specialist IS NULL OR Specialist LIKE CONCAT('%', p_Specialist, '%'))
        AND (p_MedicalLicenceNumber IS NULL OR MedicalLicenceNumber LIKE CONCAT('%', p_MedicalLicenceNumber, '%'))
        AND (p_YearsOfExperience IS NULL OR YearsOfExperience = p_YearsOfExperience)
        AND (p_MedicalSchool IS NULL OR MedicalSchool LIKE CONCAT('%', p_MedicalSchool, '%'))
        AND (p_Certificates IS NULL OR Certificates LIKE CONCAT('%', p_Certificates, '%'))
        AND (p_LanguagesSpoken IS NULL OR JSON_SEARCH(LanguagesSpoken, 'one', CONCAT('%', p_LanguagesSpoken, '%')) IS NOT NULL)
    ORDER BY DoctorDetailsID;
END;

-- ----------------------
-- add medicine procedure
-- ----------------------

DROP PROCEDURE IF EXISTS AddMedicine;

CREATE PROCEDURE AddMedicine(
    IN p_Name VARCHAR(100),
    IN p_Brand VARCHAR(100),
    IN p_Description VARCHAR(500)
)
BEGIN
    INSERT INTO Medicine (Name, Brand, Description)
    VALUES (p_Name, p_Brand, p_Description);
    
    -- Log the action
    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'Medicine',
        CONCAT('CALL AddMedicine(''', p_Name, ''', ''', p_Brand, ''', ''', p_Description, ''');')
    );
    
    -- Return the newly created MedicineId
    SELECT LAST_INSERT_ID() AS MedicineId;
END;


-- To add medicines (example below)
-- CALL AddMedicine('Ibuprofen', 'Advil', 'Anti-inflammatory and pain reliever');''

-- ----------------------
-- add patient 
-- ----------------------

DROP PROCEDURE IF EXISTS AddPatient;

CREATE PROCEDURE AddPatient(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(255),
    IN p_FirstName VARCHAR(100),
    IN p_LastName VARCHAR(100),
    IN p_Phone VARCHAR(25),
    IN p_Password VARCHAR(255),
    IN p_Identification VARCHAR(20),
    IN p_Gender CHAR(1),
    IN p_InstituteID SMALLINT,
    IN p_ABOBloodType ENUM('A','B','AB','O'),
    IN p_RhBloodType ENUM('+','-'),
    IN p_EmergencyContact VARCHAR(20),
    IN p_DOB DATE
)
BEGIN
    DECLARE v_UserID INT;
    
    INSERT INTO users (
        Username, Email, UserType,
        FirstName, LastName, Phone, PasswordHash,
        Identification, Gender, InstituteID
    ) VALUES (
        p_Username, p_Email, 'patient',
        p_FirstName, p_LastName, p_Phone,
        SHA2(p_Password, 256),
        p_Identification, p_Gender, p_InstituteID
    );

    SET v_UserID = LAST_INSERT_ID();

    INSERT INTO patientdetails (
        UserID, ABOBloodType, RhBloodType, EmergencyContact, DOB
    ) VALUES (
        v_UserID, p_ABOBloodType, p_RhBloodType, p_EmergencyContact, p_DOB
    );

    -- Create MySQL account
    SET @create_sql = CONCAT(
        'CREATE USER IF NOT EXISTS `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost` IDENTIFIED BY ', QUOTE(p_Password), ';'
    );
    PREPARE stmt1 FROM @create_sql;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- Grant SELECT and UPDATE on users table (so they can edit their own user info)
    SET @grant_sql = CONCAT(
        'GRANT SELECT, UPDATE ON `medmanagedb`.`users` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt2 FROM @grant_sql;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    -- View their patient details (READ ONLY - cannot change blood type, DOB, etc.)
    SET @grant_sql2 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`patientdetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt3 FROM @grant_sql2;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    -- View their prescriptions (READ ONLY)
    SET @grant_sql3 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`prescription` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt4 FROM @grant_sql3;
    EXECUTE stmt4;
    DEALLOCATE PREPARE stmt4;

    -- View prescription details (READ ONLY)
    SET @grant_sql4 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`prescriptiondetail` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt5 FROM @grant_sql4;
    EXECUTE stmt5;
    DEALLOCATE PREPARE stmt5;

    -- View appointments (READ ONLY)
    SET @grant_sql5 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`appointment` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt6 FROM @grant_sql5;
    EXECUTE stmt6;
    DEALLOCATE PREPARE stmt6;

    -- View medicine information (READ ONLY)
    SET @grant_sql6 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`medicine` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt7 FROM @grant_sql6;
    EXECUTE stmt7;
    DEALLOCATE PREPARE stmt7;

    -- View compliance (their medication tracking) - READ ONLY
    SET @grant_sql7 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`compliance` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt8 FROM @grant_sql7;
    EXECUTE stmt8;
    DEALLOCATE PREPARE stmt8;

    -- View reminders (READ ONLY)
    SET @grant_sql8 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`reminder` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt9 FROM @grant_sql8;
    EXECUTE stmt9;
    DEALLOCATE PREPARE stmt9;

    -- View doctor details (to see their doctor's info) - READ ONLY
    SET @grant_sql9 = CONCAT(
        'GRANT SELECT ON `medmanagedb`.`doctordetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt10 FROM @grant_sql9;
    EXECUTE stmt10;
    DEALLOCATE PREPARE stmt10;

    FLUSH PRIVILEGES;

    INSERT INTO log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddPatient(''', p_Username, ''',''', p_Email, ''',''', 
               p_FirstName, ''',''', p_LastName, ''',''', p_Phone, ''',''',
               p_Password, ''',''', p_Identification, ''',''', p_Gender, ''',',
               p_InstituteID, ',''', p_ABOBloodType, ''',''', p_RhBloodType, ''',''',
               p_EmergencyContact, ''',''', p_DOB, ''');')
    );
    
    -- Return the newly created patient info
    SELECT v_UserID AS UserID, 'Patient added successfully' AS Message;
END;

-- ----------------------
-- add reminder procedure
-- ----------------------

DROP PROCEDURE IF EXISTS AddPrescriptionReminder; 
CREATE PROCEDURE AddPrescriptionReminder(
    IN p_StartOn DATETIME,
    IN p_EndOn DATETIME,
    IN p_IntervalMinutes INT,
    IN p_PrescriptionDetailID INT
)
BEGIN
    -- Insert the reminder
    INSERT INTO Reminder (StartOn, EndOn, IntervalMinutes, PrescriptionDetailID)
    VALUES (p_StartOn, p_EndOn, p_IntervalMinutes, p_PrescriptionDetailID);

    -- Simple log (because triggers do not have user context)
    INSERT INTO log (ActionType, TableName, Query, PerformedBy)
    VALUES (
        'INSERT',
        'Reminder',
        CONCAT(
            'Auto reminder created for PrescriptionDetailID = ',
            p_PrescriptionDetailID
        ),
        'SYSTEM'
    );
END;

-- CALL AddPrescriptionReminder('2024-07-01 09:00:00', '2024-07-10 09:00:00', 240, 5); -- Example call to the procedure for prescription reminder
-- CALL AddPrescriptionReminder('2024-07-15 10:00 :00', '2024-07-15 11:00:00', 0, 3); -- Example call to the procedure for appointment reminder