USE [360iReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[ARE_Apple_Daily_Master]
(   @StartDate        DATETIME = NULL
) AS

 /*
Change History
Version		Date		Modified	Notes
1.01		01/07/09	MT			Creation

Test code:
ARE_Apple_Daily_Master
         @ClientID = 3233
         ,@StartDate = '08/18/2009'
*/

BEGIN
set nocount on
declare @EndDate as datetime

set @EndDate = dateadd(day,-15,@StartDate)

IF OBJECT_ID('tempdb..#TransactionTracking') IS NOT NULL 
		DROP TABLE #TransactionTracking
		
	
	SELECT * INTO   #TransactionTracking	
	FROM   ( (SELECT	easterncreatedate,
                    seid,
                    iscontentmatch,
                    CTID,
                    TransactionAmount,
                    TransactionAmountUSD,
                    OrigTransactionAmt,
                    customertransactiontypeid,
                    clientid, 
                    X1, X2, X3,
                    CampaignID,
                    AdCategoryID
				FROM      [SIProcessing].dbo.transactiontrackingall tt
                WHERE     tt.clientid=3233
					AND tt.easterncreatedate >= @EndDate
                    AND tt.easterncreatedate < DATEADD(week,1,@StartDate)
                    AND (X3 is NULL OR X3 in ('IN02','IN05','IN13','IN17',
                    'IN17','IN18','IN19','IN22','IN24','IN25','IN26','IN27'))
                    and tt.CampaignID not in (71146,71209,71185,71161,71208,71286,71344,
                    71318,71248,71343,71314,71425,71472,71474,71444,71449,71450)
                    and LatencyInSeconds<2592001)
                UNION ALL
                (SELECT	easterncreatedate,
                    seid,
                    iscontentmatch,
                    CTID,
                    TransactionAmount,
                    TransactionAmountUSD,
                    OrigTransactionAmt,
                    customertransactiontypeid,
                    clientid, 
                    X1, X2, X3,
                    CampaignID,
                    AdCategoryID
				FROM      [SIProcessing].dbo.transactiontrackingall tt
                WHERE     tt.clientid=3485
					AND tt.easterncreatedate >= @EndDate
                    AND tt.easterncreatedate < DATEADD(week,1,@StartDate)
                    --AND tt.X2='MXN'
                    AND (X3 is NULL OR X3 in ('IN02','IN05','IN13','IN17',
                    'IN17','IN18','IN19','IN22','IN24','IN25','IN26','IN27'))
                    and LatencyInSeconds<2592001)   
                UNION ALL
                (SELECT	easterncreatedate,
                    seid,
                    iscontentmatch,
                    CTID,
                    TransactionAmount,
                    TransactionAmountUSD,
                    OrigTransactionAmt,
                    customertransactiontypeid,
                    clientid, 
                    X1, X2, X3,
                    CampaignID,
                    AdCategoryID
				FROM      [SIProcessing].dbo.transactiontrackingall tt
                WHERE     tt.clientid=3610
					AND tt.easterncreatedate >= @EndDate
                    AND tt.easterncreatedate < DATEADD(week,1,@StartDate)
                    --AND tt.X2='BRL'
                    and tt.TransactionAmount<25000
                    AND (X3 is NULL OR X3 in ('IN02','IN05','IN13','IN17',
                    'IN17','IN18','IN19','IN22','IN24','IN25','IN26','IN27'))
                    and LatencyInSeconds<2592001)   
                UNION ALL
                (SELECT	easterncreatedate,
                    seid,
                    iscontentmatch,
                    CTID,
                    TransactionAmount,
                    TransactionAmountUSD,
                    OrigTransactionAmt,
                    customertransactiontypeid,
                    clientid, 
                    X1, X2, X3,
                    CampaignID,
                    AdCategoryID
				FROM      [SIProcessing].dbo.transactiontrackingall tt
                WHERE     tt.clientid=3486
					AND tt.easterncreatedate >= @EndDate
                    AND tt.easterncreatedate < DATEADD(week,1,@StartDate)
                    --AND tt.X2='CAD' 
                    AND (X3 is NULL OR X3 in ('IN02','IN05','IN13','IN17',
                    'IN17','IN18','IN19','IN22','IN24','IN25','IN26','IN27'))
                    and LatencyInSeconds<2592001)   ) d


--Paid Search Current Year
select d.ClientID, 'Search' as DateType, ca.DayOfWeek, d.generatedate, d.SearchEngine, d.CampaignTitle, 
            sum(d.impressions) as Impressions, sum(d.clicks) as Clicks, sum(d.cost) as Cost,
            Rank = CASE 
			when sum(d.impressions)=0 then 0
			else sum(d.impressions*d.rank)/sum(d.impressions)
			end ,
            CASE when sum(t2.OrderBooking) IS NULL then 0 else sum(t2.OrderBooking) end as OrderBooking, 
            CASE when sum(t2.OrderBookingRev) IS NULL then 0 else sum(t2.OrderBookingRev) end as OrderBookingRev,
            CASE when sum(t2.CommBooking) IS NULL then 0 else sum(t2.CommBooking) end as CommBooking, 
            CASE when sum(t2.CommBookingRev) IS NULL then 0 else sum(t2.CommBookingRev) end as CommBookingRev,
            CASE when sum(t2.NonCommBookingLat) IS NULL then 0 else sum(t2.NonCommBookingLat) end as NonCommBookingLat, 
            CASE when sum(t2.NonCommBookingLatRev) IS NULL then 0 else sum(t2.NonCommBookingLatRev) end as NonCommBookingLatRev,
            CASE when d.ClientID=3233 then sum(t2.CommBillingUS)
            when d.ClientID=3485 then sum(t2.CommBillingMX) 
            when d.ClientID=3610 then sum(t2.CommBillingBZ) 
            else sum(t2.CommBillingCA) end as CommBilling, 
            CASE when d.ClientID=3233 then sum(t2.CommBillingRevUS)
            when d.ClientID=3485 then sum(t2.CommBillingRevMX) 
            when d.ClientID=3610 then sum(t2.CommBillingRevBZ) 
            else sum(t2.CommBillingRevCA) end as CommBillingRev, 
            CASE when sum(t2.NonCommBillingLat) IS NULL then 0 else sum(t2.NonCommBillingLat) end as NonCommBillingLat, 
            CASE when sum(t2.NonCommBillingLatRev) IS NULL then 0 else sum(t2.NonCommBillingLatRev) end as NonCommBillingLatRev,
            CASE when sum(t2.NonCommBookingSKU) IS NULL then 0 else sum(t2.NonCommBookingSKU) end as NonCommBookingSKU, 
            CASE when sum(t2.NonCommBookingSKURev) IS NULL then 0 else sum(t2.NonCommBookingSKURev) end as NonCommBookingSKURev,
            CASE when sum(t2.NonCommBillingSKU) IS NULL then 0 else sum(t2.NonCommBillingSKU) end as NonCommBillingSKU, 
            CASE when sum(t2.NonCommBillingSKURev) IS NULL then 0 else sum(t2.NonCommBillingSKURev) end as NonCommBillingSKURev
from
(select rd.generatedate, SearchEngine = CASE
		WHEN se.SearchEngine LIKE '%Google%' THEN 'Google'
		WHEN se.SearchEngine LIKE '%Yahoo%' THEN 'Yahoo'
		WHEN se.SearchEngine LIKE '%MSN%' THEN 'MSN'
		ELSE se.SearchEngine
		END,
	  cm.CampaignID, cm.CampaignTitle, al.Portfolio,
      SUM(rd.NumImpressions) AS Impressions,
      SUM(rd.NumClicksReported) AS Clicks,
      SUM(rd.Cost) AS Cost,
      Rank = CASE 
		when sum(rd.TotalRankCount)=0 then 0
		else sum(rd.TotalRank)/sum(rd.TotalRankCount)
		end, 
	  rd.ClientID
from [360Analysis].dbo.viRPT_Performance_RawData_Summary rd
join [360Analysis].dbo.Campaign cm on cm.CampaignID=rd.CampaignID
join [360Analysis].dbo.searchengine se on se.seid=rd.seid
left outer join [360iReport].dbo.CampaignAlias_Apple al on rd.AdCategoryID=al.AdCategoryID
where rd.clientid in (3233,3485,3486,3610) and rd.generatedate>=@EndDate and rd.generatedate<dateadd(day,1,@StartDate)
group by rd.generatedate, se.searchengine, cm.CampaignID, cm.CampaignTitle, al.Portfolio, rd.ClientID
)
as d

left outer join
(select t.EasternCreateDate, t.ClientID, t.SearchEngine, t.CampaignID, t.CampaignTitle, t.Portfolio,
CASE when sum(t.OrderBooking) IS NULL then 0 else sum(t.OrderBooking) end as OrderBooking, 
            CASE when sum(t.OrderBookingRev) IS NULL then 0 else sum(t.OrderBookingRev) end as OrderBookingRev,
            CASE when sum(t.CommBooking) IS NULL then 0 else sum(t.CommBooking) end as CommBooking, 
            CASE when sum(t.CommBookingRev) IS NULL then 0 else sum(t.CommBookingRev) end as CommBookingRev,
            CASE when sum(t.NonCommBookingLat) IS NULL then 0 else sum(t.NonCommBookingLat) end as NonCommBookingLat, 
            CASE when sum(t.NonCommBookingLatRev) IS NULL then 0 else sum(t.NonCommBookingLatRev) end as NonCommBookingLatRev,
            sum(t.CommBillingUS) as CommBillingUS, sum(t.CommBillingRevUS) as CommBillingRevUS,
		sum(t.CommBillingMX) as CommBillingMX, sum(t.CommBillingRevMX) as CommBillingRevMX,
		sum(t.CommBillingCA) as CommBillingCA, sum(t.CommBillingRevCA) as CommBillingRevCA,
		sum(t.CommBillingBZ) as CommBillingBZ, sum(t.CommBillingRevBZ) as CommBillingRevBZ,
    CASE when sum(t.NonCommBillingLat) IS NULL then 0 else sum(t.NonCommBillingLat) end as NonCommBillingLat, 
            CASE when sum(t.NonCommBillingLatRev) IS NULL then 0 else sum(t.NonCommBillingLatRev) end as NonCommBillingLatRev,
            CASE when sum(t.NonCommBookingSKU) IS NULL then 0 else sum(t.NonCommBookingSKU) end as NonCommBookingSKU, 
            CASE when sum(t.NonCommBookingSKURev) IS NULL then 0 else sum(t.NonCommBookingSKURev) end as NonCommBookingSKURev,
            CASE when sum(t.NonCommBillingSKU) IS NULL then 0 else sum(t.NonCommBillingSKU) end as NonCommBillingSKU, 
            CASE when sum(t.NonCommBillingSKURev) IS NULL then 0 else sum(t.NonCommBillingSKURev) end as NonCommBillingSKURev
from
(SELECT DATEADD(DD,0,DATEDIFF(DD,0,tt.EasternCreateDate)) as EasternCreateDate, tt.ClientID, 
	SearchEngine = CASE
		WHEN se.SearchEngine LIKE '%Google%' and tt.IsContentMatch=0 THEN 'Google'
		WHEN se.SearchEngine LIKE '%Google%' and tt.IsContentMatch=1 THEN 'Google Content'
		WHEN se.SearchEngine LIKE '%Yahoo%' and tt.IsContentMatch=0 THEN 'Yahoo'
		WHEN se.SearchEngine LIKE '%Yahoo%' and tt.IsContentMatch=1 THEN 'Yahoo Content'
		WHEN se.SearchEngine LIKE '%MSN%' and tt.IsContentMatch=0 THEN 'MSN'
		WHEN se.SearchEngine LIKE '%MSN%' and tt.IsContentMatch=1 THEN 'MSN Content'
		ELSE se.SearchEngine
		END, 
		cm.CampaignID, cm.CampaignTitle, al.Portfolio,
		OrderBooking = CASE WHEN tt.CustomerTransactionTypeID = 13015 THEN COUNT(tt.ctid)
			ELSE 0
			END,
		OrderBookingRev = CASE WHEN tt.CustomerTransactionTypeID = 13015 and tt.ClientID in (3233,3485,3486) THEN SUM(tt.OrigTransactionAmt)
			WHEN tt.CustomerTransactionTypeID = 13015 and tt.ClientID=3470 THEN SUM(tt.TransactionAmount)
			WHEN tt.CustomerTransactionTypeID = 13015 and tt.ClientID=3610 THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		CommBooking = CASE WHEN tt.CustomerTransactionTypeID = 13016 THEN COUNT(distinct tt.X1)
			ELSE 0
			END,
		CommBookingRev = CASE WHEN tt.CustomerTransactionTypeID = 13016 and tt.ClientID in (3233,3485,3486) THEN SUM(tt.OrigTransactionAmt)
			WHEN tt.CustomerTransactionTypeID = 13016 and tt.ClientID=3470 THEN SUM(tt.TransactionAmount)
			WHEN tt.CustomerTransactionTypeID = 13016 and tt.ClientID=3610 THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		NonCommBookingLat = CASE WHEN tt.CustomerTransactionTypeID = 13017 THEN COUNT(tt.ctid)
			ELSE 0
			END,
		NonCommBookingLatRev = CASE WHEN tt.CustomerTransactionTypeID = 13017 and tt.ClientID in (3233,3485,3486) THEN SUM(tt.OrigTransactionAmt)
			WHEN tt.CustomerTransactionTypeID = 13017 and tt.ClientID=3470 THEN SUM(tt.TransactionAmount)
			WHEN tt.CustomerTransactionTypeID = 13017 and tt.ClientID=3610 THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		CommBillingUS = CASE WHEN tt.CustomerTransactionTypeID = 13018  AND tt.X2='USD' THEN COUNT(distinct tt.X1)
			ELSE 0
			END,
		CommBillingMX = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='MXN' THEN COUNT(distinct tt.X1)
			ELSE 0
			END,
		CommBillingCA = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='CAD' THEN COUNT(distinct tt.X1)
			ELSE 0
			END,
		CommBillingBZ = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='BRL' THEN COUNT(distinct tt.X1)
			ELSE 0
			END,
		CommBillingRevUS = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='USD' THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		CommBillingRevMX = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='MXN' THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		CommBillingRevCA = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='CAD' THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		CommBillingRevBZ = CASE WHEN tt.CustomerTransactionTypeID = 13018 AND tt.X2='BRL' THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		NonCommBillingLat = CASE WHEN tt.CustomerTransactionTypeID = 13019 THEN COUNT(tt.ctid)
			ELSE 0
			END,
		NonCommBillingLatRev = CASE WHEN tt.CustomerTransactionTypeID = 13019 and tt.ClientID in (3233,3485,3486) THEN SUM(tt.OrigTransactionAmt)
			WHEN tt.CustomerTransactionTypeID = 13019 and tt.ClientID=3470 THEN SUM(tt.TransactionAmount)
			WHEN tt.CustomerTransactionTypeID = 13019 and tt.ClientID=3610 THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		NonCommBookingSKU = CASE WHEN tt.CustomerTransactionTypeID = 14677 THEN COUNT(tt.ctid)
			ELSE 0
			END,
		NonCommBookingSKURev = CASE WHEN tt.CustomerTransactionTypeID = 14677 and tt.ClientID in (3233,3485,3486) THEN SUM(tt.OrigTransactionAmt)
			WHEN tt.CustomerTransactionTypeID = 14677 and tt.ClientID=3470 THEN SUM(tt.TransactionAmount)
			WHEN tt.CustomerTransactionTypeID = 14677 and tt.ClientID=3610 THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END,
		NonCommBillingSKU = CASE WHEN tt.CustomerTransactionTypeID = 14678 THEN COUNT(tt.ctid)
			ELSE 0
			END,
		NonCommBillingSKURev = CASE WHEN tt.CustomerTransactionTypeID = 14678 and tt.ClientID in (3233,3485,3486) THEN SUM(tt.OrigTransactionAmt)
			WHEN tt.CustomerTransactionTypeID = 14678 and tt.ClientID=3470 THEN SUM(tt.TransactionAmount)
			WHEN tt.CustomerTransactionTypeID = 14678 and tt.ClientID=3610 THEN SUM(tt.OrigTransactionAmt)
			ELSE 0
			END					
FROM    #TransactionTracking AS tt
join [360Analysis].dbo.Campaign cm on cm.CampaignID=tt.CampaignID 
join [360Analysis].dbo.searchengine se on se.seid=tt.seid
left outer join [360iReport].dbo.CampaignAlias_Apple al on tt.AdCategoryID=al.AdCategoryID
where tt.easterncreatedate>=@EndDate and tt.easterncreatedate<dateadd(day,1,@StartDate) and tt.clientid in (3233,3485,3486,3610)
group by  DATEADD(DD,0,DATEDIFF(DD,0,tt.EasternCreateDate)), tt.ClientID, cm.CampaignID, cm.CampaignTitle, tt.CustomerTransactionTypeID, tt.X2,
	CASE
		WHEN se.SearchEngine LIKE '%Google%' and tt.IsContentMatch=0 THEN 'Google'
		WHEN se.SearchEngine LIKE '%Google%' and tt.IsContentMatch=1 THEN 'Google Content'
		WHEN se.SearchEngine LIKE '%Yahoo%' and tt.IsContentMatch=0 THEN 'Yahoo'
		WHEN se.SearchEngine LIKE '%Yahoo%' and tt.IsContentMatch=1 THEN 'Yahoo Content'
		WHEN se.SearchEngine LIKE '%MSN%' and tt.IsContentMatch=0 THEN 'MSN'
		WHEN se.SearchEngine LIKE '%MSN%' and tt.IsContentMatch=1 THEN 'MSN Content'
		ELSE se.SearchEngine
		END, al.Portfolio) as t
group by t.EasternCreateDate, t.ClientID, t.SearchEngine, t.CampaignID, t.CampaignTitle, t.Portfolio) as t2
                  on 	d.generatedate=t2.easterncreatedate
						AND d.SearchEngine=t2.SearchEngine
						AND d.CampaignID=t2.CampaignID
						AND d.Portfolio=t2.Portfolio
						
JOIN [360iReport].dbo.JCPCalendar ca on d.generatedate=ca.CurrentYear
group by d.generatedate, ca.DayOfWeek, d.SearchEngine, d.CampaignTitle, d.ClientID

END
