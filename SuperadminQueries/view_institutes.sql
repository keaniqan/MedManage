-- Query to retrieve all institutes with optional filtering
-- Parameters:
--   @p_NameFilter: Filter institutes by name using LIKE pattern (use NULL or '%' for no filter)
--   @p_ShowDeactivated: Set to TRUE to include deactivated institutes, FALSE to exclude them

SET @p_NameFilter = NULL; -- Example: '%Institute%'
SET @p_ShowDeactivated = FALSE; -- Example: TRUE or FALSE
SELECT 
    `InstituteID`,
    `Name`,
    `AddressLine1`,
    `AddressLine2`,
    `City`,
    `StateProvinceCode`,
    `Country`,
    `PostalCode`,
    CASE 
        WHEN DeletedOn IS NULL THEN 'Active'
        ELSE 'Deactivated'
    END AS Status,
    `DeletedOn`
FROM 
    Institute
WHERE 
    -- Optional filter by name (use '%' or NULL for no filter)
    (Name LIKE IFNULL(@p_NameFilter, '%'))
    AND
    -- Optional filter to show/hide deactivated institutes
    (
        (@p_ShowDeactivated = TRUE)
        OR
        (@p_ShowDeactivated = FALSE AND DeletedOn IS NULL)
    )
ORDER BY 
    Name;