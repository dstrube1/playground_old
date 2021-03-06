	DECLARE @Date DATE = '10/25/2012'
	
	
	IF OBJECT_ID('tempdb..#TimeTable') IS NULL
		BEGIN

			CREATE TABLE #TimeTable(
				MinuteTime TIME	
			)

			;WITH TIME_CTE AS(
				SELECT CAST('0:00' AS TIME) MinTime
				UNION ALL
				SELECT DATEADD(mi,1,MinTime)
				FROM TIME_CTE
				WHERE MinTime < '23:59'
			)
			INSERT INTO #TimeTable
			SELECT MinTime
			FROM TIME_CTE OPTION (MAXRECURSION 1440)

			CREATE CLUSTERED INDEX CX_TimeTable ON #TimeTable(MinuteTime)

		END

		DECLARE @PNum INT

		SELECT @PNum = SIProcessing_Attribution.$PARTITION.PF_SI_TrackedAction(@Date)
		
		IF OBJECT_ID('tempdb..#EXP') IS NOT NULL
		DROP TABLE #EXP
		
		CREATE TABLE #EXP(
			WebserverID INT,
			CLientID INT,
			ActionTime TIME,
			ActionCount INT
		)
		
		INSERT INTO #EXP( WebServerID,CLieNTID,ActionTime, ActionCount )
		SELECT tem.WebServerID,
			tem.ClientID,
			CONVERT(VARCHAR(5), createdateutc, ( 8 )) AS [Time],
			COUNT(tem.UserUniqueGUID) AS Actions
		FROM SIProcessing_Attribution..TrackedAction tem WITH (NOLOCK)
		WHERE SIProcessing_Attribution.$PARTITION.PF_SI_TrackedAction(createdateutc) = @PNum
			AND WebServerID IN (13767,13768,13769,13770)
			--AND CLientID = 7323
		GROUP BY WebServerID,CLieNTID,CONVERT(VARCHAR(5), createdateutc, ( 8 ))
	
	
			SELECT tt.MinuteTime AS [Time],
				ClientID,
				--WebServerID,
				SUM(ISNULL(e.ActionCount,0)) AS ActionCount
			FROM #TimeTable tt 
			LEFT JOIN #EXP e ON tt.MinuteTime = e.ActionTime
			GROUP BY  tt.MinuteTime,CLientID
			ORDER BY tt.MinuteTime,CLientID--, WebserverID
			
			SELECT CLientID,SUM(ActionCount)
			FROM #EXP
			GROUP BY CLientID
			ORDER BY 2 DESC
			