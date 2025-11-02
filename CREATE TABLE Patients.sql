CREATE DATABASE IF NOT EXISTS MedManageDB;
USE MedManageDB;

INSERT INTO appointment (
    AppointmentID,
    PatientUserID,
    DoctorUserID,
    AppointmentOn,
    Details
  )
VALUES (
    AppointmentID:int,
    PatientUserID:int,
    DoctorUserID:int,
    'AppointmentOn:date',
    'Details:varchar'
  );