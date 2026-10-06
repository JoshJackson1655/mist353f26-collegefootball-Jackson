-- CREATE LOGIN NandaSurendra

/*WITH PASSWORD = 'MI$T353Instructor';?*/

CREATE USER NandaSurendra

FOR LOGIN NandaSurendra;

ALTER ROLE db_owner ADD MEMBER NandaSurendra;
