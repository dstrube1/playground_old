/****** Script for SelectTopNRows command from SSMS  ******/
SELECT CAST(CreateDAteUTC AS DATE), 
	COUNT(1) AS NumImpressions, 
		SUM(CAST(Cost AS MONEY)) AS Cost
  FROM [JunkDB].[dbo].[DSPImpression_06012012]
  GROUP BY CAST(CreateDAteUTC AS DATE)
  ORDER BY CAST(CreateDAteUTC AS DATE)
  
  DROP INDEX CX_DSPImpression_06012012 ON [JunkDB].[dbo].[DSPImpression_06012012]
  CREATE CLUSTERED INDEX CX_DSPImpression_06012012 ON [JunkDB].[dbo].[DSPImpression_06012012] (CreateDAteUTC, Advertiser_ID)
  
  SELECT TOP 10 *
  FROM [JunkDB].[dbo].[DSPImpression_06012012]
  