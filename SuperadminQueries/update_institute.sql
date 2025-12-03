DROP PROCEDURE IF EXISTS UpdateInstitute;
CREATE PROCEDURE UpdateInstitute(
    IN p_InstituteID SMALLINT UNSIGNED,
    IN p_InstituteName VARCHAR(100),
    IN p_AddressLine1 VARCHAR(60),
    IN p_AddressLine2 VARCHAR(60),
    IN p_City VARCHAR(30),
    IN p_StateProvinceCode VARCHAR(3),
    IN p_CountryCode CHAR(2),
    IN p_PostalCode VARCHAR(15)
)BEGIN
    -- Update an existing institute's details
    UPDATE Institute
    SET
        Name = p_InstituteName,
        AddressLine1 = p_AddressLine1,
        AddressLine2 = p_AddressLine2,
        City = p_City,
        StateProvinceCode = p_StateProvinceCode,
        Country = p_CountryCode,
        PostalCode = p_PostalCode
    WHERE InstituteID = p_InstituteID;

    -- Updating institute action log to keep track of changes
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'UPDATE',
        'Institute',
        CONCAT('CALL UpdateInstitute(',
            p_InstituteID, ', ', QUOTE(p_InstituteName), ', ',
            QUOTE(p_AddressLine1), ', ', QUOTE(p_AddressLine2), ', ',
            QUOTE(p_City), ', ', QUOTE(p_StateProvinceCode), ', ',
            QUOTE(p_CountryCode), ', ', QUOTE(p_PostalCode), ')'
        )
    );
END;

-- Example usage:
CALL UpdateInstitute(
    1,                          -- InstituteID
    'Borneo Medical Center',    -- InstituteName
    '456 New Street',           -- AddressLine1
    'Building B',               -- AddressLine2
    'Kuching',                  -- City
    'SRW',                      -- StateProvinceCode
    'MY',                       -- CountryCode
    '93350'                     -- PostalCode
);
