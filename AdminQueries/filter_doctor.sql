USE medmanagedb;

DROP PROCEDURE IF EXISTS FilterDoctors;

DELIMITER //

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
END //

DELIMITER ;

-- Usage examples:
-- Filter by specialist only
CALL FilterDoctors(NULL, NULL, 'Neurologist', NULL, NULL, NULL, NULL, NULL);

-- Filter by medical school and years of experience
CALL FilterDoctors(NULL, NULL, NULL, NULL, 13, NULL, NULL, NULL);

-- Filter by language spoken (searches within JSON array)
CALL FilterDoctors(NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'English');

CALL FilterDoctors(NULL, NULL, 'Neurologist', NULL, NULL, NULL, NULL, 'Malay');
-- Get all doctors
CALL FilterDoctors(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);