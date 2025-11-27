USE medmanagedb;
SELECT
	m.MedicineID,
    m.Name,
    m.Brand,
    m.Description
FROM Medicine m
ORDER by m.MedicineID DESC;