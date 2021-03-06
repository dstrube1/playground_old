USE [360Analysis]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ARE_RedRoof_EngineHistory_YTD]
	@ClientID INT,
	@StartDate DATETIME,
	@CampaignIDList VARCHAR(2000) = NULL,
	@SEIDList VARCHAR(2000) = NULL
AS
 /*
Change History
	Version		Date		Modified	Notes
	1.00		07/14/08	LIR	
	1.01		10/26/09	MT			Took out IsContentMatch<2 ELSE split	
*/
BEGIN
	SET NOCOUNT ON
	CREATE TABLE #CampaignIDList (CampaignID INT PRIMARY KEY CLUSTERED)
	CREATE TABLE #SEIDList (SEID SMALLINT PRIMARY KEY CLUSTERED)

	DECLARE	@EndDate datetime
	SET @EndDate = DATEADD(day,6,@StartDate)
	SET @StartDate = DATEADD(yy, DATEDIFF(yy, 0, @StartDate), 0) -- Beginning of year

	--Parse Campaign
	IF @CampaignIDList IS NOT NULL
		INSERT INTO #CampaignIDList (CampaignID)
			SELECT DISTINCT ParseID FROM SIAnalysis.dbo.fn_ParseNumList (@CampaignIDList)
	ELSE
		INSERT INTO #CampaignIDList (CampaignID)
			SELECT campaignid  FROM [360Analysis].dbo.campaign WHERE clientid=@ClientID

	--Parse SEID
	IF @SEIDList IS NOT NULL
		INSERT INTO #SEIDList (SEID)
			SELECT DISTINCT ParseID FROM SIAnalysis.dbo.fn_ParseNumList (@SEIDList)
	ELSE
		INSERT INTO #SEIDList (SEID)
			SELECT DISTINCT SEID
			FROM SIAnalysis.dbo.CampaignSearchEngine ca
			WHERE EXISTS (SELECT 1 FROM #CampaignIDList WHERE CampaignID = ca.CampaignID)

	SELECT	tt.IsContentMatch AS ContentMatch,
			SearchEngine = CASE
				WHEN se.searchengine LIKE '%Google%' AND tt.ISContentMatch=0 THEN 'Google'
				WHEN se.searchengine LIKE '%Google%' AND tt.ISContentMatch=1 THEN 'Google Content'
				WHEN se.searchengine LIKE '%MSN%'  AND tt.ISContentMatch=0 THEN 'MSN'
				WHEN se.searchengine LIKE '%MSN%'  AND tt.ISContentMatch=1 THEN 'MSN Content'
				WHEN se.searchengine LIKE '%Yahoo!%'  AND tt.ISContentMatch=0 THEN 'Yahoo! Bing'
				WHEN se.searchengine LIKE '%Yahoo!%'  AND tt.ISContentMatch=1 THEN 'Yahoo! Bing Content'
				WHEN se.searchengine LIKE '%Yahoo%'  AND tt.ISContentMatch=0 THEN 'Yahoo'
				WHEN se.searchengine LIKE '%Yahoo%'  AND tt.ISContentMatch=1 THEN 'Yahoo Content'
				ELSE se.SearchEngine
			END,
			SUM(CASE tt.customertransactiontypeid WHEN -1 THEN 1 ELSE 0 END) AS Reservations,
			SUM(CASE tt.customertransactiontypeid WHEN -1 THEN tt.TransactionAmount ELSE 0 END) AS Revenue,
			SUM(case when isnumeric(tt.x2) = 1 AND CAST(tt.x2 AS INT) >0 then CAST(tt.x2 AS INT) else 0 end) AS Nights_Booked
	INTO #TransactionTracking
	FROM [360Analysis].dbo.transactiontrackingall tt
		JOIN #CampaignIDList AS ci ON tt.CampaignID = ci.CampaignID
		JOIN #SEIDList AS sl ON tt.SEID = sl.SEID
			AND tt.clientid = @ClientID
			AND tt.easterncreatedate>=@StartDate
			AND tt.easterncreatedate<DATEADD(day,1,@EndDate)
		JOIN [360Analysis].dbo.searchengine se ON se.seid=tt.seid
	GROUP BY tt.IsContentMatch,
			CASE
				WHEN searchengine LIKE '%Google%' AND ISContentMatch=0 THEN 'Google'
				WHEN searchengine LIKE '%Google%' AND ISContentMatch=1 THEN 'Google Content'
				WHEN searchengine LIKE '%MSN%' THEN 'MSN'
				WHEN searchengine LIKE '%MSN%'  AND ISContentMatch=0 THEN 'MSN'
				WHEN searchengine LIKE '%MSN%'  AND ISContentMatch=1 THEN 'MSN Content'
				WHEN searchengine LIKE '%Yahoo!%'  AND ISContentMatch=0 THEN 'Yahoo! Bing'
				WHEN searchengine LIKE '%Yahoo!%'  AND ISContentMatch=1 THEN 'Yahoo! Bing Content'
				WHEN searchengine LIKE '%Yahoo%'  AND ISContentMatch=0 THEN 'Yahoo'
				WHEN searchengine LIKE '%Yahoo%'  AND ISContentMatch=1 THEN 'Yahoo Content'
				ELSE SearchEngine
			END
 
	SELECT	@StartDate AS StartDate, @EndDate AS EndDate,
			d.SearchEngine, d.ContentMatch,
			'Search' AS DataType,
			SUM(d.Impressions) AS Impressions, SUM(d.Clicks) AS Clicks,
			SUM(d.Cost) AS Cost,
			Rank = CASE 
				WHEN SUM(d.impressions)=0 THEN 0
				ELSE SUM(d.impressions*d.rank)/SUM(d.impressions)
			END,
			SUM(t2.Revenue) AS Revenue,
			SUM(t2.Reservations) AS Reservations,
			SUM(t2.Nights_Booked) AS Nights_Booked, 
			@ClientID AS ClientID
	FROM
			(	SELECT	rd.IsContentMatch AS ContentMatch,
						SearchEngine = CASE
							WHEN searchengine LIKE '%Google%' AND ISContentMatch=0 THEN 'Google'
							WHEN searchengine LIKE '%Google%' AND ISContentMatch=1 THEN 'Google Content'
							WHEN searchengine LIKE '%MSN%'  AND ISContentMatch=0 THEN 'MSN'
							WHEN searchengine LIKE '%MSN%'  AND ISContentMatch=1 THEN 'MSN Content'
							WHEN searchengine LIKE '%Yahoo!%'  AND ISContentMatch=0 THEN 'Yahoo! Bing'
							WHEN searchengine LIKE '%Yahoo!%'  AND ISContentMatch=1 THEN 'Yahoo! Bing Content'
							WHEN searchengine LIKE '%Yahoo%'  AND ISContentMatch=0 THEN 'Yahoo'
							WHEN searchengine LIKE '%Yahoo%'  AND ISContentMatch=1 THEN 'Yahoo Content'
							ELSE SearchEngine
						END,
						SUM(CAST(rd.numimpressions AS BIGINT)) AS Impressions, SUM(CAST(rd.numclicksreported AS BIGINT)) AS Clicks,
						SUM(rd.cost) AS Cost,
						Rank = CASE
							WHEN SUM(rd.TotalRankCount) = 0 THEN 0
							WHEN SUM(rd.numimpressions) = 0 THEN 0
							ELSE SUM(rd.numimpressions*rd.TotalRank/(CASE WHEN rd.TotalRankCount=0 THEN 1 ELSE rd.totalrankcount END))/SUM(CAST(rd.numimpressions AS BIGINT))
						END
				FROM [360Analysis].dbo.RPT_PS_Summary_CampaignLevel rd
				JOIN #CampaignIDList AS ci ON rd.CampaignID = ci.CampaignID
				JOIN #SEIDList AS sl ON rd.SEID = sl.SEID
				JOIN [360Analysis].dbo.searchengine se ON se.seid=rd.seid
				WHERE rd.clientid=@ClientID AND rd.generatedate>=@StartDate AND rd.generatedate<DATEADD(day,1,@EndDate)
				GROUP BY rd.IsContentMatch,
						CASE
							WHEN searchengine LIKE '%Google%' AND ISContentMatch=0 THEN 'Google'
							WHEN searchengine LIKE '%Google%' AND ISContentMatch=1 THEN 'Google Content'
							WHEN searchengine LIKE '%MSN%' THEN 'MSN'
							WHEN searchengine LIKE '%MSN%'  AND ISContentMatch=0 THEN 'MSN'
							WHEN searchengine LIKE '%MSN%'  AND ISContentMatch=1 THEN 'MSN Content'
							WHEN searchengine LIKE '%Yahoo!%'  AND ISContentMatch=0 THEN 'Yahoo! Bing'
							WHEN searchengine LIKE '%Yahoo!%'  AND ISContentMatch=1 THEN 'Yahoo! Bing Content'
							WHEN searchengine LIKE '%Yahoo%'  AND ISContentMatch=0 THEN 'Yahoo'
							WHEN searchengine LIKE '%Yahoo%'  AND ISContentMatch=1 THEN 'Yahoo Content'
							ELSE SearchEngine
						END
			) AS d
			LEFT OUTER JOIN #TransactionTracking AS t2
				ON t2.SearchEngine=d.SearchEngine AND t2.contentmatch=d.contentmatch
	GROUP BY d.SearchEngine, d.ContentMatch

END




GO
GRANT EXECUTE ON [dbo].[ARE_RedRoof_EngineHistory_YTD] TO [atlanta\mtucker] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[ARE_RedRoof_EngineHistory_YTD] TO [Role_SI Tech Services Tier 2] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[ARE_RedRoof_EngineHistory_YTD] TO [Role_SI Tech Services Tier 2] AS [dbo]