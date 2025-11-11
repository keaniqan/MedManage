INSERT INTO users (
  UserID,
  Username,
  Email,
  UserType,
  FirstName,
  LastName,
  Phone,
  PasswordHash,
  Identification,
  Gender,
  InstituteID
)
VALUES (
  1,
  'drjones',
  'dr.jones@example.com',
  'doctor',
  'Sarah',
  'Jones',
  '0123456789',
  SHA2('securePassword123', 256),  -- Hash the password securely
  'IC1234567',
  'F',
  1
);

CREATE USER 'doc1'@'localhost' IDENTIFIED BY 'doc1';

CREATE VIEW patient_view AS
SELECT UserID, Username, Email, FirstName, LastName, Phone, Gender, InstituteID
FROM users
WHERE UserType = 'patient';

GRANT SELECT ON medmanagedb.patient_view TO 'doc1'@'localhost';
FLUSH PRIVILEGES;

