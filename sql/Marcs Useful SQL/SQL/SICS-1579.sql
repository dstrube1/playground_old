--10.50.0.128\sqldw
WITH FlaudClicks AS (
	SELECT CreateDate,
		CSKID, 
		UserUniqueGuid,
		1 AS Count
	FROM [JunkDB].[dbo].[Temp_ClickTrackingRaw_8-14-2010]
	WHERE ExceptionID = 1 AND CSKID = 5326929 
),
FirstClick AS (
	SELECT * , 
		row_number() over (partition by CSKID, UserUniqueGuid order by CreateDate) as RN
	FROM [JunkDB].[dbo].[Temp_ClickTrackingRaw_8-14-2010]
	WHERE ExceptionID IS NULL
),
nextCreateDate as
(
	select CreateDate,
		CSKID, 
		UserUniqueGuid, 
		row_number() over (partition by CSKID, UserUniqueGuid order by CreateDate)-1 as RN
	FROM [JunkDB].[dbo].[Temp_ClickTrackingRaw_8-14-2010]
	WHERE ExceptionID IS NULL
)
SELECT tc.CSKID, 
	tc.UserUniqueGuid,
	tc.CreateDate,
	ISNULL(ncd.CreateDate,GETDATE()) AS Next_createDate,
	cmo.FraudWindow,
	ISNULL(SUM(fc.Count),0) AS Fraud_Count 
FROM FirstClick tc
	LEFT JOIN nextCreateDate ncd on ncd.RN = tc.RN AND ncd.UserUniqueGuid = tc.UserUniqueGuid and ncd.CSKID = tc.CSKID
	LEFT JOIN FlaudClicks fc ON tc.UserUniqueGuid = fc.UserUniqueGuid and tc.CSKID = fc.CSKID AND fc.CreateDate >= tc.CreateDate AND fc.CreateDate < ISNULL(ncd.CreateDate,GETDATE())
	LEFT JOIN SIAnalysis..CSKeywords csk ON tc.CSKID = csk.CSKID
	LEFT JOIN SIAnalysis..ClientMailOption cmo ON cmo.ClientID = csk.ClientID
WHERE tc.CSKID = 5326929 
--	AND DATEDIFF(s,tc.CreateDate,fc.CreateDate) > 420 
GROUP BY tc.CSKID, tc.UserUniqueGuid,tc.CreateDate,ncd.CreateDate,cmo.FraudWindow
--HAVING SUM(fc.Count) > 0
ORDER BY tc.CSKID,tc.UserUniqueGuid,tc.CreateDate


