-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: mysql
-- Generation Time: Nov 17, 2025 at 12:00 PM
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
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment` (
  `AppointmentID` int NOT NULL,
  `PatientDetailID` int NOT NULL,
  `DoctorDetailID` int NOT NULL,
  `AppointmentOn` datetime NOT NULL,
  `Details` varchar(500) COLLATE utf8mb4_general_ci NOT NULL,
  `IsDoctorAccept` tinyint(1) DEFAULT NULL,
  `IsPatientAccept` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all appointments made and scheduled. The boolean fields are used to check if both pateitn and doctor are able to accept the appointment.';

-- --------------------------------------------------------

--
-- Table structure for table `compliance`
--

DROP TABLE IF EXISTS `compliance`;
CREATE TABLE `compliance` (
  `ComplianceID` int NOT NULL,
  `TakenOn` datetime NOT NULL,
  `PrescriptionID` int NOT NULL,
  `DoseTaken` varchar(50) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores whenever the patient takes a dose';

-- --------------------------------------------------------

--
-- Table structure for table `disease`
--

DROP TABLE IF EXISTS `disease`;
CREATE TABLE `disease` (
  `DiseaseID` int NOT NULL,
  `Name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='A record of diseases that the patients has contracted';

-- --------------------------------------------------------

--
-- Table structure for table `disease_patientdetails`
--

DROP TABLE IF EXISTS `disease_patientdetails`;
CREATE TABLE `disease_patientdetails` (
  `DiseaseID` int NOT NULL,
  `PatientDetailsID` int NOT NULL,
  `Onset` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Remitted` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intermediate table for many to many relation representing what diseases the patient has contracted.';

-- --------------------------------------------------------

--
-- Table structure for table `doctordetails`
--

DROP TABLE IF EXISTS `doctordetails`;
CREATE TABLE `doctordetails` (
  `DoctorDetailsID` int NOT NULL,
  `UserID` int NOT NULL,
  `Specialist` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `MedicalLicenceNumber` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `YearsOfExperience` int NOT NULL,
  `MedicalSchool` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Certificates` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `LanguagesSpoken` json NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores Doctor details of a user';

-- --------------------------------------------------------

--
-- Table structure for table `doctor_patient`
--

DROP TABLE IF EXISTS `doctor_patient`;
CREATE TABLE `doctor_patient` (
  `PatientDetailsID` int NOT NULL,
  `DoctorDetailsID` int NOT NULL,
  `IsPrimaryDoctor` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intermediate table to represent the Doctor and which Patient is assigned to them.';

-- --------------------------------------------------------

--
-- Table structure for table `institute`
--

DROP TABLE IF EXISTS `institute`;
CREATE TABLE `institute` (
  `InstituteID` smallint UNSIGNED NOT NULL,
  `Name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `AddressLine1` varchar(60) COLLATE utf8mb4_general_ci NOT NULL,
  `AddressLine2` varchar(60) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `City` varchar(30) COLLATE utf8mb4_general_ci NOT NULL,
  `StateProvinceCode` varchar(3) COLLATE utf8mb4_general_ci NOT NULL,
  `Country` varchar(2) COLLATE utf8mb4_general_ci NOT NULL,
  `PostalCode` varchar(15) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Store all institutes that are using the system';

-- --------------------------------------------------------

--
-- Table structure for table `Log`
--

DROP TABLE IF EXISTS `Log`;
CREATE TABLE `Log` (
  `LogID` int NOT NULL,
  `ActionType` enum('insert','update','delete') COLLATE utf8mb4_general_ci NOT NULL,
  `TableName` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `Query` text COLLATE utf8mb4_general_ci NOT NULL,
  `CreatedOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `PerformedBy` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medicine`
--

DROP TABLE IF EXISTS `medicine`;
CREATE TABLE `medicine` (
  `MedicineId` int NOT NULL,
  `Name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Brand` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(500) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Record of all possible Medicine';

-- --------------------------------------------------------

--
-- Table structure for table `patientdetails`
--

DROP TABLE IF EXISTS `patientdetails`;
CREATE TABLE `patientdetails` (
  `PatientDetailsID` int NOT NULL,
  `UserID` int NOT NULL,
  `ABOBloodType` enum('A','B','AB','O') COLLATE utf8mb4_general_ci NOT NULL,
  `RhBloodType` enum('+','-') COLLATE utf8mb4_general_ci NOT NULL,
  `EmergencyContact` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `DOB` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores patient details of a user';

-- --------------------------------------------------------

--
-- Table structure for table `prescription`
--

DROP TABLE IF EXISTS `prescription`;
CREATE TABLE `prescription` (
  `PrescriptionID` int NOT NULL,
  `PatientDetailID` int NOT NULL,
  `DoctorDetailID` int NOT NULL,
  `PreviousPrescriptionID` int DEFAULT NULL,
  `MedicineID` int NOT NULL,
  `TotalDose` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `Remark` varchar(500) COLLATE utf8mb4_general_ci NOT NULL,
  `PrescribedOn` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all prescriptions of a patient. Specific details of dosage and when to take them is stored in a "PatientDetails" table';

-- --------------------------------------------------------

--
-- Table structure for table `prescriptiondetail`
--

DROP TABLE IF EXISTS `prescriptiondetail`;
CREATE TABLE `prescriptiondetail` (
  `PrescriptionDetailID` int NOT NULL,
  `PrescriptionID` int NOT NULL,
  `IsTakeOnEffect` tinyint(1) NOT NULL DEFAULT '0',
  `StartOn` datetime DEFAULT NULL,
  `EndOn` datetime DEFAULT NULL,
  `Dose` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `IntervalMinutes` int DEFAULT NULL,
  `Remark` varchar(500) COLLATE utf8mb4_general_ci NOT NULL
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
-- Table structure for table `reminder`
--

DROP TABLE IF EXISTS `reminder`;
CREATE TABLE `reminder` (
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
  `Name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Description` varchar(100) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores any side effects that may have occurred when patient takes the medication';

-- --------------------------------------------------------

--
-- Table structure for table `symptom`
--

DROP TABLE IF EXISTS `symptom`;
CREATE TABLE `symptom` (
  `SymptomID` int NOT NULL,
  `PatientDetailsID` int NOT NULL,
  `Description` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `CreatedOn` datetime NOT NULL
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
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `UserID` int NOT NULL,
  `Username` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `UserType` enum('superadmin','admin','doctor','patient') COLLATE utf8mb4_general_ci NOT NULL,
  `FirstName` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `LastName` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `Phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `Identification` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `Gender` enum('M','F') COLLATE utf8mb4_general_ci NOT NULL,
  `InstituteID` smallint UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all users using the system';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointment`
--
ALTER TABLE `appointment`
  ADD PRIMARY KEY (`AppointmentID`),
  ADD KEY `DoctorUserID` (`DoctorDetailID`),
  ADD KEY `PatientDetailID` (`PatientDetailID`);

--
-- Indexes for table `compliance`
--
ALTER TABLE `compliance`
  ADD PRIMARY KEY (`ComplianceID`),
  ADD KEY `PrescriptionID` (`PrescriptionID`);

--
-- Indexes for table `disease`
--
ALTER TABLE `disease`
  ADD PRIMARY KEY (`DiseaseID`);

--
-- Indexes for table `disease_patientdetails`
--
ALTER TABLE `disease_patientdetails`
  ADD PRIMARY KEY (`DiseaseID`,`PatientDetailsID`),
  ADD KEY `PatientDetailsID` (`PatientDetailsID`);

--
-- Indexes for table `doctordetails`
--
ALTER TABLE `doctordetails`
  ADD PRIMARY KEY (`DoctorDetailsID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `doctor_patient`
--
ALTER TABLE `doctor_patient`
  ADD PRIMARY KEY (`PatientDetailsID`,`DoctorDetailsID`),
  ADD KEY `doctor_patient_ibfk_1` (`DoctorDetailsID`);

--
-- Indexes for table `institute`
--
ALTER TABLE `institute`
  ADD PRIMARY KEY (`InstituteID`);

--
-- Indexes for table `Log`
--
ALTER TABLE `Log`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `medicine`
--
ALTER TABLE `medicine`
  ADD PRIMARY KEY (`MedicineId`);

--
-- Indexes for table `patientdetails`
--
ALTER TABLE `patientdetails`
  ADD PRIMARY KEY (`PatientDetailsID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `prescription`
--
ALTER TABLE `prescription`
  ADD PRIMARY KEY (`PrescriptionID`),
  ADD KEY `PatientID` (`PatientDetailID`),
  ADD KEY `DoctorID` (`DoctorDetailID`),
  ADD KEY `MedicineID` (`MedicineID`),
  ADD KEY `PreviousPrescriptionID` (`PreviousPrescriptionID`);

--
-- Indexes for table `prescriptiondetail`
--
ALTER TABLE `prescriptiondetail`
  ADD KEY `PrescriptionID` (`PrescriptionID`);

--
-- Indexes for table `Prescription_SideEffect`
--
ALTER TABLE `Prescription_SideEffect`
  ADD PRIMARY KEY (`PrescriptionID`,`SideEffectID`),
  ADD KEY `SideEffectID` (`SideEffectID`);

--
-- Indexes for table `reminder`
--
ALTER TABLE `reminder`
  ADD PRIMARY KEY (`ReminderID`),
  ADD KEY `PrescriptionDetailID` (`PrescriptionDetailID`),
  ADD KEY `AppointmentID` (`AppointmentID`);

--
-- Indexes for table `SideEffect`
--
ALTER TABLE `SideEffect`
  ADD PRIMARY KEY (`SideEffectID`);

--
-- Indexes for table `symptom`
--
ALTER TABLE `symptom`
  ADD PRIMARY KEY (`SymptomID`),
  ADD KEY `MedicalDetailsID` (`PatientDetailsID`);

--
-- Indexes for table `Symptom_PatientDetails`
--
ALTER TABLE `Symptom_PatientDetails`
  ADD PRIMARY KEY (`SymptomID`,`PatientDetailsID`) USING BTREE,
  ADD KEY `PatientDetailsID` (`PatientDetailsID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD KEY `InstituteID` (`InstituteID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointment`
--
ALTER TABLE `appointment`
  MODIFY `AppointmentID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `compliance`
--
ALTER TABLE `compliance`
  MODIFY `ComplianceID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `disease`
--
ALTER TABLE `disease`
  MODIFY `DiseaseID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `institute`
--
ALTER TABLE `institute`
  MODIFY `InstituteID` smallint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Log`
--
ALTER TABLE `Log`
  MODIFY `LogID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medicine`
--
ALTER TABLE `medicine`
  MODIFY `MedicineId` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `prescription`
--
ALTER TABLE `prescription`
  MODIFY `PrescriptionID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reminder`
--
ALTER TABLE `reminder`
  MODIFY `ReminderID` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointment`
--
ALTER TABLE `appointment`
  ADD CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`PatientDetailID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`DoctorDetailID`) REFERENCES `doctordetails` (`DoctorDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `compliance`
--
ALTER TABLE `compliance`
  ADD CONSTRAINT `compliance_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `disease_patientdetails`
--
ALTER TABLE `disease_patientdetails`
  ADD CONSTRAINT `disease_patientdetails_ibfk_1` FOREIGN KEY (`DiseaseID`) REFERENCES `disease` (`DiseaseID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `disease_patientdetails_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON UPDATE CASCADE;

--
-- Constraints for table `doctordetails`
--
ALTER TABLE `doctordetails`
  ADD CONSTRAINT `doctordetails_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE;

--
-- Constraints for table `doctor_patient`
--
ALTER TABLE `doctor_patient`
  ADD CONSTRAINT `doctor_patient_ibfk_1` FOREIGN KEY (`DoctorDetailsID`) REFERENCES `doctordetails` (`DoctorDetailsID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `doctor_patient_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON UPDATE CASCADE;

--
-- Constraints for table `patientdetails`
--
ALTER TABLE `patientdetails`
  ADD CONSTRAINT `patientdetails_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE;

--
-- Constraints for table `prescription`
--
ALTER TABLE `prescription`
  ADD CONSTRAINT `prescription_ibfk_3` FOREIGN KEY (`MedicineID`) REFERENCES `medicine` (`MedicineId`) ON UPDATE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_4` FOREIGN KEY (`PreviousPrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_5` FOREIGN KEY (`PatientDetailID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_6` FOREIGN KEY (`DoctorDetailID`) REFERENCES `doctordetails` (`DoctorDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `prescriptiondetail`
--
ALTER TABLE `prescriptiondetail`
  ADD CONSTRAINT `prescriptiondetail_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON UPDATE CASCADE;

--
-- Constraints for table `Prescription_SideEffect`
--
ALTER TABLE `Prescription_SideEffect`
  ADD CONSTRAINT `Prescription_SideEffect_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Prescription_SideEffect_ibfk_2` FOREIGN KEY (`SideEffectID`) REFERENCES `SideEffect` (`SideEffectID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `reminder`
--
ALTER TABLE `reminder`
  ADD CONSTRAINT `reminder_ibfk_1` FOREIGN KEY (`PrescriptionDetailID`) REFERENCES `prescriptiondetail` (`PrescriptionID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `reminder_ibfk_2` FOREIGN KEY (`AppointmentID`) REFERENCES `appointment` (`AppointmentID`) ON UPDATE CASCADE;

--
-- Constraints for table `Symptom_PatientDetails`
--
ALTER TABLE `Symptom_PatientDetails`
  ADD CONSTRAINT `Symptom_PatientDetails_ibfk_1` FOREIGN KEY (`SymptomID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `Symptom_PatientDetails_ibfk_2` FOREIGN KEY (`PatientDetailsID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`InstituteID`) REFERENCES `institute` (`InstituteID`) ON UPDATE CASCADE;
COMMIT;