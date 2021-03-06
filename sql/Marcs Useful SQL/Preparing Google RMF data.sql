
SELECT ReportDate, CrawlingFileImportStatusID, COUNT(1)
FROM dbo.CrawlingFileTracking
WHERE FileTypeID = 11
AND ReportDate >= '2011/11/27'
AND ReportDate < '2011/12/10'
GROUP BY  ReportDate,CrawlingFileImportStatusID
ORDER BY  CrawlingFileImportStatusID,ReportDate


SELECT ReportDate, COUNT(1) AS NumFiles, MIN (ProcessStart) AS StartTime,AVG(DATEDIFF(s,ProcessStart,ProcessEND)) AS avgsec, AVG(DATEDIFF(s,ProcessStart,ProcessEND))/COUNT(1) AS SecPerFile
FROM dbo.CrawlingFileTracking
WHERE FileTypeID = 13
AND CrawlingFileImportStatusID = 3
GROUP BY ReportDate
ORDER BY ReportDate

UPDATE dbo.CrawlingFileTracking
SET CrawlingFileImportStatusID = 1,
ProcessID = NULL
WHERE FileTypeID = 11
AND ReportDate >= '2011/11/27'
AND ClientID = 3854
--AND CrawlingFileImportStatusID =99
--COMMIT

SELECT *
FROM dbo.LUFileType

SELECT* 
FROM CrawlingFileTracking
WHERE FileTypeID IN (11,12,13)
AND CrawlingFileImportStatusID = 1

SELECT* 
FROM CrawlingFileTracking
WHERE FileTypeID IN (11)
AND CrawlingFileImportStatusID = 1
ORDER BY 2

SELECT *
FROM dbo.CrawlingFileTracking
WHERE
clientid = 5988
     AND FileTypeID IN (1,2) --group or keyword level files
     AND ReportDate >= '12/04/2011'
ORDER BY reportdate DESC



