BACKUP DATABASE Staging
TO DISK = 'A:\bddbackups\staging.bak'
WITH 
COMPRESSION,
INIT,
STATS = 10;

RESTORE LABELONLY
FROM DISK = 'A:\bddbackups\staging.bak';

RESTORE VERIFYONLY
FROM DISK = 'A:\bddbackups\staging.bak';

RESTORE FILELISTONLY
FROM DISK = 'A:\bddbackups\staging.bak';