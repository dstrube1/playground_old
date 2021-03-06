
DECLARE @BeginDateLocalized DATETIME = '2013-06-16' ,
    @EndDateLocalized DATETIME = '2013-06-17' ,
    @AffiliateID INT = 334 ,
    --@ProcessSecondary BIT = 1 ,
    @debug BIT = 0   
   
   /*
   
        EXEC SI_SP_Transaction_TE4_FromExposureSEQ_New @BeginDatelocalized = '2013-06-17',
            @EndDatelocalized = '2013-06-18', @AffiliateID = 33
     */ 
       
DECLARE @SQLString AS VARCHAR(200) ,
    @RecordCount INT ,
    @retry INT ,
    @err INT ,
    @msg VARCHAR(2000) ,
    @TotalCount INT ,
    @TrackedQueueHeaderID INT ,
    @BeginExposureSequenceID BIGINT ,
    @EndExposureSequenceID BIGINT ,
    @MaxExposureSequenceID BIGINT ,
    @SequenceRange INT = 5000000 ,
    @minEasternCreateDate DATETIME ,
    @minEasternCreateDate2 DATETIME   
	   
DECLARE @Clients TABLE ( ClientID INT )        
     
SET @TotalCount = 0   

IF OBJECT_ID('tempdb..#TrackedCache') IS NOT NULL
DROP TABLE #TrackedCache 
         
CREATE TABLE #TrackedCache
    (
      [EasternCreateDate] [datetime] NOT NULL ,
      [CSKID] [int] NULL ,
      [TransactionAmount] [float] NULL ,
      [CreatedDate] [datetime] NOT NULL ,
      [TransactionTypeID] [int] NULL ,
      [MoreInfo] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS
                                 NULL ,
      [N1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N4] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N5] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N6] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N7] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N8] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N9] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N10] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                            NULL ,
      [X1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X4] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X5] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X6] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X7] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X8] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X9] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X10] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                            NULL ,
      [CustomerTransactionTypeID] [int] NULL ,
      [isContentMatch] [bit] NULL ,
      [ClickTime] [datetime] NULL ,
      [LatencyInSeconds] [int] NULL ,
      [UserUniqueGUID] [varchar](36) COLLATE SQL_Latin1_General_CP1_CI_AS
                                     NOT NULL ,
      [ClientID] [int] NOT NULL ,
      [ReferenceID] [int] NULL ,
      [SEID] [int] NULL ,
      [NSEID] [int] NULL ,
      [PublisherID] [int] NULL ,
      [CkeywordID] [int] NULL ,
      [AdCategoryID] [int] NULL ,
      [CampaignID] [int] NULL ,
      [OrigClientID] [int] NOT NULL ,
      [ExtraInfo1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                   NULL ,
      [OrigTransactionAmt] [money] NULL ,
      [CurrencyID] [int] NULL ,
      [OrigCurrencyID] [int] NULL ,
      [WebServerID] [int] NULL ,
      [AccessServerID] [int] NULL ,
      [TrackedActionID] [bigint] NOT NULL ,
      [TrackedExposureID] [bigint] NOT NULL ,
      [ChannelID] [int] NULL ,
      [ActionWeightPct] [numeric](3, 2) NOT NULL ,
      [ActionWeightFactor] [float] NULL ,
      [AttributedExposures] [int] NULL ,
      [ExposureSequence] [bigint] NULL ,
      [ActionQuantity] [float] NULL ,
      [KeywordID] [int] NULL ,
      [Keyword] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS
                                NULL ,
      [ExposureTypeID] [int] NULL ,
      [PaidInclusion] [int] NOT NULL ,
      [USDExchangeRate] [money] NULL ,
      [AffiliateID] INT ,
      [BinaryCheckSum] [INT] NOT NULL ,
      [ExposureSequenceID] BIGINT ,
      [GlobalTrackingTypeID] INT ,
      [GlobalTrackingID] BIGINT ,
      [DeviceTypeID] TINYINT ,
      [DeviceModelID] INT ,
      [AdjustedActionQuantity] [Float] ,
      [ExposureBrowserVersion] VARCHAR(20) NULL
    )               
	        
	        
IF OBJECT_ID('tempdb..#TrackedCache2') IS NOT NULL
DROP TABLE #TrackedCache2 
         
	             
CREATE TABLE #TrackedCache2
    (
      [EasternCreateDate] [datetime] NOT NULL ,
      [CSKID] [int] NULL ,
      [TransactionAmount] [float] NULL ,
      [CreatedDate] [datetime] NOT NULL ,
      [TransactionTypeID] [int] NULL ,
      [MoreInfo] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS
                                 NULL ,
      [N1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N4] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N5] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N6] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N7] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N8] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N9] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [N10] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                            NULL ,
      [X1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X4] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X5] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X6] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X7] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X8] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X9] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                           NULL ,
      [X10] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                            NULL ,
      [CustomerTransactionTypeID] [int] NULL ,
      [isContentMatch] [bit] NULL ,
      [ClickTime] [datetime] NULL ,
      [LatencyInSeconds] [int] NULL ,
      [UserUniqueGUID] [varchar](36) COLLATE SQL_Latin1_General_CP1_CI_AS
                                     NOT NULL ,
      [ClientID] [int] NOT NULL ,
      [ReferenceID] [int] NULL ,
      [SEID] [int] NULL ,
      [NSEID] [int] NULL ,
      [PublisherID] [int] NULL ,
      [CkeywordID] [int] NULL ,
      [AdCategoryID] [int] NULL ,
      [CampaignID] [int] NULL ,
      [OrigClientID] [int] NOT NULL ,
      [ExtraInfo1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                   NULL ,
      [OrigTransactionAmt] [money] NULL ,
      [CurrencyID] [int] NULL ,
      [OrigCurrencyID] [int] NULL ,
      [WebServerID] [int] NULL ,
      [AccessServerID] [int] NULL ,
      [TrackedActionID] [bigint] NOT NULL ,
      [TrackedExposureID] [bigint] NOT NULL ,
      [ChannelID] [int] NULL ,
      [ActionWeightPct] [numeric](3, 2) NOT NULL ,
      [ActionWeightFactor] [float] NULL ,
      [AttributedExposures] [int] NULL ,
      [ExposureSequence] [bigint] NULL ,
      [ActionQuantity] [float] NULL ,
      [KeywordID] [int] NULL ,
      [Keyword] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS
                                NULL ,
      [ExposureTypeID] [int] NULL ,
      [PaidInclusion] [int] NOT NULL ,
      [USDExchangeRate] [money] NULL ,
      [AffiliateID] INT ,
      [BinaryCheckSum] [INT] NOT NULL ,
      [ExposureSequenceID] BIGINT ,
      [GlobalTrackingTypeID] INT ,
      [GlobalTrackingID] BIGINT ,
      [DeviceTypeID] TINYINT ,
      [DeviceModelID] INT ,
      [ActionQuanityAdjusted] [Float] ,
      [ExposureBrowserVersion] VARCHAR(20) NULL
    )                  
	  
	  
IF OBJECT_ID('tempdb..#LatentActions') IS NOT NULL
DROP TABLE #LatentActions 
         
	  
CREATE TABLE #LatentActions
    (
      ClientID INT ,
      SEID INT ,
      GlobalTrackingTypeID INT ,
      BeginDate DATE ,
      EndDate DATE
    )                     
  
  
IF OBJECT_ID('tempdb..#ThirdPartyLatentActions') IS NOT NULL
DROP TABLE #ThirdPartyLatentActions 
  
CREATE TABLE #ThirdPartyLatentActions
    (
      ClientID INT ,
      SEID INT ,
      BeginDate DATE ,
      EndDate DATE
    )   
        
INSERT  INTO #TrackedCache
        ( EasternCreateDate ,
          CSKID ,
          TransactionAmount ,
          CreatedDate ,
          TransactionTypeID ,
          MoreInfo ,
          [N1] ,
          [N2] ,
          [N3] ,
          [N4] ,
          [N5] ,
          [N6] ,
          [N7] ,
          [N8] ,
          [N9] ,
          [N10] ,
          [X1] ,
          [X2] ,
          [X3] ,
          [X4] ,
          [X5] ,
          [X6] ,
          [X7] ,
          [X8] ,
          [X9] ,
          [X10] ,
          CustomerTransactionTypeID ,
          iscontentmatch ,
          ClickTime ,
          LatencyInSeconds ,
          UserUniqueGUID ,
          ClientID ,
          ReferenceID ,
          SEID ,
          NSEID ,
          PublisherID ,
          CkeywordID ,
          AdCategoryID ,
          CampaignID ,
          OrigClientID ,
          ExtraInfo1 ,
          OrigTransactionAmt ,
          CurrencyID ,
          OrigCurrencyID ,
          WebServerID ,
          AccessServerID ,
          TrackedActionID ,
          TrackedExposureID ,
          ChannelID ,
          ActionWeightPct ,
          ActionWeightFactor ,
          AttributedExposures ,
          ExposureSequence ,
          ActionQuantity ,
          KeywordID ,
          Keyword ,
          ExposureTypeID ,
          PaidInclusion ,
          USDExchangeRate ,
          AffiliateID ,
          BinaryCheckSum ,
          ExposureSequenceID ,
          GlobalTrackingTypeID ,
          GlobalTrackingID ,
          DeviceTypeID ,
          DeviceModelID ,
          ExposureBrowserVersion				       
		)
        EXEC SI_SP_Transaction_TE4_FromExposureSEQ_New @BeginDatelocalized = @BeginDatelocalized,
            @EndDatelocalized = @EndDatelocalized, @AffiliateID = @AffiliateID        
         
	    
      
SELECT  @RecordCount = COUNT(1) ,
        @MaxExposureSequenceID = MAX(ExposureSequenceID) ,
        @minEasternCreateDate = DATEADD(dd, -2, MIN(EasternCreateDate))
FROM    #TrackedCache       
     
     
CREATE NONCLUSTERED INDEX [idx_TempTrackedCache_TrackedActionID]  ON #TrackedCache( [TrackedActionID] ASC)            
      
         
INSERT  INTO #LatentActions
        ( ClientID ,
          SEID ,
          GlobalTrackingTypeID ,
          BeginDate ,
          EndDate        
	    )
        SELECT  ClientID ,
                SEID ,
                GlobalTrackingTypeID ,
                CAST(MIN(EasternCreateDate) AS DATE) AS BeginDate ,
                CAST(MAX(EasternCreateDate) AS DATE) AS EndDate
        FROM    #TrackedCache
        WHERE   EasternCreateDate <= DATEADD(dd, -1, GETDATE())
                AND EasternCreateDate >= DATEADD(dd, -30, GETDATE())
                AND ChannelID != 4
        GROUP BY ClientID ,
                SEID ,
                GlobalTrackingTypeID
  
INSERT  INTO #ThirdPartyLatentActions
        ( ClientID ,
          SEID ,
          BeginDate ,
          EndDate        
	    )
        SELECT  ClientID ,
                SEID ,
                CAST(MIN(EasternCreateDate) AS DATE) AS BeginDate ,
                CAST(MAX(EasternCreateDate) AS DATE) AS EndDate
        FROM    #TrackedCache
        WHERE   EasternCreateDate <= DATEADD(dd, -1, GETDATE())
                AND EasternCreateDate >= DATEADD(dd, -30, GETDATE())
                AND ChannelID = 4
        GROUP BY ClientID ,
                SEID          
             
             
IF @debug = 1 
    BEGIN
    
        SELECT CAST(EasternCreateDate AS DATE),  
        SUM(TransactionAmount) AS TransactionAmount_PreConv,
        SUM( CASE WHEN ChannelID = 4 THEN TransactionAmount ELSE 0 END) AS TransactionAmount_PreConv_4,
        SUM(CASE WHEN AdjustedActionQuantity IS NOT NULL
                             THEN TransactionAmount / ActionQuantity
                                  * AdjustedActionQuantity
                             ELSE [TransactionAmount]
                        END )AS [TransactionAmount],
        COUNT( DISTINCT TrackedActionID) AS NumActions,
        COUNT( DISTINCT CASE WHEN ChannelID = 4 THEN TrackedActionID ELSE NULL END) AS NumActions_4
        FROM    #TrackedCache
        WHERE ClientID = 3829
        GROUP BY CAST(EasternCreateDate AS DATE)
    
    END
    
ELSE 
    BEGIN         
             
             
             
        DELETE  TrackedCache
        FROM    #TrackedCache
        WHERE   TrackedCache.TrackedActionID = #TrackedCache.TrackedActionID
                AND TrackedCache.EasternCreateDate > @minEasternCreateDate        
				       
          
       
       
        WITH    Adjust
                  AS ( SELECT   TrackedActionID ,
                                ActionQuantity
                       FROM     #TrackedCache
                       WHERE    EXISTS ( SELECT 1
                                         FROM   dbo.ClientAttributionProfileSetting caps
                                         WHERE  caps.ClientID = #TrackedCache.OrigClientID
                                                AND #TrackedCache.CreatedDate >= caps.EffectiveBeginDateUTC
                                                AND #TrackedCache.CreatedDate < ISNULL(caps.EffectiveEndDateUTC,
                                                              '9999-12-31')
                                                AND caps.WeightedActionToggle = 1
                                                AND caps.ProfileSequence = 1 )
                     ),
                AdjustSum
                  AS ( SELECT   TrackedActionID ,
                                SUM(ActionQuantity) AS ActionQuantitySum
                       FROM     Adjust
                       GROUP BY TrackedActionID
                     )
            UPDATE  #TrackedCache
            SET     #TrackedCache.AdjustedActionQuantity = ActionQuantity
                    / AdjustSum.ActionQuantitySum
            FROM    AdjustSum
            WHERE   #TrackedCache.TrackedActionID = AdjustSum.TrackedActionID  
				 
				        
				        
        SELECT CAST(EasternCreateDate AS DATE),  
        SUM(TransactionAmount) AS TransactionAmount_PreConv,
        SUM( CASE WHEN ChannelID = 4 THEN TransactionAmount ELSE 0 END) AS TransactionAmount_PreConv_4,
        SUM(CASE WHEN AdjustedActionQuantity IS NOT NULL
                             THEN TransactionAmount / ActionQuantity
                                  * AdjustedActionQuantity
                             ELSE [TransactionAmount]
                        END )AS [TransactionAmount],
        COUNT( DISTINCT TrackedActionID) AS NumActions,
        COUNT( DISTINCT CASE WHEN ChannelID = 4 THEN TrackedActionID ELSE NULL END) AS NumActions_4
        FROM    #TrackedCache
        WHERE ClientID = 3829
        GROUP BY CAST(EasternCreateDate AS DATE)
    
				        
        INSERT  TrackedCache
                ( [EasternCreateDate] ,
                  [TID] ,
                  [NTID] ,
                  [CSKID] ,
                  [TransactionAmount] ,
                  [CreatedDate] ,
                  [TransactionTypeID] ,
                  [MoreInfo] ,
                  [N1] ,
                  [N2] ,
                  [N3] ,
                  [N4] ,
                  [N5] ,
                  [N6] ,
                  [N7] ,
                  [N8] ,
                  [N9] ,
                  [N10] ,
                  [X1] ,
                  [X2] ,
                  [X3] ,
                  [X4] ,
                  [X5] ,
                  [X6] ,
                  [X7] ,
                  [X8] ,
                  [X9] ,
                  [X10] ,
                  [CustomerTransactionTypeID] ,
                  [loginfo] ,
                  [ISContentMatch] ,
                  [ClickTime] ,
                  [LatencyInSeconds] ,
                  [UserUniqueGuid] ,
                  [ClientID] ,
                  [KeywordID] ,
                  [ReferenceID] ,
                  [SEID] ,
                  [NSEID] ,
                  [PublisherID] ,
                  [CKeywordID] ,
                  [AdCategoryID] ,
                  [CampaignID] ,
                  [OrigClientID] ,
                  [ExtraInfo1] ,
                  [OrigTransactionAmt] ,
                  [CurrencyID] ,
                  [OrigCurrencyID] ,
                  [WebServerID] ,
                  [AccessServerID] ,
                  [TrackedActionID] ,
                  [TrackedExposureID] ,
                  [ChannelID] ,
                  [ActionWeightPct] ,
                  [ActionWeightFactor] ,
                  [AttributedExposures] ,
                  [ExposureSequence] ,
                  [ActionQuantity] ,
                  [Keyword] ,
                  [ExposureTypeID] ,
                  [PaidInclusion] ,
                  [USDExchangeRate] ,
                  [AffiliateID] ,
                  [BinaryCheckSum] ,
                  [ExposureSequenceID] ,
                  [GlobalTrackingTypeID] ,
                  [GlobalTrackingID] ,
                  [DeviceTypeID] ,
                  [DeviceModelID] ,
                  [ExposureBrowserVersion]  
				
                )
                SELECT  tt.[EasternCreateDate] ,
                        tt.TrackedActionID AS TID ,
                        tt.TrackedActionID AS NTID ,
                        tt.[CSKID] ,
                       CAST( CASE WHEN tt.AdjustedActionQuantity IS NOT NULL
                             THEN TransactionAmount / ActionQuantity
                                  * AdjustedActionQuantity
                             ELSE [TransactionAmount]
                        END AS MONEY)AS [TransactionAmount] ,
                        tt.[CreatedDate] ,
                        tt.[TransactionTypeID] ,
                        tt.[MoreInfo] ,
                        tt.[N1] ,
                        tt.[N2] ,
                        tt.[N3] ,
                        tt.[N4] ,
                        tt.[N5] ,
                        tt.[N6] ,
                        tt.[N7] ,
                        tt.[N8] ,
                        tt.[N9] ,
                        tt.[N10] ,
                        tt.[X1] ,
                        tt.[X2] ,
                        tt.[X3] ,
                        tt.[X4] ,
                        tt.[X5] ,
                        tt.[X6] ,
                        tt.[X7] ,
                        tt.[X8] ,
                        tt.[X9] ,
                        tt.[X10] ,
                        tt.[CustomerTransactionTypeID] ,
                        NULL AS loginfo ,
                        tt.[ISContentMatch] ,
                        tt.[ClickTime] ,
                        tt.[LatencyInSeconds] ,
                        tt.[UserUniqueGuid] ,
                        tt.[ClientID] ,
                        tt.[KeywordID] ,
                        tt.[ReferenceID] ,
                        tt.[SEID] ,
                        tt.[NSEID] ,
                        tt.[PublisherID] ,
                        tt.[CKeywordID] ,
                        tt.[AdCategoryID] ,
                        tt.[CampaignID] ,
                        tt.[OrigClientID] ,
                        tt.[ExtraInfo1] ,
                        tt.[OrigTransactionAmt] ,
                        tt.[CurrencyID] ,
                        tt.[OrigCurrencyID] ,
                        tt.[WebServerID] ,
                        tt.[AccessServerID] ,
                        tt.[TrackedActionID] ,
                        tt.[TrackedExposureID] ,
                        tt.[ChannelID] ,
                        tt.[ActionWeightPct] ,
                        tt.[ActionWeightFactor] ,
                        tt.[AttributedExposures] ,
                        tt.[ExposureSequence] ,
                        ISNULL(tt.AdjustedActionQuantity, tt.ActionQuantity) ,
                        tt.[Keyword] ,
                        tt.[ExposureTypeID] ,
                        tt.[PaidInclusion] ,
                        tt.[USDExchangeRate] ,
                        tt.[AffiliateID] ,
                        tt.[BinaryCheckSum] ,
                        tt.[ExposureSequenceID] ,
                        tt.[GlobalTrackingTypeID] ,
                        tt.[GlobalTrackingID] ,
                        tt.[DeviceTypeID] ,
                        tt.[DeviceModelID] ,
                        tt.[ExposureBrowserVersion]
                FROM    #TrackedCache tt        
                

END