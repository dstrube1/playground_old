USE [SIOLAP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



        
/*
	Description:	Summary client-level data refresh stored procedure
					Adapted from dbo.SI_SP_RPT_PS_DataRefresh
	Author:			Sean Fitzgerald
	
	Usage:			BEGIN TRAN
	
					SELECT * FROM dbo.Staging_RPT_PS_Summary_ClientLevel;
					SELECT * FROM dbo.RPT_PS_Summary_ClientLevel;
					
					EXEC [dbo].[SI_SP_RPT_PS_Summary_ClientLevel];
					
					SELECT * FROM dbo.Staging_RPT_PS_Summary_ClientLevel;
					SELECT * FROM dbo.RPT_PS_Summary_ClientLevel;
					
					ROLLBACK TRAN
	
	Modification(s):
	----------------
	Date:		Author:			Description:
	03/20/2012	Sean Fitzgerald	SIOPS-6109, Stored procedure created	
	03/23/2012	Sean Fitzgerald DMSREL-15, Replace DELETE | INSERT refined DELETE and MERGE		
	03/28/2012	Sean Fitzgerald	SIP-9026, Add new columns for side-by-side attribution
	09/20/2012	YZ				Add code to refresh dbo.RPT_PS_Summary_AgencyLevel
*/                
ALTER PROCEDURE [dbo].[ZZ_SI_SP_RPT_PS_Summary_ClientLevel]
AS 
	   SET NOCOUNT ON;                
	   BEGIN TRY          
			BEGIN TRAN              
			
			DELETE rd
			FROM	dbo.RPT_PS_Summary_ClientLevel AS rd
			INNER JOIN dbo.Staging_RPT_PS_Summary_ClientLevel AS rs
				ON rd.ClientID = rs.ClientID
				AND rd.GenerateDate = rs.GenerateDate
				AND rd.SEID = rs.SEID
			WHERE NOT EXISTS ( 
				SELECT	1
				FROM	dbo.Staging_RPT_PS_Summary_ClientLevel
				WHERE	ClientID = rd.ClientID
					AND GenerateDate = rd.GenerateDate
					AND IsContentMatch = rd.IsContentMatch
					AND SEID = rd.SEID 
				);

			MERGE INTO dbo.RPT_PS_Summary_ClientLevel AS t
			USING (
				SELECT	ClientID
					,GenerateDate
					,IsContentMatch
					,SEID
					,NumImpressions
					,Cost
					,NumClicksReported
					,NumClicksTracked
					,0 AS TransactionCount
					,TransactionCount AS TTCount
					,TransactionAmount
					,TotalRank
					,TotalRankCount
					,ISNULL(TransactionCountWithWeight, TransactionCount) AS TransactionCountWithWeight
					,SocialImpressions
					,SocialClicks
					,SocialCost
					,TransactionCount2
					,TransactionAmount2
					,TransactionCountWithWeight2
				FROM	dbo.Staging_RPT_PS_Summary_ClientLevel
				) AS s 
				ON t.ClientID = s.ClientID
					AND t.GenerateDate = s.GenerateDate
					AND t.IsContentMatch = s.IsContentMatch
					AND t.SEID = s.SEID 					
			WHEN MATCHED THEN
				UPDATE SET NumImpressions = s.NumImpressions
					,Cost = s.Cost
					,NumClicksReported = s.NumClicksReported
					,NumClicksTracked = s.NumClicksTracked
					,TransactionCount = s.TransactionCount
					,TTCount = s.TTCount
					,TransactionAmount = s.TransactionAmount
					,TotalRank = s.TotalRank
					,TotalRankCount = s.TotalRankCount
					,TransactionCountWithWeight = s.TransactionCountWithWeight
					,SocialImpressions = s.SocialImpressions
					,SocialClicks = s.SocialClicks
					,SocialCost = s.SocialCost
					,TransactionCount2 = s.TransactionCount2
					,TransactionAmount2 = s.TransactionAmount2
					,TransactionCountWithWeight2 = s.TransactionCountWithWeight2
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (ClientID,GenerateDate,IsContentMatch,SEID,NumImpressions,Cost,NumClicksReported,NumClicksTracked,TransactionCount,TTCount,TransactionAmount,TotalRank,TotalRankCount,TransactionCountWithWeight,SocialImpressions,SocialClicks,SocialCost,TransactionCount2,TransactionAmount2,TransactionCountWithWeight2) 
				VALUES (s.ClientID,s.GenerateDate,s.IsContentMatch,s.SEID,s.NumImpressions,s.Cost,s.NumClicksReported,s.NumClicksTracked,s.TransactionCount,s.TTCount,s.TransactionAmount,s.TotalRank,s.TotalRankCount,s.TransactionCountWithWeight,s.SocialImpressions,s.SocialClicks,s.SocialCost,s.TransactionCount2,s.TransactionAmount2,s.TransactionCountWithWeight2)
			;
						
			 COMMIT TRAN
	   END TRY
	   BEGIN CATCH          
			 IF @@TranCount > 0 
				ROLLBACK          
	   END CATCH    
	   
	   --Update dbo.RPT_PS_Summary_AgencyLevel    
	   --First find all agency which need to update
	   DECLARE @RC int
		CREATE TABLE #Agency (AgencyClientID INT, GenerateDate SMALLDATETIME, SEID smallint)
				
		IF OBJECT_ID('tempdb..#RPT_PS_Summary_AgencyLevel') IS NOT NULL
		DROP TABLE #RPT_PS_Summary_AgencyLevel

		CREATE TABLE #RPT_PS_Summary_AgencyLevel(
			ClientID int,
			GenerateDate smalldatetime,
			SEID smallint,
			NumImpressions bigint,
			Cost money,
			NumClicksReported bigint,
			NumClicksTracked bigint,
			TransactionCount numeric(18, 2),
			TransactionAmount money,
			TotalRank numeric(18, 2),
			TotalRankCount bigint,
			TransactionCountWithWeight numeric(18, 2),
			CurrencyID smallint
		)

		INSERT INTO #Agency
			(AgencyClientID, GenerateDate, SEID)
		SELECT DISTINCT ParentClientID, GenerateDate, SEID
		FROM dbo.Staging_RPT_PS_Summary_ClientLevel rp 
		join Clients cl ON cl.ClientID = rp.ClientID
		WHERE EXISTS (SELECT 1 FROM Clients WHERE ClientID = cl.ParentClientID AND StatusFlag = 1 AND ClientID > 0)
		
		CREATE CLUSTERED INDEX indx_Agency_AgencyClientID ON #Agency (AgencyClientID)
		
		
		SELECT @RC = @@RowCount
		
		WHILE @RC > 0
		BEGIN
			INSERT INTO #Agency
				(AgencyClientID, GenerateDate, SEID)
			SELECT DISTINCT ParentClientID, GenerateDate, SEID
			FROM #Agency rp join Clients cl ON cl.ClientID = rp.AgencyClientID
			WHERE EXISTS (SELECT 1 FROM Clients WHERE ClientID = cl.ParentClientID AND StatusFlag = 1 AND ClientID > 0)
			AND NOT EXISTS (SELECT 1 FROM #Agency WHERE AgencyClientID = cl.ParentClientID)
			
			SELECT @RC = @@RowCount
		END
		
		create table #Clients (ClientID int)
		create clustered index idx_Clients_Temp on #Clients (ClientID)

		set nocount on
		declare @ClientID int
		select  @ClientID = MIN(AgencyClientID)
		from #Agency

		while @ClientID > 0
		begin
			Truncate table #Clients
			insert into #Clients
				(ClientID)
			select ClientID
			from Searchignite.dbo.tn_ClientHierarchy(@ClientID)
			
			truncate table #RPT_PS_Summary_AgencyLevel
			
			insert into #RPT_PS_Summary_AgencyLevel(ClientID, GenerateDate, SEID, CurrencyID, NumImpressions, Cost, NumClicksReported, NumClicksTracked, TransactionCount, TransactionAmount, TotalRank, TotalRankCount, TransactionCountWithWeight)
			select @ClientID,  GenerateDate, rp.SEID, isnull(CurrencyID, 73), sum(NumImpressions)
				, sum(Cost), sum(NumClicksReported), sum(NumClicksTracked), sum(TTCount), sum(TransactionAmount)
			, sum(TotalRank), sum(TotalRankCount), sum(TransactionCountWithWeight)
			from SIOLAP.dbo.RPT_PS_Summary_ClientLevel rp join SearchIgnite.dbo.SearchEngine se on rp.SEID = se.SEID
			where exists (select 1 from #Clients where ClientID = RP.ClientID)
			and exists (select 1 from #Agency where AgencyClientID = @ClientID and GenerateDate = rp.GenerateDate and SEID = rp.SEID)
			group by GenerateDate, rp.SEID, isnull(CurrencyID, 73)
			
			--Merger data with RPT_PS_Summary_AgencyLevel
			
			MERGE INTO RPT_PS_Summary_AgencyLevel AS t
			USING (
				SELECT	ClientID, GenerateDate, SEID, CurrencyID, NumImpressions, Cost, NumClicksReported, NumClicksTracked, TransactionCount, TransactionAmount, TotalRank, TotalRankCount, TransactionCountWithWeight
				FROM	#RPT_PS_Summary_AgencyLevel
				) AS s 
				ON t.ClientID = s.ClientID
				AND t.GenerateDate = s.GenerateDate
				AND t.SEID = s.SEID 					
			WHEN MATCHED THEN
				UPDATE SET NumImpressions = s.NumImpressions,
					Cost = s.Cost,
					NumClicksReported = s.NumClicksReported,
					NumClicksTracked = s.NumClicksTracked,
					TransactionCount = s.TransactionCount,
					TransactionAmount = s.TransactionAmount,
					TotalRank = s.TotalRank,
					TotalRankCount = s.TotalRankCount,
					TransactionCountWithWeight = s.TransactionCountWithWeight,
					CurrencyID = s.CurrencyID
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (ClientID, GenerateDate, SEID, CurrencyID, NumImpressions, Cost, NumClicksReported, NumClicksTracked, TransactionCount, TransactionAmount, TotalRank, TotalRankCount, TransactionCountWithWeight) 
				VALUES (s.ClientID, s.GenerateDate, s.SEID, s.CurrencyID, s.NumImpressions, s.Cost, s.NumClicksReported, s.NumClicksTracked, s.TransactionCount, s.TransactionAmount, s.TotalRank, s.TotalRankCount, s.TransactionCountWithWeight)
			--WHEN NOT MATCHED BY SOURCE and EXISTS (select 1 from #RPT_PS_Summary_AgencyLevel where ClientID = t.ClientID and GenerateDate = t.GenerateDate) THEN
			--	DELETE	
			;
			
			
			select  @ClientID = MIN(AgencyClientID)
			from #Agency
			where AgencyClientID > @ClientID
		end