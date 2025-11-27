-- Retrieve and lists all superadmin users from the database.

EXPLAIN SELECT 
    UserID,
    Username,
    Email,
    FirstName,
    LastName,
    Phone,
    Identification,
    Institute.Name AS Institute
FROM `Users`
INNER JOIN `Institute` ON Users.InstituteID = Institute.InstituteID
WHERE
    (UserType = 'superadmin' OR UserType = 'admin')
    -- AND username LIKE '%%';-- Filter by username if needed