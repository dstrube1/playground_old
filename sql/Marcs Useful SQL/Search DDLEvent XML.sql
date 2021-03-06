/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [EventTimeStampUTC]
      ,[EventData]
      ,[EventData].value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(max)')
  FROM [DBA].[dbo].[DDLEvent]
  WHERE  [EventData].value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(max)') like 'IX_CSKeywords_Dup'
  AND [EventData].value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(max)') like 'SearchIgnite'
  ORDER BY EventTimeStampUTC
  