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
GRANT SELECT, INSERT, UPDATE ON medmanagedb.users TO 'doc1'@'localhost';
FLUSH PRIVILEGES;

