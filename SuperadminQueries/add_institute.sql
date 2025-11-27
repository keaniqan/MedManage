-- Creates a new institute in the database.
DROP PROCEDURE IF EXISTS AddInstitute;
CREATE PROCEDURE AddInstitute(
    IN p_InstituteName VARCHAR(100),
    IN p_AddressLine1 VARCHAR(60),
    IN p_AddressLine2 VARCHAR(60),
    IN p_City VARCHAR(30),
    IN p_StateProvinceCode VARCHAR(3),
    IN p_CountryCode CHAR(2),
    IN p_PostalCode VARCHAR(15)
)BEGIN
    -- Inserting the new institute into the institutes table
    INSERT INTO Institute (
        Name,
        AddressLine1,
        AddressLine2,
        City,
        StateProvinceCode,
        Country,
        PostalCode
    ) VALUES (
        p_InstituteName,
        p_AddressLine1,
        p_AddressLine2,
        p_City,
        p_StateProvinceCode,
        p_CountryCode,
        p_PostalCode
    );

    -- Logging the creation of the new institute
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'INSERT',
        'Institute',
        CONCAT('CALL AddInstitute(',
            QUOTE(p_InstituteName), ', ',QUOTE(p_AddressLine1), ', ',
            QUOTE(p_AddressLine2), ', ',QUOTE(p_City), ', ',
            QUOTE(p_StateProvinceCode), ', ',QUOTE(p_CountryCode), ', ',
            QUOTE(p_PostalCode),')'
        )
    );
END;

-- Example usage:
CALL AddInstitute(
    'Health Institute',
    '123 Main St',
    'Suite 400',
    'Metropolis',
    'CA',
    'US',
    '90210'
);