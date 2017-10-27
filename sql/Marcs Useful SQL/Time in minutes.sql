
WITH TIME_CTE AS(
	SELECT CAST('0:00' AS TIME) MinTime
	UNION ALL
	SELECT DATEADD(mi,1,MinTime)
	FROM TIME_CTE
	WHERE MinTime < '23:59'
)
SELECT MinTime
FROM TIME_CTE OPTION (MAXRECURSION 1440)