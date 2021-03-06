USE [SearchIgnite]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[SI_SP_CampaignManagement_Keyword_Read]
(
	@ClientID INT 
	,@UserID INT 
	,@PublisherFilterID INT = null 
	,@PublisherFilterTypeID SMALLINT = -1	--(-1 All publishres, 1 SEID, 2 - CampaignID, 3 GroupID)
	,@StartDate DATETIME					--Startdate from the CampaignSearchengine table
	,@EndDate DATETIME						--EndDate from the CampaignSearchengine table
	,@CurrencyID INT = NULL					--Conversion currency from SearchEngine table to this value LUCurrency
	,@KeywordStatusID varchar(1000) = NULL			--Keyword status lukeywordstatus (1 Active, 2 Paused, 3 Inactive, 4 Deleted
	,@CustomerTransactionType NVARCHAR(MAX) = NULL
	,@IncludeContentMatch TINYINT = NULL	
	,@SortDataGridColumnID INT = 72
	,@SortDescending TINYINT  = 0
	,@RequestPage INT = 1
	,@RowsPerPage INT = 50
	,@SearchText NVARCHAR(1000) = NULL
	,@AdvancedFilterXML XML = NULL
	,@AdvancedFilterID INT = NULL
	,@isDebug TINYINT = 0
	,@VGID int = null
)

AS
/*
--	12/09/09	LIR	Initial version
--	01/11/10	LIR Added support for bulksheet advance filters
--	01/13/10	LIR added support for currency conversion
--	01/19/10	LIR added the SSRedirect AS CampaignSSRedirect
--	01/20/10	LIR Added AND CampaignSearchEngine.StatusFlag = 1 to remove inactive CampaignSearchEngine records
--	01/22/10	LIR Rename @AdCatoryStatusID to @AdCategoryStatusID
--	01/22/10	LIR Added new column CampaignStatusID  JIRA SIP-1582
--	01/26/10	LIR Formanted to match the ad proc
--	01/26/10	LIR added support for Campaign Deleted to the InheritedStatus JIRA sip-1666
--	02/01/10	LIR fixed the currency conversion problem with CPA..etc
--	02/02/10	LIR fixed problem with status filter and advanced filter for bulksheets
--	02/03/10	LIR do not return records if campaign.statuflag = 0
--	02/04/10	LIR added 	AND SearchEngine.StatusFlag = 1
--	02/04/10	LIR Added text search support for both groups and campaigns
--	02/10/10	LIR Moved Advance filter down and validated that all advance filter columns work and removed Publisher 99
--	02/17/10	LIR	Added currency Code to result set and added content bid (%1)
--	02/25/10	LIR	Added temp table and index
--	02/28/10	LIR Added a couple ID columns to the result set for the front end
--	02/28/10	LIR Added an index on cskid to the inital temp table and moved the exists lower in the RPT cte
--	03/01/10	LIR Added perforamce enhancements
--	03/01/10	LIR Added renamed InheritedStatusDesc to InheritedStatus
--	03/04/10	LIR Fixed hardcoded currencyID = 5
--	03/04/10	LIR SIP-2555 fixed the SearchBid and FinalBid issue and translate the matchtype for yahoo
--	03/08/10	LIR Added Bid Method, Bid Method Type and Bid method Group into result set.
--	03/08/10	LIR Fix problem with match type for Yahoo
--	03/08/10	LIR Return Globalrule column
--	03/09/10	LIR Changed where we are pulling EnableContentMatch from Campaign to CampaignSearchEngine
--	03/09/10	LIR Renamed Finalbid from searchbid
--	03/09/10	YZ	SIP-2688 "Search" Box Does Not Return Results for Double Byte Characters
--	03/09/10	LIR Added isSpotID and support for wildcards
--	03/16/10	LIR Added support for additional sort columns, only thing left is to add the engine sort
--	03/22/10	LIR	fixed an issue with the organic rank sort and Revenue
--	05/10/10	LIR	Added SpotID to result set to support Advance filters
--	05/24/10	WDJ	Added special handling for single quotes (').
--	06/07/10	LIR	SIP-3581 Added support for Pending status 
--	06/09/10	WDJ	SIP-3649 Resolved Weighted Actions issue.
--	06/11/10	YZ	SIP-3810, Action Filter didn't work correctly
--	06/14/10	YZ	Add VGID as filter, also @CampaignStatusID to varchar(1000) to allow multi status filter
--	07/19/10	WDJ	SIP-4321 - Commented out Line 432 (now line 434) of the code. This line has been moved down into
--					the subquery of the CTE and references a un-aliased column as well as outside of the GROUP BY.
--	07/14/10	YZ	SIP-4255  If ParentSeId = 82, then 
				   1) If group level EnableContentMatch is false, do not return keywords with MatchTypeId = 4 
				   2) If group level EnableSearchMatch is false, do not return keywords other than MatchTypeId = 4
--	07/26/10	YZ	SIP-4051 Clicks, Impressions and Cost not showing up correctly when filtering actions	   
--  07/28/10	MRS SIP-4271 Added CampaignStatusID Column in #CSKeyword Table, #CSKeyword insert satatement, and Final CTE. 

To do:
--Add support for Engine columns sort (Calculated columns left --87,89,92,94,95)
--Add support for Advance filter
--Add support for transaction type filtering
--Optimzie by cleaning up unneeded index..etc
--Use sp_ExecuteSQL to parameterize the query as opposed to dynamic SQL

EXEC SI_SP_CampaignManagement_Keyword_Read
	 @ClientID = 76
	,@StartDate = '09/01/09'
	,@ENDDate = '09/30/09'
	,@UserID  = 2
	,@isDebug = 1
	--,@AdCategoryStatusID = 1		
	,@IncludeContentMatch = 1
	,@currencyID = 73
	--,@CustomerTransactionType = '674'
	--,@PublisherFilterID = 1
	--,@PublisherFilterTypeID  = 1
	,@RowsPerPage  = 200
	,@RequestPage =1
	,@SortDescEnding = 0
	,@SortDataGridColumnID = 96
	,@SearchText = 'test'
	,@AdvancedFilterID = null
	,@AdvancedFilterXML =
 '<si>  
  <advancedfilter publisherfiltertypeid="2" publisherfiltertype="campaign">  
    <filterelement xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" filterelementid="0" filtertypeid="3" filtertype="Settings" 
    filteroperatorid="6" filteroperator="CONTAINS" datagridcolumnid="1" datafield="CampaignName">  
      <values>  
        <value>health</value>  
        <value>m</value>  
      </values>  
    </filterelement>  

    <filterelement xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" filterelementid="1" filtertypeid="4" filtertype="Performance" 
    filteroperatorid="1" filteroperator="GT" datagridcolumnid="9" datafield="impressions">  
      <values>  
        <value>1000</value>  
        <value>2000</value>  
      </values>  
    </filterelement>
  </advancedfilter>  
    <advancedfilter publisherfiltertypeid="3" publisherfiltertype="group">  
    <filterelement xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" filterelementid="4" filtertypeid="3" filtertype="Settings" 
    filteroperatorid="6" filteroperator="CONTAINS" datagridcolumnid="20" datafield="groupName">  
      <values>  
        <value>health</value>  
        <value>m</value>  
      </values>  
    </filterelement>  
        <filterelement xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" filterelementid="5" filtertypeid="3" filtertype="Settings" 
        filteroperatorid="6" filteroperator="CONTAINS" datagridcolumnid="1" datafield="CampaignName">  
      <values>  
        <value>health</value>  
        <value>m</value>  
      </values>  
    </filterelement>  

    <filterelement xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" filterelementid="6" filtertypeid="3" filtertype="Settings" 
    filteroperatorid="3" filteroperator="LT" datagridcolumnid="32" datafield="DailyBudget">  
      <values>  
        <value>10000</value>  
      </values>  
    </filterelement>  
  </advancedfilter>     
</si>'


SELECT TOP 100 * FROM [CampaignAdCategory] WHERE statusflag =1

SELECT ClientID,CampaignID, COUNT(1) FROM [CampaignAdCategory] WHERE statusflag =1
GROUP BY [ClientID], campaignID
ORDER BY COUNT(1) desc

ClientID	(No column name)
3342	114663
3299	57544
2669	48279
2958	46898
2941	45846
3460	44955
2671	40973
2319	36253
2505	33197
2246	30187
1962	29875
3421	28450
2804	26621
2639	26464
2282	25737

SELECT * FROM [LUDataGridColumn]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE 
		@SQL_Keyword_CTE NVARCHAR(max)	
		,@SQL_Keyword_Temp NVARCHAR(max)			
		,@StartDateTxt VARCHAR(20)
		,@EndDateTxt VARCHAR(20)
		,@FirstRow INT
		,@LastRow INT
		,@CurrencyIDTxt NVARCHAR(10)
		,@SQL_AdvanceFilter NVARCHAR(max)
		,@SQL_ContentMatch  NVARCHAR(max)
		,@SQL_Sort NVARCHAR(max)
		,@SQL_Keyword_Temp_Index nVARCHAR(max)
		,@SQL_LoadCSKID NVARCHAR(max)
		,@SQL_ColumnSort NVARCHAR(max)
		,@LanguageID INT		
		,@SQL_PublisherFilter NVARCHAR(max)	
		,@SQL_FinalSelect NVARCHAR(MAX)
		,@SQL_Where NVARCHAR(max)				
		,@SQL_Keyword_RPT_CTE NVARCHAR(MAX)
		,@SQL_rptTT_CTE NVARCHAR(MAX)
		,@DynamicSQL NVARCHAR(MAX)
		,@BigVar Nvarchar(max)
		,@BigVarSize BIGINT
		,@OffSet bigint		
		,@canIndex BIT
		,@RecordCount INT
		,@SortDirection VARCHAR(5)
		
	Create table #VirtualGroupDetailCache (SEID smallint, CampaignID int, AdcategoryID int)
		
--SET Varibles		
	SET @StartDateTxt = CONVERT(DATETIME, CONVERT(VARCHAR(20), @StartDate, 101))
	SET @EndDateTxt =	CONVERT(DATETIME, CONVERT(VARCHAR(20), @EndDate, 101))			
	SET @LastRow = @RequestPage * @RowsPerPage 
	SET @FirstRow = @LastRow - @RowsPerPage + 1
	SET @CurrencyIDTxt = CASE WHEN @CurrencyID IS NULL THEN 'NULL' ELSE CAST(@CurrencyID AS VARCHAR(10)) END
	SET @SQL_AdvanceFilter = ''
	SET @SQL_Keyword_Temp_Index = ''
	SET @SQL_LoadCSKID = ''	
	SET @SQL_ColumnSort = ''
	SET @SortDirection = ' ASC'
------------------------------------------------------------------------------------------------------------
------------------------------ Set all the misc parameters for the dynamic SQL -----------------------------	
--CustomerTransactiontype
	IF @CustomerTransactionType IS NOT NULL
		SET @CustomerTransactionType ='
		AND rpttt.CustomerTransactionTypeID IN ('+@CustomerTransactionType +')'
	ELSE
		SET @CustomerTransactionType = ''
		
--Content Match
	IF @IncludeContentMatch = 1 
		SET @SQL_ContentMatch = '
	AND rpt.isContentMatch = 1'
	ELSE IF @IncludeContentMatch = 0 
		SET @SQL_ContentMatch = '
	AND rpt.isContentMatch = 0'
	ELSE
		SET @SQL_ContentMatch = ''
	
--See if there is an Advance Filter
--Advance Filter
	IF @AdvancedFilterID IS NOT NULL
	BEGIN
		SELECT  @AdvancedFilterXML = AdvancedFilterXML  
		FROM AdvancedFilter
		WHERE @AdvancedFilterID =AdvancedFilterID 
		
		SET @SQL_AdvanceFilter = '
WHERE 1 =1 ' + dbo.fn_CampaignManagementAdvancedFilter(@AdvancedFilterXML,5)
	END	
	ELSE
		SET @SQL_AdvanceFilter = '
WHERE 1 = 1 ' + dbo.fn_CampaignManagementAdvancedFilter(@AdvancedFilterXML,5)
	
--See if there is a search text
	 IF @SearchText IS NULL
		SET @SearchText = '
'
	ELSE
	BEGIN
		SET @SearchText = REPLACE(REPLACE(@SearchText,'_','[_]'),'%','[%]')
		-- 2010-05-24 WDJ Handle Single Quotes (remember to change this SPROC to use sp_executeSQL w/parameters to prevent having to have special cases for special charactrers)
		SET @SearchText = REPLACE(@SearchText,'''','''''');
		SET @SearchText = '
	AND (csk.Keyword LIKE N''%'+@SearchText+'%''
		OR cac.AdCategoryName LIKE N''%'+@SearchText+'%''
		OR cpn.CampaignTitle  LIKE N''%'+@SearchText+'%''
		OR (isRedirect=1 AND csk.redirectURL LIKE N''%'+@SearchText+'%'')
		OR (isRedirect!=1 AND csk.URL LIKE N''%'+@SearchText+'%'' ))
'
	END
-- SET SORT COLUMN
	SELECT @SQL_Sort = QUOTENAME(ISNULL(dbc.DatabaseColumnName, dgc.DataField))
			,@canIndex = canIndex
	FROM
		dbo.[LUDataGridColumn] AS dgc
		LEFT JOIN dbo.LUDataBaseColumn AS dbc ON dbc.DataBaseColumnID = dgc.DataBaseColumnID
	WHERE  DataGridColumnID = @SortDataGridColumnID

	IF @SortDescending = 1
		SET @SortDirection =  ' DESC'		

--Localization
	SELECT @LanguageID = ISNULL(ID,1) 
	FROM Users u
		LEFT JOIN LUCulture c ON u.Cultureid = c.cultureID
		LEFT JOIN Languages l ON c.CultureCode = l.culture_name
	WHERE userid = @userID
		AND is_supported = 1

	IF @LanguageID IS NULL
		SET @LanguageID = 1
				
--Where Clause
--Handle the PublisherFilter
IF @PublisherFilterTypeID = 1 AND @PublisherFilterTypeID IS NOT NULL  --SEID
	BEGIN
		SET @SQL_PublisherFilter = 
'	AND CampaignSearchEngine.seid = ' + CAST(@PublisherFilterID AS VARCHAR(10)) + '--Publisher Filter by SearchEngine'
	END
	ELSE IF @PublisherFilterTypeID = 2  --CampaignID
	BEGIN
		SET @SQL_PublisherFilter = 
'	AND cpn.CampaignID = ' + CAST(@PublisherFilterID AS VARCHAR(10)) + '--Publisher Filter by Campaign ID'
	END
	ELSE IF @PublisherFilterTypeID = 3  --GroupID
	BEGIN
		SET @SQL_PublisherFilter = 
'	AND cac.AdCategoryID = ' + CAST(@PublisherFilterID AS VARCHAR(10)) + '--Publisher Filter by Group ID'
	END
ELSE	
	SET @SQL_PublisherFilter = ''
		
	IF @KeywordStatusID IS NOT NULL
	BEGIN
		SET @SQL_Where =
'WHERE csk.ClientID = ' + CAST(@ClientID AS VARCHAR(10))+'
	AND csk.StatusFlag = 1
	AND cac.StatusFlag = 1
	AND cpn.StatusFlag = 1 
	AND CampaignSearchEngine.StatusFlag = 1
	AND csk.CSKeywordStatusID in (' + @KeywordStatusID + ')'
	END
	ELSE
	begin
		SET @SQL_Where =
'WHERE csk.ClientID = ' + CAST(@ClientID AS VARCHAR(10))+'
	AND csk.StatusFlag = 1
	AND cac.StatusFlag = 1
	AND cpn.StatusFlag = 1 
	AND CampaignSearchEngine.StatusFlag = 1'
	END
	
	if @VGID >= 0
	begin
		if @VGID = 0
			insert into #VirtualGroupDetailCache
				(SEID, CampaignID, AdcategoryID)
			select cs.SEID, ca.CampaignID, ac.AdCategoryID
			from Campaign ca join CampaignSearchEngine cs on ca.ClientID = @ClientID and ca.CampaignID = cs.CampaignID
			join CampaignadCategory ac on ac.CampaignID = ca.CampaignID
			where not exists (select 1 from dbo.VirtualGroupDetailCache where ClientID = @ClientID and VGID = VGID and SEID = cs.SEID and CampaignID = ca.CampaignID and (AdcategoryID = 0 or AdcategoryID = ac.AdcategoryID))
			--select @SQL_FinalSelect = @SQL_FinalSelect + ' and not exists (select 1 from dbo.VirtualGroupDetailCache where ClientID = ' + CAST(@ClientID AS VARCHAR(10)) + ' and VGID = VGID and SEID = FinalCTE.SEID and CampaignID = FinalCTE.CampaignID and (AdcategoryID = 0 or AdcategoryID = FinalCTE.AdcategoryID)) '

		else
			insert into #VirtualGroupDetailCache
				(SEID, CampaignID, AdcategoryID)
			select cs.SEID, ca.CampaignID, ac.AdCategoryID
			from Campaign ca join CampaignSearchEngine cs on ca.ClientID = @ClientID and ca.CampaignID = cs.CampaignID
			join CampaignadCategory ac on ac.CampaignID = ca.CampaignID
			where exists (select 1 from dbo.VirtualGroupDetailCache where ClientID = @ClientID and VGID = @VGID and SEID = cs.SEID and CampaignID = ca.CampaignID and (AdcategoryID = 0 or AdcategoryID = ac.AdcategoryID))

		create Clustered Index idx_VGDC_SEID on #VirtualGroupDetailCache (SEID, CampaignID, AdcategoryID)
			--select @SQL_FinalSelect = @SQL_FinalSelect + ' and exists (select 1 from dbo.VirtualGroupDetailCache where ClientID = ' + CAST(@ClientID AS VARCHAR(10)) + ' and VGID = ' + CAST(@VGID AS VARCHAR(10)) + ' and SEID = FinalCTE.SEID and CampaignID = FinalCTE.CampaignID and (AdcategoryID = 0 or AdcategoryID = FinalCTE.AdcategoryID)) '
			
		select @SQL_Where = @SQL_Where + ' and exists (select 1 from #VirtualGroupDetailCache where SEID = CSK.SEID and CampaignID = CSK.CampaignID and AdcategoryID = CSK.AdcategoryID) '
	end

SET @SQL_Where = @SQL_Where + @SQL_PublisherFilter + @SearchText 
------------------------------------------------------------------------------------------------------------------
 CREATE TABLE #CSKeyword
(	Keyword [nvarchar](200) COLLATE Latin1_General_CI_AS_KS_WS NULL
	,CSKID INT 
	,AdCategoryName	NVARCHAR(200)
	,CampaignTitle NVARCHAR(100)
	,SearchEngine NVARCHAR(25)
	,KeywordStatusDesc VARCHAR(20)
	,InheritedStatusID TINYINT
	,KeywordMatchDesc VARCHAR(50)		
	,CurrentRank NUMERIC(18,2)	
	,FinalBid MONEY	
	,SearchBidConverted MONEY	
	,MainBidAmount MONEY
	,MinBid MONEY
	,BidMethod VARCHAR(100)	
	,BidMethodType VARCHAR(100)
	,BidMethodGroup VARCHAR(100)
	,DestinationURL NVARCHAR(2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL	
	,OrganicRank VARCHAR(5)	
	,SEID smallint
	,CampaignID INT
	,AdCategoryID INT
	,DailyBudgetConverted MONEY	
	,DetailStatusID INT
	,CurrencyCode VARCHAR(10)
	,EnableContentMatch BIT
	,EnableSearchMatch BIT 
	,KeywordMatchTypeID TINYINT
	,ContentBidConverted MONEY	
	,KeywordStatusID INT
	,BidRuleID INT	
	,BidRuleTypeID INT
	,GlobalRule BIT
	,isSpot BIT
	,SpotID INT
	,KeywordSearchEngineDetailStatusID INT
	,GroupEnableContentMatch bit
	,GroupEnableSearchMatch bit
	,ParentSEID int
	,CampaignStatusID INT
)
---------------------------------------------------------------------------------------------------------------
--Group CTE RPT tables
IF @CustomerTransactionType = ''
BEGIN
	SET @SQL_Keyword_RPT_CTE = 
'WITH KeywordRPTTables_CTE AS
(
SELECT
	rpt.CSKID
	,SUM(NumImpressions) AS NumImpressions
	,SUM(NumClicksReported) AS NumClicksReported
	,SUM(Cost * ISNULL(cx.ExchangeRate, 1.0)) AS Cost
	,SUM(TransactionAmount * ISNULL(cx.ExchangeRate, 1.0)) AS TransactionAmount
	,SUM(ISNULL(rpt.TTCount, rpt.TransactionCount)) AS TransactionCount
	,SUM(TransactionCountWithWeight) AS TransactionCountWithWeight
FROM
	SIOLAP.dbo.RPT_PS_Summary_CSKLevel AS rpt
	LEFT JOIN SearchEngine ON SearchEngine.seid = rpt.SEID
	LEFT JOIN CurrencyExchangeData cx ON cx.FromCurrencyID = SearchEngine.CurrencyID 
		AND ToCurrencyID = ISNULL('+ @CurrencyIDTxt+', FromCurrencyID)
WHERE ClientID = '+CAST(@ClientID AS VARCHAR(10)) + ' 
	AND GenerateDate BETWEEN '''+@StartDateTxt+''' AND '''+@EndDateTxt+'''' + @SQL_ContentMatch + '
	AND EXISTS (SELECT 1 FROM #CSKeyword AS csk WHERE rpt.cskid = csk.cskID)	
GROUP BY CSKID
)'
END
ELSE
BEGIN
	SET @SQL_Keyword_RPT_CTE = 
'WITH KeywordRPTTables_CTE AS
(
SELECT
	rpt.CSKID
	,SUM(NumImpressions) AS NumImpressions
	,SUM(NumClicksReported) AS NumClicksReported
	,SUM(Cost * ISNULL(cx.ExchangeRate, 1.0)) AS Cost
	,rpttt2.TransactionAmount  AS TransactionAmount
	,rpttt2.TransactionCount AS TransactionCount
	--,SUM(TransactionCountWithWeight) AS TransactionCountWithWeight
	,rpttt2.TransactionCountWithWeight as TransactionCountWithWeight
	--ISNULL(rpttt2.TTCount, rpttt2.TransactionCount) * ISNULL(Weight, 1)
FROM
	SIOLAP.dbo.RPT_PS_Summary_CSKLevel AS rpt
	left JOIN (select CSKID, sum(TransactionAmount* ISNULL(cx.ExchangeRate, 1.0)) as TransactionAmount, sum(ISNULL(TTCount, TransactionCount)) as TransactionCount,
				sum(ISNULL(TTCount, TransactionCount)* ISNULL(Weight, 1)) as TransactionCountWithWeight
			from SIOLAP.dbo.RPT_PS_Summary_CustomerTT rpttt
			LEFT JOIN SIOLAP.dbo.ClientCustomerTransactionTypeWeight AS w ON
		w.ClientID = rpttt.ClientID
		AND w.CustomerTransactionTypeID = rpttt.CustomerTransactionTypeID	
		LEFT JOIN SearchEngine se ON se.seid = rpttt.SEID
	LEFT JOIN CurrencyExchangeData cx ON cx.FromCurrencyID = se.CurrencyID 
		AND ToCurrencyID = ISNULL('+ @CurrencyIDTxt+', FromCurrencyID)
			where rpttt.ClientID = '+CAST(@ClientID AS VARCHAR(10)) + ' 
	AND GenerateDate BETWEEN '''+@StartDateTxt+''' AND '''+@EndDateTxt+'''' + @CustomerTransactionType +@SQL_ContentMatch + '
	group by CSKID) AS rpttt2 ON
		rpttt2.cskid = rpt.cskid
	LEFT JOIN SearchEngine ON SearchEngine.seid = rpt.SEID
	LEFT JOIN CurrencyExchangeData cx ON cx.FromCurrencyID = SearchEngine.CurrencyID 
		AND ToCurrencyID = ISNULL('+ @CurrencyIDTxt+', FromCurrencyID)
WHERE rpt.ClientID = '+CAST(@ClientID AS VARCHAR(10)) + ' 
	AND rpt.GenerateDate BETWEEN '''+@StartDateTxt+''' AND '''+@EndDateTxt+'''' + @SQL_ContentMatch + '
	AND EXISTS (SELECT 1 FROM #CSKeyword AS csk WHERE rpt.cskid = csk.cskID)
GROUP BY rpt.CSKID, rpttt2.TransactionAmount, rpttt2.TransactionCount,rpttt2.TransactionCountWithWeight
)'
	
END
	
--Build a temp table based on the sort column and standard filters
IF @AdvancedFilterXML IS NULL 
	AND @SortDataGridColumnID IN (72,73,74,75,76,77,78,79,80,81,82,84,85,86,88,93,96,144,149,153,154)
BEGIN
	DECLARE @SQL_RowNumber VARCHAR(500)
	
	SET @SQL_RowNumber = ',ROW_NUMBER() OVER(ORDER BY ' + @SQL_Sort +  @SortDirection + ' ,csk.CSKID) AS RowNumber'
		
	CREATE TABLE #cskid (CSKID INT, RowNumber INT,RecordCount INT)
	
	IF @SortDataGridColumnID = 76
	BEGIN
		SET @SQL_ColumnSort =  'JOIN SearchEngine se ON CampaignSearchEngine.SEID = se.SEID
'		
	END
	ELSE IF @SortDataGridColumnID = 77
	BEGIN
		SET @SQL_ColumnSort =  'JOIN LUKeywordStatus AS kws ON kws.KeywordStatusID = csk.CSKeywordstatusID
'		
	END
	ELSE IF @SortDataGridColumnID = 79
	BEGIN
		SET @SQL_ColumnSort =  'LEFT JOIN CSKeywordsRankInfo AS cskr ON cskr.CSKID = csk.CSKID
'		
	END
	ELSE IF @SortDataGridColumnID = 80 -- Just order by finalbid, same as converted
	BEGIN
		SET @SQL_ColumnSort =  '	LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
'		
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY b.FinalBid ' + @SortDirection + ', csk.CSKID) AS RowNumber'
	END	
--	ELSE IF @SortDataGridColumnID = 80
--	BEGIN
--		SET @SQL_ColumnSort =  '	LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
--	JOIN SearchEngine se ON CampaignSearchEngine.seid = se.seid
--	LEFT JOIN CurrencyExchangeData ed ON ed.FromCurrencyID = se.CurrencyID
--		AND ToCurrencyID = ISNULL(NULL, FromCurrencyID)
--'		
--		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY (b.FinalBid * ISNULL(ExchangeRate,1.0)), csk.CSKID ' + @SortDirection + ') AS RowNumber'
--	END
	ELSE IF @SortDataGridColumnID = 81
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY MinBid ' + @SortDirection + ', csk.CSKID) AS RowNumber'
	END	
	ELSE IF @SortDataGridColumnID = 82
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY (CASE	WHEN csk.BidRuleID IS NULL AND SPOTID IS NULL THEN ''Manual Bid''
			WHEN csk.BidRuleID IS NULL AND SPOTID IS NOT NULL THEN ''SPOT''
			WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 1 THEN ''Global Bid Rule''
			WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 0 THEN ''Bid Rule''
		END) ' + @SortDirection + ', csk.CSKID) AS RowNumber'
		
		SET @SQL_ColumnSort =  '	LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
	LEFT JOIN BidRule AS br	ON br.BidRuleID = csk.BidRuleID
	LEFT JOIN SpotAdgroups sa ON sa.AdCategoryID = cac.AdCategoryID
'		
	END	
	ELSE IF @SortDataGridColumnID = 83
	BEGIN
		SET @SQL_ColumnSort =  'LEFT JOIN BidRule AS br	ON br.BidRuleID = csk.BidRuleID
	LEFT JOIN LUBidRuleType brt  ON brt.BidRuleTypeID = br.BidRuleTypeID
'			
	END		
	ELSE IF @SortDataGridColumnID = 84
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY (CASE WHEN isRedirect = 1 THEN csk.redirectURL ELSE csk.URL end) ' + @SortDirection + ', csk.CSKID) AS RowNumber'
	END	
	ELSE IF @SortDataGridColumnID = 96
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY ((CASE
		WHEN [Rank] IS NULL THEN ''-''
		WHEN [Rank] <= 30 THEN CONVERT(VARCHAR(5), [Rank])
	ELSE ''30+'' END) ) ' + @SortDirection + ', csk.CSKID) AS RowNumber'
		SET @SQL_ColumnSort =  '	LEFT JOIN dbo.SEOKeywordRank AS seo ON seo.ClientID = csk.ClientID AND seo.isActive = 1 AND seo.Keyword = csk.Keyword
'		
	END		
	ELSE IF @SortDataGridColumnID = 144
	BEGIN
		SET @SQL_ColumnSort =  '	LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
'		
	END	
	ELSE IF @SortDataGridColumnID = 149
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY (CASE
		WHEN cac.AdCategoryStatusID = 2 THEN ''Group Paused''
		WHEN cac.AdCategoryStatusID = 4 THEN ''Group Deleted''
		WHEN cpn.CampaignStatusID = 2 THEN ''Campaign Paused''
		WHEN cpn.CampaignStatusID = 4 THEN ''Campaign Deleted''
		ELSE NULL
	END)' + @SortDirection + ', csk.CSKID) AS RowNumber'
	END	
	ELSE IF @SortDataGridColumnID = 153
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY (CASE	WHEN csk.BidRuleID IS NULL AND SPOTID IS NULL THEN ''Manual''
			WHEN csk.BidRuleID IS NULL AND SPOTID IS NOT NULL THEN ''SPOT''
			WHEN br.BidruleTypeID  > 0  THEN BidruleTypeDesc
		END)' + @SortDirection + ', csk.CSKID) AS RowNumber'
		
		SET @SQL_ColumnSort =  ' LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
	LEFT JOIN BidRule AS br	ON br.BidRuleID = csk.BidRuleID
	LEFT JOIN SpotAdgroups sa ON sa.AdCategoryID = cac.AdCategoryID
	LEFT JOIN LUBidRuleType brt  ON brt.BidRuleTypeID = br.BidRuleTypeID
'
	END	
	ELSE IF @SortDataGridColumnID = 154
	BEGIN
		SET @SQL_RowNumber = '	,ROW_NUMBER() OVER(ORDER BY (CASE WHEN csk.BidRuleID IS NULL AND SPOTID IS NULL THEN ''''
			WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 0 THEN ''''
			WHEN csk.BidRuleID IS NULL AND SPOTID IS NOT NULL THEN
			(SELECT TOP 1 NAME FROM dbo.CampaignOptimizerSettings spot WHERE spot.SPOTID = sa.SPOTID)
			WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 1 THEN BidRuleName
		END)' + @SortDirection + ', csk.CSKID ' + @SortDirection + ') AS RowNumber'
		
		SET @SQL_ColumnSort =  ' LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
	LEFT JOIN BidRule AS br	ON br.BidRuleID = csk.BidRuleID
	LEFT JOIN SpotAdgroups sa ON sa.AdCategoryID = cac.AdCategoryID
	LEFT JOIN LUBidRuleType brt  ON brt.BidRuleTypeID = br.BidRuleTypeID
'
	END		
	ELSE
	
	BEGIN	
		SET @SQL_ColumnSort = ''
	END	
--Code to load the page
	IF @SortDataGridColumnID IN (72,73,74,75,76,77,78,79,80,81,82,84,96,144,149, 153, 154)
	BEGIN --different cte if it not engine data
		SET @SQL_LoadCSKID =
	';WITH CSKID_CTE AS
	(
	SELECT
		csk.cskid
		' + @SQL_RowNumber + '
	FROM cskeywords csk
		JOIN CampaignAdCategory cac ON csk.AdCategoryID = cac.AdCategoryID
		JOIN Campaign AS cpn on cpn.CampaignID = csk.CampaignID
		JOIN CampaignSearchEngine ON cpn.CampaignID = CampaignSearchEngine.CampaignID
		join SearchEngine se on se.SEID=  csk.SEID
	' + @SQL_ColumnSort 
	+ @SQL_Where
	+ ' and (Case when ParentSEID = 82 and GroupEnableContentMatch = 0 and GroupEnableSearchMatch = 0 then 0
				when ParentSEID = 82 and GroupEnableContentMatch = 0 and GroupEnableSearchMatch = 1 and csk.KeywordMatchTypeID = 4 then 0
				when ParentSEID = 82 and GroupEnableContentMatch = 1 and GroupEnableSearchMatch = 0 and csk.KeywordMatchTypeID <> 4 then 0
				else 1 end) = 1),Max_CTE AS
	(
	SELECT
		MAX(RowNumber) AS maxRowNumber
	FROM CSKID_CTE
	)
	INSERT INTO #cskid(CSKID, RowNumber, RecordCount)
	SELECT
		CSKID
		,RowNumber
		,(SELECT TOP 1 (maxRowNumber) FROM Max_CTE)
	FROM CSKID_CTE
	WHERE RowNumber BETWEEN '+CAST(@FirstRow AS VARCHAR(10))+' AND '+CAST(@LastRow AS VARCHAR(10)) + '
	'
END
ELSE IF @SortDataGridColumnID IN (85,86,87,88,89,90,91,92,93,94,95)
BEGIN
		SET @SQL_LoadCSKID  = 
';WITH RPT_CTE AS
(
SELECT
	csk.CSKID
	,SUM(NumImpressions) AS NumImpressions
	,SUM(NumClicksReported) AS NumClicksReported
	,SUM(Cost * ISNULL(cx.ExchangeRate, 1.0)) AS Cost
	,SUM(TransactionAmount * ISNULL(cx.ExchangeRate, 1.0)) AS TransactionAmount
	,SUM(ISNULL(rpt.TTCount, rpt.TransactionCount)) AS TransactionCount
	,SUM(TransactionCountWithWeight) AS TransactionCountWithWeight
FROM cskeywords csk
	JOIN CampaignAdCategory cac ON csk.AdCategoryID = cac.AdCategoryID
	JOIN Campaign AS cpn on cpn.CampaignID = csk.CampaignID
	JOIN CampaignSearchEngine ON cpn.CampaignID = CampaignSearchEngine.CampaignID
	LEFT JOIN SIOLAP.dbo.RPT_PS_Summary_CSKLevel AS rpt ON csk.cskid = rpt.cskid
		AND rpt.ClientID = '+CAST(@ClientID AS VARCHAR(10)) + ' 
		AND rpt.GenerateDate BETWEEN '''+@StartDateTxt+''' AND '''+@EndDateTxt+'''' + @SQL_ContentMatch + '	
	JOIN SearchEngine ON SearchEngine.seid = csk.SEID
	LEFT JOIN CurrencyExchangeData cx ON cx.FromCurrencyID = SearchEngine.CurrencyID 
		AND ToCurrencyID = ISNULL(73, FromCurrencyID)
'+  @SQL_Where + '  and (Case when ParentSEID = 82 and GroupEnableContentMatch = 0 and GroupEnableSearchMatch = 0 then 0
				when ParentSEID = 82 and GroupEnableContentMatch = 0 and GroupEnableSearchMatch = 1 and csk.KeywordMatchTypeID = 4 then 0
				when ParentSEID = 82 and GroupEnableContentMatch = 1 and GroupEnableSearchMatch = 0 and csk.KeywordMatchTypeID <> 4 then 0
				else 1 end) = 1	GROUP BY csk.CSKID
'
+		
	'),CSKID_CTE AS
	(
	SELECT
		cskid
		' + @SQL_RowNumber + '
	FROM RPT_CTE csk
	),Max_CTE AS
	(
	SELECT
		MAX(RowNumber) AS maxRowNumber
	FROM CSKID_CTE
	)
	INSERT INTO #cskid(CSKID, RowNumber, RecordCount)
	SELECT
		CSKID
		,RowNumber
		,(SELECT TOP 1 (maxRowNumber) FROM Max_CTE)
	FROM CSKID_CTE
	WHERE RowNumber BETWEEN '+CAST(@FirstRow AS VARCHAR(10))+' AND '+CAST(@LastRow AS VARCHAR(10)) + '
	'		
END
	SET @SQL_Where = @SQL_Where + '	AND EXISTS (SELECT 1 FROM #CSKID AS CSKID WHERE CSK.cskid = cskID.cskID)
	'

	EXECUTE(@SQL_LoadCSKID)
		
	SELECT @RecordCount = (SELECT TOP 1 RecordCount FROM #CSKID)
END

SET @SQL_Keyword_Temp =
'
INSERT INTO #CSKeyword
SELECT
	csk.Keyword
	,csk.CSKID
	,cac.AdCategoryName	
	,cpn.CampaignTitle
	,se.SearchEngine		
	,KeywordStatusDesc
	,CASE
		WHEN cac.AdCategoryStatusID = 2 THEN 2
		WHEN cac.AdCategoryStatusID = 4 THEN 4
		WHEN cpn.CampaignStatusID = 2 THEN 1
		WHEN cpn.CampaignStatusID = 4 THEN 3
	ELSE NULL END AS InheritedStatusID
	,CASE
		WHEN [ParentSEID] = 33 AND csk.KeywordMatchTypeID = 1 THEN ''Advanced''
		WHEN [ParentSEID] = 33 AND csk.KeywordMatchTypeID = 2 THEN ''Standard''
		ELSE KeywordMatchDesc END AS KeywordMatchDesc
	,ISNULL(cskr.CurrentRank, 0) AS CurrentRank
	,ISNULL(b.FinalBid, 0) AS FinalBid
	,(b.FinalBid*ISNULL(ExchangeRate,1.0)) AS SearchBidConverted
	,ISNULL(csk.MainBidAmount, 0) AS MainBidAmount
	,ISNULL(csk.MinBid, 0) AS MinBid
	,CASE
		WHEN csk.BidRuleID IS NULL AND SPOTID IS NULL THEN ''Manual Bid''
		WHEN csk.BidRuleID IS NULL AND SPOTID IS NOT NULL THEN ''SPOT''
		WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 1 THEN ''Global Bid Rule''
		WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 0 THEN ''Bid Rule''
	END AS BidMethod
	,CASE
		WHEN csk.BidRuleID IS NULL AND SPOTID IS NULL THEN ''Manual''
		WHEN csk.BidRuleID IS NULL AND SPOTID IS NOT NULL THEN ''SPOT''
		WHEN br.BidruleTypeID > 0 THEN BidruleTypeDesc
	END AS BidMethodType
	,CASE
		WHEN csk.BidRuleID IS NULL AND SPOTID IS NULL THEN ''''
		WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 0 THEN ''''
		WHEN csk.BidRuleID IS NULL AND SPOTID IS NOT NULL THEN (SELECT TOP 1 NAME FROM dbo.CampaignOptimizerSettings spot WHERE spot.SPOTID = sa.SPOTID)
		WHEN csk.BidruleID IS NOT NULL AND GlobalRule = 1 THEN BidRuleName
	END AS BidMethodGroup
	,CASE WHEN isRedirect = 1 THEN csk.redirectURL ELSE csk.URL END AS DestinationURL
	,(CASE
		WHEN [Rank] IS NULL THEN ''-''
		WHEN [Rank] <= 30 THEN CONVERT(VARCHAR(5), [Rank])
	ELSE ''30+'' END) AS OrganicRank
	,se.SEID
	,csk.CampaignID
	,cac.AdCategoryID
	,(CampaignSearchEngine.DailyBudget * ISNULL(ExchangeRate,1.0)) AS DailyBudgetConverted
	,CASE csk.KeywordSearchEngineDetailStatusID
		WHEN 5 THEN 7
		WHEN 4 THEN 8
		WHEN 2 THEN 9
		WHEN 1 THEN 9
		WHEN 6 THEN 10
		ELSE csk.CSKeywordstatusID
	END AS DetailStatusID
    ,lc.CurrencyCode
    ,CampaignSearchEngine.EnableContentMatch
    ,CampaignSearchEngine.EnableSearchMatch
	,csk.KeywordMatchTypeID
	,(cac.ContentBid * ISNULL(ExchangeRate,1.0)) AS ContentBidConverted
	,KeywordStatusID
	,csk.BidRuleID
	,br.BidRuleTypeID
	,GlobalRule
	,CASE WHEN SpotID IS NULL THEN 0 ELSE 1 END AS isSpot
	,SPOTID
	,csk.KeywordSearchEngineDetailStatusID
	,isnull(cac.GroupEnableContentMatch, 0)
	,isnull(cac.GroupEnableSearchMatch, 0)
	,se.ParentSEID
	,CampaignStatusID
FROM CSKeywords AS csk
	JOIN CampaignAdCategory cac ON csk.AdCategoryID = cac.AdCategoryID
	JOIN Campaign AS cpn on cpn.CampaignID = csk.CampaignID
	JOIN CampaignSearchEngine ON cpn.CampaignID = CampaignSearchEngine.CampaignID
	JOIN SearchEngine se ON CampaignSearchEngine.seid = se.seid
	LEFT JOIN CurrencyExchangeData ed ON ed.FromCurrencyID = se.CurrencyID AND ToCurrencyID = ISNULL('+ @CurrencyIDTxt+', FromCurrencyID)
	LEFT JOIN LUKeywordStatus AS kws ON kws.KeywordStatusID = csk.CSKeywordstatusID
	LEFT JOIN LUKeywordMatchType AS kwm ON kwm.KeywordMatchTypeID = csk.KeywordMatchTypeID
	LEFT JOIN dbo.SEOKeywordRank AS seo ON seo.ClientID = csk.ClientID AND seo.isActive = 1 AND seo.Keyword = csk.Keyword
	LEFT JOIN CSKeywordsRankInfo AS cskr ON cskr.CSKID = csk.CSKID
	JOIN LUCurrency lc on lc.CurrencyID = se.CurrencyID
	LEFT JOIN Bid AS b on b.CSKID = csk.CSKID
	LEFT JOIN BidRule AS br	ON br.BidRuleID = csk.BidRuleID
	LEFT JOIN SpotAdgroups sa ON sa.AdCategoryID = cac.AdCategoryID
	LEFT JOIN LUBidRuleType brt  ON brt.BidRuleTypeID = br.BidRuleTypeID
	' + @SQL_Where

IF @isDebug != 1
	EXEC(@SQL_Keyword_Temp)
	

--Create index after table is loaded
CREATE INDEX idx_CSKeyword_CSKID  ON  #CSKeyword
([CSKID] ASC)

	SET @SQL_Sort = @SQL_Sort +  @SortDirection	
		
if @canIndex = 'true' AND 1=2 --temp removed not sure if this helps or hurts yet
begin
	SET @SQL_Keyword_Temp_Index = '
	
	CREATE INDEX idx_CSKeyword  ON  #CSKeyword
	('+@SQL_Sort+')
	'
	EXEC(@SQL_Keyword_Temp_Index)
END
	
---------------------------------------------------------------------------------------------------------------
--Group CTE base tables
	SET @SQL_Keyword_CTE = 
'WITH KeywordBaseTables_CTE AS
(
SELECT
	csk.CSKID
	,csk.Keyword
	,csk.AdCategoryID
	,csk.AdCategoryName
	,csk.CampaignID
	,csk.CampaignTitle
	,csk.SEID
	,csk.SearchEngine
	,csk.DailyBudgetConverted
	,csk.ContentBidConverted
	,csk.KeywordStatusID
	,csk.KeywordStatusDesc
	,csk.KeywordMatchTypeID
	,csk.KeywordMatchDesc
	,csk.CurrentRank
	,csk.MinBid
	,csk.URL
	,csk.OrganicRank
	,csk.InheritedStatusID	
	,csk.FinalBid	
	,csk.FinalBidConverted
	,csk.BidMethod
	,csk.BidMethodType
	,csk.BidMethodGroup
	,csk.BidRuleID
	,csk.BidRuleTypeID
	,csk.CurrencyCode
	,csk.GlobalRule
	,csk.isSpot
	,csk.SpotID
	,csk.,KeywordSearchEngineDetailStatusID
FROM #CSKeyword	csk
)'		


----------------------------------------------------------------------------------------------------				
SELECT @SQL_FinalSelect =
'SELECT
	*
	,ROW_NUMBER() OVER(ORDER BY '+@SQL_Sort +') AS RowNumber
INTO #Keyword 
FROM FinalCTE '
+ @SQL_AdvanceFilter 
+ CASE WHEN @RecordCount IS NOT NULL THEN '
SELECT ' +CAST(@RecordCount AS VARCHAR(10)) ELSE '
SELECT count(1) FROM #Keyword ' END
+ '

SELECT
	Keyword
	,CSKID AS [Keyword ID]
	,AdCategoryName AS [Group Name]
	,CampaignTitle AS [Campaign Name]
	,SearchEngine AS Publisher
	,KeywordStatusDesc AS Status
	,InheritedStatus AS [Inherited Status]
	,KeywordMatchDesc AS [Match Type]
	,CurrentRank AS [Current Rank]
	,FinalBid AS [Search Bid]
	,SearchBidConverted AS [Search Bid Converted]
	,FirstPageMinBid AS [First Page/Min Bid]
	,BidMethod AS [Bid Method]
	,BidMethodType AS [Bid Method Type]
	,BidMethodGroup AS [Bid Method Group]
	,DestinationURL AS [Destination URL]
	,NumImpressions AS Impressions
	,NumClicksReported AS Clicks
	,CTR
	,Cost
	,CPC	
	,TransactionCount AS [Actions]
	,WeightedActions AS [Weighted Actions]
	,ConversionRate AS [Conversion Rate]	
	,TransactionAmount AS Revenue
	,CPA
	,ROAS AS [ROAS%]
	,OrganicRank AS [Organic Rank]
	,AdCategoryID
	,CampaignID
	,KeywordMatchTypeID
	,CurrencyCode
	,EnableContentMatch
	,EnableSearchMatch	
	,SEID
	,KeywordStatusID
	,BidRuleID
	,BidRuleTypeID
	,GlobalRule
	,isSpot
	,SpotID
FROM
	#Keyword AS tmp
' + CASE WHEN @RecordCount IS NOT NULL THEN '
' ELSE ' WHERE RowNumber BETWEEN '+CAST(@FirstRow AS VARCHAR(10))+' AND '+CAST(@LastRow AS VARCHAR(10)) END


---------------------------------------------------------------------------------------------------------------
--Build the Dynamic SQL	
SET @DynamicSQL = ';
'	+ ISNULL(@SQL_Keyword_RPT_CTE,'')
	+ ISNULL(@SQL_rptTT_CTE,'') 
+ ' ,FinalCTE AS
(
SELECT
	Keyword
	,k.CSKID
	,AdCategoryID
	,AdCategoryName
	,CampaignID
	,CampaignTitle
	,DailyBudgetConverted
	,KeywordStatusID
	,CASE WHEN KeywordStatusID = 1 THEN --JIRA SIP-3581
			(SELECT KeywordSearchEngineDetailStatusDesc 
				FROM LUKeywordSearchEngineDetailStatus ksedsd
				WHERE ksedsd.KeywordSearchEngineDetailStatusID = k.KeywordSearchEngineDetailStatusID)
			ELSE KeywordStatusDesc END AS KeywordStatusDesc
	--,KeywordStatusDesc
	,InheritedStatusDesc AS InheritedStatus
	,KeywordMatchDesc
	,SEID
	,SearchEngine
	,CurrentRank
	,FinalBid
	,MinBid AS FirstPageMinBid
	,BidMethod
	,BidMethodType
	,BidMethodGroup
	,EnableContentMatch
	,EnableSearchMatch
	,DestinationURL
	,ContentBidConverted
	,GlobalRule
	,ISNULL(NumImpressions,0) AS NumImpressions
	,ISNULL(NumClicksReported,0) AS NumclicksReported
	,ISNULL(Cost,0.0) AS Cost
	,CASE WHEN ISNULL(NumImpressions,0) > 0 THEN ISNULL(100.00 * NumClicksReported / NumImpressions,0) ELSE 0 END AS CTR
    ,CASE WHEN NumClicksReported > 0 THEN ISNULL(Cost/NumClicksReported, 0) ELSE 0 END AS CPC
	,ISNULL(TransactionCount,0) AS TransactionCount
	,ISNULL(TransactionCountWithWeight,0) AS WeightedActions
	,CASE WHEN (ISNULL(TransactionCount,0) > 0 AND ISNULL(NumClicksReported,0) > 0) THEN ISNULL(TransactionCount/NumClicksReported * 100,0) ELSE 0 END AS [ConversionRate]
	,ISNULL(TransactionAmount, 0) AS TransactionAmount
    ,CASE WHEN (ISNULL(TransactionCount,0) > 0 AND ISNULL(Cost,0) > 0) THEN ISNULL(cost/TransactionCount,0) ELSE 0 END AS CPA
	,CASE WHEN (ISNULL(TransactionAmount,0) > 0 AND ISNULL(Cost,0) > 0) THEN ISNULL(TransactionAmount/Cost,0) ELSE 0 END AS ROAS
	,OrganicRank
	,KeywordMatchTypeID
	,CurrencyCode
	,BidRuleID
	,SearchBidConverted
	,BidRuleTypeID
	,isSpot
	,SpotID
	,CampaignStatusID
FROM #CSKeyword	 k
	LEFT JOIN KeywordRPTTables_CTE rpt ON k.cskid = rpt.cskid
	LEFT JOIN LUInheritedStatus AS lis ON k.InheritedStatusID = lis.InheritedStatusID
)
' + @SQL_FinalSelect

	IF @isDebug =1
	BEGIN
		PRINT '/*'
		PRINT 'Advance Filter XML:'
		PRINT CAST(@AdvancedFilterXML AS VARCHAR(max))
		PRINT ''
		PRINT 'Advance Filter SQL:'
		PRINT @SQL_AdvanceFilter
		PRINT ''
		PRINT '@SQL_Where = ' + ISNULL(@SQL_Where,'null' )
		PRINT '@SQL_PublisherFilter = ' + ISNULL(@SQL_PublisherFilter,'null')
		PRINT '@SearchText = ' + ISNULL(@SearchText,'NULL')
		PRINT '*/'
		
		PRINT '
IF OBJECT_ID(''tempdb..#cskid'') IS NOT NULL
	DROP table #cskid;
GO		
IF OBJECT_ID(''tempdb..#Keyword'') IS NOT NULL
	DROP table #Keyword;
GO
IF OBJECT_ID(''tempdb..#CSKeyword'') IS NOT NULL
	DROP table #CSKeyword;
GO
CREATE TABLE #cskid (CSKID INT, RowNumber INT,RecordCount INT)
	
CREATE TABLE #CSKeyword
(	Keyword [nvarchar](200) COLLATE Latin1_General_CI_AS_KS_WS NULL
	,CSKID INT 
	,AdCategoryName	NVARCHAR(200)
	,CampaignTitle NVARCHAR(100)
	,SearchEngine NVARCHAR(25)
	,KeywordStatusDesc VARCHAR(20)
	,InheritedStatusID TINYINT
	,KeywordMatchDesc VARCHAR(50)		
	,CurrentRank NUMERIC(18,2)	
	,FinalBid MONEY	
	,SearchBidConverted MONEY	
	,MainBidAmount MONEY
	,MinBid MONEY
	,BidMethod VARCHAR(100)	
	,BidMethodType VARCHAR(100)
	,BidMethodGroup VARCHAR(100)
	,DestinationURL NVARCHAR(2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL	
	,OrganicRank VARCHAR(5)	
	,SEID smallint
	,CampaignID INT
	,AdCategoryID INT
	,DailyBudgetConverted MONEY	
	,DetailStatusID INT
	,CurrencyCode VARCHAR(10)
	,EnableContentMatch BIT
	,EnableSearchMatch BIT
	,KeywordMatchTypeID TINYINT
	,ContentBidConverted MONEY	
	,KeywordStatusID INT
	,BidRuleID INT	
	,BidRuleTypeID INT
	,GlobalRule BIT
	,isSpot BIT
	,SpotID INT
	,KeywordSearchEngineDetailStatusID INT
	,GroupEnableContentMatch bit
	,GroupEnableSearchMatch bit
	,ParentSEID int
	,CampaignStatusID
)
' 

	PRINT @SQL_LoadCSKID
	SET @bigVarSize = len(@SQL_Keyword_Temp)

	IF @bigVarSize > 0
	BEGIN
		SET @offset = 0
		WHILE @offset <= @bigVarSize
		BEGIN
			PRINT SUBSTRING(@SQL_Keyword_Temp	, @offset, 4000)
			SET @offset = @offset + 4000
		END
	END
	ELSE
	BEGIN
		PRINT @SQL_Keyword_Temp	
	END
	
	
	PRINT '
CREATE INDEX idx_CSKeyword_CSKID  ON  #CSKeyword
	([CSKID] ASC)'
	PRINT @SQL_Keyword_Temp_Index

	SET @bigVarSize = len(@DynamicSQL)

	IF @bigVarSize > 0
	BEGIN
		SET @offset = 0
		WHILE @offset <= @bigVarSize
		BEGIN
			PRINT SUBSTRING(@DynamicSQL, @offset, 4000)
			SET @offset = @offset + 4000
		END
	END
	ELSE
	BEGIN
		PRINT @DynamicSQL
	END

	END
	ELSE
	BEGIN
		EXECUTE (@DynamicSQL);
	END
END




GO
GRANT EXECUTE ON [dbo].[SI_SP_CampaignManagement_Keyword_Read] TO [webaccess] AS [dbo]