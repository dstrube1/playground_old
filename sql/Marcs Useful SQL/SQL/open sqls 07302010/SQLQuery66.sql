--SELECT *  FROM [SIProcessing_Attribution_Archive].[dbo].[ArchiveLog] ORDER BY 2,3

TRUNCATE TABLE SIProcessing_Attribution_Archive..

sp_who4

SELECT rows FROM sys.partitions WHERE object_id = OBJECT_ID(N'SIProcessing_Attribution_Archive..TrackedExposure_swap')

Select * from SIProcessing_Attribution_Archive..TrackedExposure_swap

SELECT * FROM sys.partitions WHERE object_id = OBJECT_ID(N'SIProcessing_Attribution_Archive..ArchiveLog') order by partition_number

WITH [ArchiveLog ORDERED BY DATE] AS
(SELECT ROW_NUMBER() OVER (Order by DATE) As ROWID, *  FROM [SIProcessing_Attribution_Archive].[dbo].[ArchiveLog])
DELETE FROM [ArchiveLog ORDERED BY DATE] WHERE ROWID =1

DELETE FROM [SIProcessing_Attribution_Archive].[dbo].[ArchiveLog]
WHERE ErrorMessage = 'DEBUG'

INSERT INTO ArchiveLog SELECT * FROM ArchiveLog_5-03 where row = row id

SELECT * FROM [ArchiveLog_5-03]

ALTER TABLE SIProcessing_Archive..ArchiveLog 
ADD RUNDATE DATETIME

Select DateADD(day,-92,GETDATE())

--SELECT *
--INTO dbo.[ArchiveLog_5-03]
--FROM dbo.[ArchiveLog]

The SIProcessing_Attribution_Archive..TrackedExposure_swap failed with error# 1105 and with the following message: Could not allocate space for object 'dbo.TrackedExposure_swap'.'PK_TrackedExposure1' in database 'SIProcessing_Attribution_Archive' because the 'PRIMARY' filegroup is full. Create disk space by deleting unneeded files, dropping objects in the filegroup, adding additional files to the filegroup, or setting autogrowth on for existing files in the filegroup..
