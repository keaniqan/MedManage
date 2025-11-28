USE medmanagedb;
SELECT
	m.MedicineId,
    m.Name,
    m.Brand,
    m.Description
FROM Medicine m
ORDER by m.MedicineId DESC;