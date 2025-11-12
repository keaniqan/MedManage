-- Active: 1761104084214@@127.0.0.1@3307@medmanagedb
-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 06, 2025 at 05:53 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12
CREATE DATABASE IF NOT EXISTS `medmanagedb` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `medmanagedb`;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */  ;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cos10082_med_manage`hkjkjgjk
--

-- --------------------------------------------------------

--
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment` (
  `AppointmentID` int(11) NOT NULL,
  `PatientID` int(11) NOT NULL,
  `DoctorID` int(11) NOT NULL,
  `AppointmentOn` int(11) NOT NULL,
  `Details` varchar(500) NOT NULL,
  `IsDoctorAccept` tinyint(1) DEFAULT NULL,
  `IsPatientAccept` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all appointments made and scheduled. The boolean fields are used to check if both pateitn and doctor are able to accept the appointment.';

-- --------------------------------------------------------

--
-- Table structure for table `compliance`
--

DROP TABLE IF EXISTS `compliance`;
CREATE TABLE `compliance` (
  `ComplianceID` int(11) NOT NULL,
  `PrescriptionDetailID` int(11) NOT NULL,
  `DoseTaken` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores whenever the patient takes a dose';

-- --------------------------------------------------------

--
-- Table structure for table `disease`
--

DROP TABLE IF EXISTS `disease`;
CREATE TABLE `disease` (
  `DiseaseID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Description` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='A record of diseases that the patients has contracted';

-- --------------------------------------------------------

--
-- Table structure for table `disease_patientdetails`
--

DROP TABLE IF EXISTS `disease_patientdetails`;
CREATE TABLE `disease_patientdetails` (
  `DiseaseID` int(11) NOT NULL,
  `PatientDetailsID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intermediate table for many to many relation representing what diseases the patient has contracted.';

-- --------------------------------------------------------

--
-- Table structure for table `doctordetails`
--

DROP TABLE IF EXISTS `doctordetails`;
CREATE TABLE `doctordetails` (
  `DoctorDetailsID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Title` varchar(100) NOT NULL,
  `MedicalLicenceNumber` varchar(50) NOT NULL,
  `YearsOfExperience` int(11) NOT NULL,
  `MedicalSchool` varchar(100) NOT NULL,
  `Certificates` varchar(100) NOT NULL,
  `LanguagesSpoken` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores Doctor details of a user';

-- --------------------------------------------------------

--
-- Table structure for table `doctor_patient`
--

DROP TABLE IF EXISTS `doctor_patient`;
CREATE TABLE `doctor_patient` (
  `PatientDetailsID` int(11) NOT NULL,
  `DoctorDetailsID` int(11) NOT NULL,
  `IsPrimaryDoctor` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Intermediate table to represent the Doctor and which Patient is assigned to them.';

-- --------------------------------------------------------

--
-- Table structure for table `institute`
--

DROP TABLE IF EXISTS `institute`;
CREATE TABLE `institute` (
  `InstituteID` smallint(5) UNSIGNED NOT NULL,
  `Name` varchar(100) NOT NULL,
  `AddressLine1` varchar(60) NOT NULL,
  `AddressLine2` varchar(60) DEFAULT NULL,
  `City` varchar(30) NOT NULL,
  `StateProvinceCode` varchar(3) NOT NULL,
  `Country` varchar(2) NOT NULL,
  `PostalCode` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Store all institutes that are using the system';

-- --------------------------------------------------------

--
-- Table structure for table `medicine`
--

DROP TABLE IF EXISTS `medicine`;
CREATE TABLE `medicine` (
  `MedicineId` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Brand` varchar(100) NOT NULL,
  `Description` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Record of all possible Medicine';

-- --------------------------------------------------------

--
-- Table structure for table `patientdetails`
--

DROP TABLE IF EXISTS `patientdetails`;
CREATE TABLE `patientdetails` (
  `PatientDetailsID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `ABOBloodType` enum('A','B','AB','O') NOT NULL,
  `RhBloodType` enum('+','-') NOT NULL,
  `EmergencyContact` varchar(20) NOT NULL,
  `DOB` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores patient details of a user';

-- --------------------------------------------------------

--
-- Table structure for table `prescription`
--

DROP TABLE IF EXISTS `prescription`;
CREATE TABLE `prescription` (
  `PrescriptionID` int(11) NOT NULL,
  `PatientID` int(11) NOT NULL,
  `DoctorID` int(11) NOT NULL,
  `PreviousPrescriptionID` int(11) DEFAULT NULL,
  `MedicineID` int(11) NOT NULL,
  `TotalDose` varchar(50) NOT NULL,
  `Remark` varchar(500) NOT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all prescriptions of a patient. Specific details of dosage and when to take them is stored in a "PatientDetails" table';

-- --------------------------------------------------------

--
-- Table structure for table `prescriptiondetail`
--

DROP TABLE IF EXISTS `prescriptiondetail`;
CREATE TABLE `prescriptiondetail` (
  `PrescriptionDetailID` int(11) NOT NULL,
  `PrescriptionID` int(11) NOT NULL,
  `IsTakeOnEffect` tinyint(1) NOT NULL DEFAULT 0,
  `StartOn` datetime NOT NULL,
  `EndOn` datetime DEFAULT NULL,
  `Dose` varchar(50) NOT NULL,
  `IntervalMinutes` int(11) DEFAULT NULL,
  `Remark` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores when the patient is to take the medication.';

-- --------------------------------------------------------

--
-- Table structure for table `reminder`
--

DROP TABLE IF EXISTS `reminder`;
CREATE TABLE `reminder` (
  `ReminderID` int(11) NOT NULL,
  `StartOn` datetime NOT NULL,
  `EndOn` datetime DEFAULT NULL,
  `IntervalMinutes` int(11) DEFAULT NULL,
  `PrescriptionDetailID` int(11) DEFAULT NULL,
  `AppointmentID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores upcoming and past reminders';

-- --------------------------------------------------------

--
-- Table structure for table `symptom`
--

DROP TABLE IF EXISTS `symptom`;
CREATE TABLE `symptom` (
  `SymptomID` int(11) NOT NULL,
  `PatientDetailsID` int(11) NOT NULL,
  `Description` varchar(100) NOT NULL,
  `CreatedOn` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `UserType` enum('superadmin','admin','doctor','patient') NOT NULL,
  `FirstName` varchar(100) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `Phone` varchar(259) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `Identification` varchar(20) NOT NULL,
  `Gender` enum('M','F') NOT NULL,
  `InstituteID` smallint(5) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores all users using the system';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointment`
--
ALTER TABLE `appointment`
  ADD PRIMARY KEY (`AppointmentID`),
  ADD KEY `DoctorUserID` (`DoctorID`);

--
-- Indexes for table `compliance`
--
ALTER TABLE `compliance`
  ADD PRIMARY KEY (`ComplianceID`),
  ADD KEY `PrescriptionDetailID` (`PrescriptionDetailID`);

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
  ADD KEY `PatientID` (`PatientID`),
  ADD KEY `DoctorID` (`DoctorID`),
  ADD KEY `MedicineID` (`MedicineID`),
  ADD KEY `PreviousPrescriptionID` (`PreviousPrescriptionID`);

--
-- Indexes for table `prescriptiondetail`
--
ALTER TABLE `prescriptiondetail`
  ADD KEY `PrescriptionID` (`PrescriptionID`);

--
-- Indexes for table `reminder`
--
ALTER TABLE `reminder`
  ADD PRIMARY KEY (`ReminderID`),
  ADD KEY `PrescriptionDetailID` (`PrescriptionDetailID`),
  ADD KEY `AppointmentID` (`AppointmentID`);

--
-- Indexes for table `symptom`
--
ALTER TABLE `symptom`
  ADD PRIMARY KEY (`SymptomID`),
  ADD KEY `MedicalDetailsID` (`PatientDetailsID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users` 
  ADD KEY `InstituteID` (`InstituteID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointment`
--
ALTER TABLE `appointment`
  MODIFY `AppointmentID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `compliance`
--
ALTER TABLE `compliance`
  MODIFY `ComplianceID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `disease`
--
ALTER TABLE `disease`
  MODIFY `DiseaseID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `institute`
--
ALTER TABLE `institute`
  MODIFY `InstituteID` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medicine`
--
ALTER TABLE `medicine`
  MODIFY `MedicineId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `prescription`
--
ALTER TABLE `prescription`
  MODIFY `PrescriptionID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reminder`
--
ALTER TABLE `reminder`
  MODIFY `ReminderID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointment`
--
ALTER TABLE `appointment`
  ADD CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`DoctorID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`DoctorID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE;

--
-- Constraints for table `compliance`
--
ALTER TABLE `compliance`
  ADD CONSTRAINT `compliance_ibfk_1` FOREIGN KEY (`PrescriptionDetailID`) REFERENCES `prescriptiondetail` (`PrescriptionID`) ON UPDATE CASCADE;

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
  ADD CONSTRAINT `prescription_ibfk_1` FOREIGN KEY (`PatientID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_2` FOREIGN KEY (`DoctorID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_3` FOREIGN KEY (`MedicineID`) REFERENCES `medicine` (`MedicineId`) ON UPDATE CASCADE,
  ADD CONSTRAINT `prescription_ibfk_4` FOREIGN KEY (`PreviousPrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON UPDATE CASCADE;

--
-- Constraints for table `prescriptiondetail`
--
ALTER TABLE `prescriptiondetail`
  ADD CONSTRAINT `prescriptiondetail_ibfk_1` FOREIGN KEY (`PrescriptionID`) REFERENCES `prescription` (`PrescriptionID`) ON UPDATE CASCADE;

--
-- Constraints for table `reminder`
--
ALTER TABLE `reminder`
  ADD CONSTRAINT `reminder_ibfk_1` FOREIGN KEY (`PrescriptionDetailID`) REFERENCES `prescriptiondetail` (`PrescriptionID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `reminder_ibfk_2` FOREIGN KEY (`AppointmentID`) REFERENCES `appointment` (`AppointmentID`) ON UPDATE CASCADE;

--
-- Constraints for table `symptom`
--
ALTER TABLE `symptom`
  ADD CONSTRAINT `symptom_ibfk_1` FOREIGN KEY (`PatientDetailsID`) REFERENCES `patientdetails` (`PatientDetailsID`) ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`InstituteID`) REFERENCES `institute` (`InstituteID`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
