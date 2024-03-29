/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * FROM [SIProcessing].[dbo].[LUCurrency]
 
 SELECT * FROM LUCountry where Country like '%Andorra%'
 
 --Insert INTO LUCurrency(CurrencyID,CurrencyCode,CurrencyName,CountryID,StatusFlag,CurrencySymbol)
 --Values(3)
 
 
 SELECT * FROM ClientSearchEngineMapping
 WHERE
 SEID IN ( SELECT SEID FROM SearchEngine WHERE SearchEngine like '%BING%')
 AND StatusFlag = 1
 AND CanCrawling = 1
 
 Select csem.ClientID,
 csem.SEID
--c.ClientName, 
--CASE WHEN c.ParentClientID IS NOT NULL THEN (SELECT ClientName From Clients Where ClientID = c.ParentClientID) ELSE '' END AS 'Parent Client', 
--CASE WHEN c.RootClientID IS NOT NULL THEN (SELECT ClientName From Clients Where ClientID = c.RootClientID) ELSE '' END AS 'Root Client', 
--rpt.GenerateDate, 
--SUM(rpt.cost) AS Cost 
from ClientSearchEngineMapping csem 
join Clients c ON csem.ClientID = c.ClientID 
join SIOLAP..RPT_PS_Summary_ClientLevel rpt ON csem.ClientID = rpt.ClientID AND rpt.SEID = csem.SEID 
where csem.SEID IN (  SELECT SEID FROM SearchEngine WHERE SearchEngine like '%BING%') AND csem.CanCrawling = 1 AND c.StatusFlag = 1 AND rpt.GenerateDate = (SELECT MAX(GenerateDate) FROM SIOLAP..RPT_PS_Summary_ClientLevel WHERE ClientID = csem.ClientID AND Cost > 0) AND rpt.GenerateDate >='7/01/2010' 
GROUP BY csem.ClientID,c.ClientName,rpt.GenerateDate,c.ParentClientID,c.RootClientID,csem.SEID
HAVING SUM(rpt.cost) > 0
ORDER BY 1