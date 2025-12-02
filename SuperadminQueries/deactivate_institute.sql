-- Soft deletes the institute by setting DeletedOn timestamp
DROP PROCEDURE IF EXISTS DeactivateInstitute;
CREATE PROCEDURE DeactivateInstitute(
    IN p_InstituteName VARCHAR(100)
)BEGIN
    -- Soft delete the institute by setting DeletedOn timestamp
     UPDATE `Institutes`
     SET `DeletedOn` = NOW()
     WHERE `InstituteID` = (
         SELECT `InstituteID` 
         FROM `Institute` 
         WHERE `Name` = p_InstituteName
     );

    -- Log the deletion action
    INSERT INTO Log (ActionType, TableName, Query)
    VALUES (
        'DELETE',
        'Institute',
        CONCAT('CALL DeactivateInstitute(''', p_InstituteName, ''');')
    );
END;