-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: mysql
-- Generation Time: Nov 17, 2025 at 04:46 PM
-- Server version: 8.0.32
-- PHP Version: 8.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `medmanagedb`
--
DROP DATABASE IF EXISTS `medmanagedb`;
CREATE DATABASE IF NOT EXISTS `medmanagedb` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `medmanagedb`;

-- --------------------------------------------------------

--
-- Table structure for table `Appointment`
--

DROP TABLE IF EXISTS `Appointment`;
CREATE TABLE `Appointment` (
  `AppointmentID` int NOT NULL,
  `PatientUserID` int NOT NULL,
  `DoctorUserID` int NOT NULL,
  `AppointmentOn` datetime NOT NULL,
  `Details` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `IsDoctorAccept` tinyint(1) DEFAULT NULL,
  `IsPatientAccept` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all appointments made and scheduled. The boolean fields are used to check if both pateitn and doctor are able to accept the appointment.';

-- --------------------------------------------------------

--
-- Table structure for table `Compliance`
--

DROP TABLE IF EXISTS `Compliance`;
CREATE TABLE `Compliance` (
  `ComplianceID` int NOT NULL,
  `TakenOn` datetime NOT NULL,
  `PrescriptionID` int NOT NULL,
  `DoseTaken` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores whenever the patient takes a dose';

-- --------------------------------------------------------

--
-- Table structure for table `Disease`
--

DROP TABLE IF EXISTS `Disease`;
CREATE TABLE `Disease` (
  `DiseaseID` int NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='A record of diseases that the patients has contracted';

-- --------------------------------------------------------

--
-- Table structure for table `Disease_PatientDetails`
--

DROP TABLE IF EXISTS `Disease_PatientDetails`;
CREATE TABLE `Disease_PatientDetails` (
  `DiseaseID` int NOT NULL,
  `PatientDetailsID` int NOT NULL,
  `Onset` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Remitted` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intermediate table for many to many relation representing what diseases the patient has contracted.';

-- --------------------------------------------------------

--
-- Table structure for table `DoctorDetails`
--

DROP TABLE IF EXISTS `DoctorDetails`;
CREATE TABLE `DoctorDetails` (
  `DoctorDetailsID` int NOT NULL,
  `UserID` int NOT NULL,
  `Specialist` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `MedicalLicenceNumber` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `YearsOfExperience` int NOT NULL,
  `MedicalSchool` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Certificates` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `LanguagesSpoken` json NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores Doctor details of a user';

-- --------------------------------------------------------

--
-- Table structure for table `Doctor_Patient`
--

DROP TABLE IF EXISTS `Doctor_Patient`;
CREATE TABLE `Doctor_Patient` (
  `PatientDetailsID` int NOT NULL,
  `DoctorDetailsID` int NOT NULL,
  `IsPrimaryDoctor` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intermediate table to represent the Doctor and which Patient is assigned to them.';

-- --------------------------------------------------------

--
-- Table structure for table `Institute`
--

DROP TABLE IF EXISTS `Institute`;
CREATE TABLE `Institute` (
  `InstituteID` smallint UNSIGNED NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AddressLine1` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `AddressLine2` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `City` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `StateProvinceCode` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Country` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `PostalCode` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Store all institutes that are using the system';

-- --------------------------------------------------------

--
-- Table structure for table `Log`
--

DROP TABLE IF EXISTS `Log`;
CREATE TABLE `Log` (
  `LogID` int NOT NULL,
  `ActionType` enum('insert','update','delete') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `TableName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Query` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `CreatedOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `PerformedBy` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Medicine`
--

DROP TABLE IF EXISTS `Medicine`;
CREATE TABLE `Medicine` (
  `MedicineId` int NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Record of all possible Medicine';

-- --------------------------------------------------------

--
-- Table structure for table `PatientDetails`
--

DROP TABLE IF EXISTS `PatientDetails`;
CREATE TABLE `PatientDetails` (
  `PatientDetailsID` int NOT NULL,
  `UserID` int NOT NULL,
  `ABOBloodType` enum('A','B','AB','O') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `RhBloodType` enum('+','-') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `EmergencyContact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `DOB` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores patient details of a user';

-- --------------------------------------------------------

--
-- Table structure for table `Prescription`
--

DROP TABLE IF EXISTS `Prescription`;
CREATE TABLE `Prescription` (
  `PrescriptionID` int NOT NULL,
  `PatientUserID` int NOT NULL,
  `DoctorUserID` int NOT NULL,
  `PreviousPrescriptionID` int DEFAULT NULL,
  `MedicineID` int NOT NULL,
  `TotalDose` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `PrescribedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all prescriptions of a patient. Specific details of dosage and when to take them is stored in a "PatientDetails" table';

-- --------------------------------------------------------

--
-- Table structure for table `PrescriptionDetail`
--

DROP TABLE IF EXISTS `PrescriptionDetail`;
CREATE TABLE `PrescriptionDetail` (
  `PrescriptionDetailID` int NOT NULL,
  `PrescriptionID` int NOT NULL,
  `IsTakeOnEffect` tinyint(1) NOT NULL DEFAULT '0',
  `StartOn` datetime DEFAULT NULL,
  `EndOn` datetime DEFAULT NULL,
  `Dose` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `IntervalMinutes` int DEFAULT NULL,
  `Remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores when the patient is to take the medication.';

-- --------------------------------------------------------

--
-- Table structure for table `Prescription_SideEffect`
--

DROP TABLE IF EXISTS `Prescription_SideEffect`;
CREATE TABLE `Prescription_SideEffect` (
  `PrescriptionID` int NOT NULL,
  `SideEffectID` int NOT NULL,
  `ReportedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Reminder`
--

DROP TABLE IF EXISTS `Reminder`;
CREATE TABLE `Reminder` (
  `ReminderID` int NOT NULL,
  `StartOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `EndOn` datetime DEFAULT NULL,
  `IntervalMinutes` int DEFAULT NULL,
  `PrescriptionDetailID` int DEFAULT NULL,
  `AppointmentID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores upcoming and past reminders';

-- --------------------------------------------------------

--
-- Table structure for table `SideEffect`
--

DROP TABLE IF EXISTS `SideEffect`;
CREATE TABLE `SideEffect` (
  `SideEffectID` int NOT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores any side effects that may have occurred when patient takes the medication';

-- --------------------------------------------------------

--
-- Table structure for table `Symptom`
--

DROP TABLE IF EXISTS `Symptom`;
CREATE TABLE `Symptom` (
  `SymptomID` int NOT NULL,
  `Name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Symptom_PatientDetails`
--

DROP TABLE IF EXISTS `Symptom_PatientDetails`;
CREATE TABLE `Symptom_PatientDetails` (
  `SymptomID` int NOT NULL,
  `PatientDetailsID` int NOT NULL,
  `Onset` datetime NOT NULL,
  `Remitted` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `UserID` int NOT NULL,
  `Username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `UserType` enum('superadmin','admin','doctor','patient') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `FirstName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `LastName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `PasswordHash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Identification` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Gender` enum('M','F') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `InstituteID` smallint UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all users using the system';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Appointment`
--
ALTER TABLE `Appointment`
  ADD PRIMARY KEY (`AppointmentID`),
  ADD KEY `DoctorUserID` (`DoctorUserID`),
  ADD KEY `PatientUserID` (`PatientUserID`);

--
-- Indexes for table `Compliance`
--
ALTER TABLE `Compliance`
  ADD PRIMARY KEY (`ComplianceID`),
  ADD KEY `PrescriptionID` (`PrescriptionID`);

--
-- Indexes for table `Disease`
--
ALTER TABLE `Disease`
  ADD PRIMARY KEY (`DiseaseID`);

--
-- Indexes for table `Disease_PatientDetails`
--
ALTER TABLE `Disease_PatientDetails`
  ADD PRIMARY KEY (`DiseaseID`,`PatientDetailsID`),
  ADD KEY `PatientDetailsID` (`PatientDetailsID`);

--
-- Indexes for table `DoctorDetails`
--
ALTER TABLE `DoctorDetails`
  ADD PRIMARY KEY (`DoctorDetailsID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `Doctor_Patient`
--
ALTER TABLE `Doctor_Patient`
  ADD PRIMARY KEY (`PatientDetailsID`,`DoctorDetailsID`),
  ADD KEY `DoctorDetailsID` (`DoctorDetailsID`);

--
-- Indexes for table `Institute`
--
ALTER TABLE `Institute`
  ADD PRIMARY KEY (`InstituteID`);

--
-- Indexes for table `Log`
--
ALTER TABLE `Log`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `Medicine`
--
ALTER TABLE `Medicine`
  ADD PRIMARY KEY (`MedicineId`);

--
-- Indexes for table `PatientDetails`
--
ALTER TABLE `PatientDetails`
  ADD PRIMARY KEY (`PatientDetailsID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `Prescription`
--
ALTER TABLE `Prescription`
  ADD PRIMARY KEY (`PrescriptionID`),
  ADD KEY `PatientID` (`PatientUserID`),
  ADD KEY `DoctorID` (`DoctorUserID`),
  ADD KEY `MedicineID` (`MedicineID`),
  ADD KEY `PreviousPrescriptionID` (`PreviousPrescriptionID`);

--
-- Indexes for table `PrescriptionDetail`
--
ALTER TABLE `PrescriptionDetail`
  ADD PRIMARY KEY (`PrescriptionDetailID`),
  ADD KEY `PrescriptionID` (`PrescriptionID`);

--
-- Indexes for table `Prescription_SideEffect`
--
ALTER TABLE `Prescription_SideEffect`
  ADD PRIMARY KEY (`PrescriptionID`,`SideEffectID`),
  ADD KEY `SideEffectID` (`SideEffectID`);

--
-- Indexes for table `Reminder`
--
ALTER TABLE `Reminder`
  ADD PRIMARY KEY (`ReminderID`),
  ADD KEY `PrescriptionDetailID` (`PrescriptionDetailID`),
  ADD KEY `AppointmentID` (`AppointmentID`);

--
-- Indexes for table `SideEffect`
--
ALTER TABLE `SideEffect`
  ADD PRIMARY KEY (`SideEffectID`);

--
-- Indexes for table `Symptom`
--
ALTER TABLE `Symptom`
  ADD PRIMARY KEY (`SymptomID`);

--
-- Indexes for table `Symptom_PatientDetails`
--
ALTER TABLE `Symptom_PatientDetails`
  ADD PRIMARY KEY (`SymptomID`,`PatientDetailsID`),
  ADD KEY `PatientDetailsID` (`PatientDetailsID`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`UserID`),
  ADD KEY `InstituteID` (`InstituteID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Appointment`
--
ALTER TABLE `Appointment`
  MODIFY `AppointmentID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Compliance`
--
ALTER TABLE `Compliance`
  MODIFY `ComplianceID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Disease`
--
ALTER TABLE `Disease`
  MODIFY `DiseaseID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `DoctorDetails`
--
ALTER TABLE `DoctorDetails`
  MODIFY `DoctorDetailsID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Institute`
--
ALTER TABLE `Institute`
  MODIFY `InstituteID` smallint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Log`
--
ALTER TABLE `Log`
  MODIFY `LogID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Medicine`
--
ALTER TABLE `Medicine`
  MODIFY `MedicineId` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `PatientDetails`
--
ALTER TABLE `PatientDetails`
  MODIFY `PatientDetailsID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Prescription`
--
ALTER TABLE `Prescription`
  MODIFY `PrescriptionID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `PrescriptionDetail`
--
ALTER TABLE `PrescriptionDetail`
  MODIFY `PrescriptionDetailID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Reminder`
--
ALTER TABLE `Reminder`
  MODIFY `ReminderID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `SideEffect`
--
ALTER TABLE `SideEffect`
  MODIFY `SideEffectID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Symptom`
--
ALTER TABLE `Symptom`
  MODIFY `SymptomID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Users`
--
ALTER TABLE `Users`
  MODIFY `UserID` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

-- 
-- Constraints for table `Appointment`
-- 
ALTER table `Appointment`
  ADD CONSTRAINT `Appointment_ibfk_1` FOREIGN KEY (`PatientUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Appointment_ibfk_2` FOREIGN KEY (`DoctorUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Compliance`
--
ALTER TABLE `Compliance`
  ADD CONSTRAINT `Compliance_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Disease_PatientDetails`
--
ALTER TABLE `Disease_PatientDetails`
  ADD CONSTRAINT `Disease_PatientDetails_ibfk_1` FOREIGN KEY (`DiseaseID`) REFERENCES `Disease` (`DiseaseID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Disease_PatientDetails_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `PatientDetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `DoctorDetails`
--
ALTER TABLE `DoctorDetails`
  ADD CONSTRAINT `DoctorDetails_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Doctor_Patient`
--
ALTER TABLE `Doctor_Patient`
  ADD CONSTRAINT `Doctor_Patient_ibfk_1` FOREIGN KEY (`DoctorDetailsID`) REFERENCES `DoctorDetails` (`DoctorDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Doctor_Patient_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `PatientDetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `PatientDetails`
--
ALTER TABLE `PatientDetails`
  ADD CONSTRAINT `PatientDetails_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `PatientDetails_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `Prescription`
--
ALTER TABLE `Prescription`
  ADD CONSTRAINT `Prescription_ibfk_2` FOREIGN KEY (`DoctorUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_ibfk_3` FOREIGN KEY (`PreviousPrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_ibfk_4` FOREIGN KEY (`MedicineID`) REFERENCES `Medicine` (`MedicineId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_ibfk_5` FOREIGN KEY (`PatientUserID`) REFERENCES `Users` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `PrescriptionDetail`
--
ALTER TABLE `PrescriptionDetail`
  ADD CONSTRAINT `PrescriptionDetail_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Prescription_SideEffect`
--
ALTER TABLE `Prescription_SideEffect`
  ADD CONSTRAINT `Prescription_SideEffect_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `Prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_SideEffect_ibfk_2` FOREIGN KEY (`SideEffectID`) REFERENCES `SideEffect` (`SideEffectID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Reminder`
--
ALTER TABLE `Reminder`
  ADD CONSTRAINT `Reminder_ibfk_1` FOREIGN KEY (`PrescriptionDetailID`) REFERENCES `PrescriptionDetail` (`PrescriptionDetailID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Reminder_ibfk_2` FOREIGN KEY (`AppointmentID`) REFERENCES `Appointment` (`AppointmentID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Symptom_PatientDetails`
--
ALTER TABLE `Symptom_PatientDetails`
  ADD CONSTRAINT `Symptom_PatientDetails_ibfk_1` FOREIGN KEY (`SymptomID`) REFERENCES `Symptom` (`SymptomID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Symptom_PatientDetails_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `PatientDetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Users`
--
ALTER TABLE `Users`
  ADD CONSTRAINT `Users_ibfk_1` FOREIGN KEY (`InstituteID`) REFERENCES `Institute` (`InstituteID`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

---------------------------------
-- Add Doctor Stored Procedure --
---------------------------------
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

    SET v_UserID = LAST_INSERT_ID();

    INSERT INTO doctordetails (
        UserID, Specialist, MedicalLicenceNumber, YearsOfExperience,
        MedicalSchool, Certificates, LanguagesSpoken
    ) VALUES (
        v_UserID, p_Specialization, p_MedicalLicenceNumber, p_YearsOfExperience,
        p_MedicalSchool, p_Certificates, p_LanguagesSpoken
    );

    -- Create MySQL account (requires proper privileges; remove if not needed)
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

     -- Grant privileges on doctordetails as well
    SET @grant_sql2 = CONCAT(
        'GRANT SELECT, INSERT, UPDATE ON `medmanagedb`.`doctordetails` TO `',
        REPLACE(p_Username,'`','``'),
        '`@`localhost`;'
    );
    PREPARE stmt3 FROM @grant_sql2;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    FLUSH PRIVILEGES;

    INSERT INTO user_action_log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'users',
        CONCAT('CALL AddDoctor(''', p_Username, ''',''', p_Email, ''',''', 
               p_FirstName, ''',''', p_LastName, ''',''', p_Phone, ''',''',
               p_Password, ''',''', p_Identification, ''',''', p_Gender, ''',',
               p_InstituteID, ');')
    );
END;

------------------------------------
-- Delete Doctor Stored Procedure --
------------------------------------

DROP PROCEDURE IF EXISTS DeleteDoctor;

CREATE PROCEDURE DeleteDoctor(
    IN p_UserID INT
)
BEGIN
    SET @sql = CONCAT('DELETE FROM users WHERE UserID = ? AND UserType = ''doctor''');
    PREPARE stmt FROM @sql;
    SET @userId = p_UserID;
    EXECUTE stmt USING @userId;
    DEALLOCATE PREPARE stmt;

    INSERT INTO user_action_log (ActionType, TableName, Query)
    VALUES (
        'DROP',
        'users',
        CONCAT('CALL DeleteDoctor(', p_UserID, ');')
    );
END;

----------------------------------
-- Edit Doctor Stored Procedure --
----------------------------------

DROP PROCEDURE IF EXISTS UpdateDoctor;

CREATE PROCEDURE UpdateDoctor(
    IN p_UserID INT,
    IN p_FieldName VARCHAR(50),
    IN p_NewValue VARCHAR(255)
)
BEGIN
    SET @sql = CONCAT('UPDATE users SET ', p_FieldName, ' = ? WHERE UserID = ? AND UserType = ''doctor''');
    PREPARE stmt FROM @sql;
    SET @newValue = p_NewValue;
    SET @userId = p_UserID;
    EXECUTE stmt USING @newValue, @userId;
    DEALLOCATE PREPARE stmt;

    INSERT INTO user_action_log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'users',
        CONCAT('CALL UpdateDoctor(', p_UserID, ', ''', p_FieldName, ''', ''', p_NewValue, ''');')
    );
END;

------------------------------------
-- Filter Doctor Stored Procedure --
------------------------------------
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

