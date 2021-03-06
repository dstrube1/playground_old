
 DECLARE @DisplayClickTrackingRaw TABLE
(
[DCID] [int] NOT NULL IDENTITY(1, 1),
[ImpressionID] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserUniqueGuid] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [int] NULL,
[AdvertiserID] [int] NULL,
[PublisherID] [int] NULL,
[AdCategoryID] [int] NULL,
[CreativeID] [bigint] NULL,
[URL] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralURL] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OSVersion] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrowserVersion] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPAddress] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WebServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDateUTC] [datetime] NOT NULL,
[GlobalTrackingTypeID] [int] NULL,
[GlobalTrackingID] [bigint] NULL,
[AttributeCollection] [xml] NULL
)

INSERT INTO @DisplayClickTrackingRaw
        ( ImpressionID ,
          UserUniqueGuid ,
          ClientID ,
          AdvertiserID ,
          PublisherID ,
          AdCategoryID ,
          CreativeID ,
          URL ,
          ReferralURL ,
          OSVersion ,
          BrowserVersion ,
          IPAddress ,
          WebServerName ,
          AccessServerName ,
          CreateDateUTC
 )
SELECT  DISTINCT ImpressionID ,
          UserUniqueGuid ,
          CAST(ClientID AS INT) AS CLientID,
          CAST(AdvertiserID AS INT) AS AdvertiserID,
          CAST(PublisherID AS INT) AS  PublisherID,
          CAST(CategoryID AS INT) AS AdCategoryID ,
          CAST(CreativeID AS BIGINT) AS CreativeID,
          URL ,
          ReferralURL ,
          OSVersion ,
          BrowserVersion ,
          IPAddress ,
          WebServerName ,
          'M-Test' AS AccessServerName,
          CreateDateUTC 
  FROM SIProcessing_Attribution..TrackedExposureDisplayClicks_SUSPECT tes
  WHERE ClientID = 5947
	AND CreateDateUTC  >= '02/20/2012'
	
       
       IF OBJECT_ID('tempdb..#ClientInfo') IS NOT NULL
		DROP TABLE #ClientInfo
       
        CREATE TABLE #ClientInfo
            (
              [DCID] [int] NOT NULL,
              [ImpressionID] [varchar](36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
              [UserUniqueGuid] [varchar](36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
              [ClientID] [int] NULL,
              [AdvertiserID] [int] NULL,
              [PublisherID] [int] NULL,
              [PublisherCurrencyID] [int] NULL,
              [CategoryID] [int] NULL,
              [CampaignID] [int] NULL,
              [CreativeID] [bigint] NULL,
              [AffiliateID] INT NULL,
              [WebServerName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
              [AccessServerName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
              [WebServerID] INT NULL,
              [AccessServerID] INT NULL,
              [CreateDateUTC] [datetime] NOT NULL,
              [EasternCreateDate] [datetime] NOT NULL,
              [RowNumber] INT NOT NULL,
			  [GlobalTrackingTypeID] INT NULL,
			  [GlobalTrackingID] BIGINT NULL,
			  [AttributeCollection] XML NULL,
              PRIMARY KEY ( RowNumber, DCID )
            ) ;  
          
 
                    INSERT  INTO #ClientInfo
                            (
                              DCID,
                              CreateDateUTC,
                              EasternCreateDate,
                              ImpressionID,
                              UserUniqueGuid,
                              ClientID,
                              AdvertiserID,
                              PublisherID,
                              PublisherCurrencyID,
                              CategoryID,
                              CampaignID,
                              CreativeID,
                              AffiliateID,
                              WebServerName,
                              AccessServerName,
                              WebServerID,
                              AccessServerID,
                              RowNumber,
							  GlobalTrackingTypeID,
							  GlobalTrackingID,
							  AttributeCollection
			          )
                            SELECT  dctr.DCID,
                                    dctr.CreateDateUTC,
                                    dbo.fn_ConvertTime(dctr.CreateDateUTC, 13, 0, 8, 1) AS EasternCreateDate,
                                    dctr.ImpressionID,
                                    dctr.UserUniqueGuid,
                                    dctr.ClientID,
                                    dctr.Advertiserid,
                                    dctr.PublisherID,
                                    cur.CurrencyID,
                                    dctr.AdCategoryID,
                                    nana.campaign_id AS CampaignID,
                                    dctr.CreativeID,
                                    ( SELECT    MIN(AffiliateID)
                                      FROM      AffiliateGroupClients
                                      WHERE     StatusFlag = 1
                                                AND ClientID = dctr.ClientID
                                    ) AS AffiliateID,
                                    dctr.WebServerName,
                                    dctr.AccessServerName,
                                    lu1.LUServerID,
                                    lu2.LUServerID,
                                    ROW_NUMBER() OVER ( PARTITION BY dctr.CreateDateUTC,
                                                        dctr.UserUniqueGuid,
                                                        dctr.ClientID ORDER BY dctr.CreateDateUTC ),
									dctr.GlobalTrackingTypeID,
									dctr.GlobalTrackingID,
									dctr.AttributeCollection
                            FROM    @DisplayClickTrackingRaw AS dctr
                                    LEFT JOIN NETMINING..campaign_creatives_NAN nana ON nana.creative_id = dctr.CreativeID
                                    LEFT JOIN NETMINING..publishers_NAN nanp ON nanp.publisher_id = dctr.PublisherID
                                    LEFT JOIN LUServer AS lu1 ON dctr.WebServerName = lu1.LUServerName
                                    LEFT JOIN LUServer AS lu2 ON dctr.AccessServerName = lu2.LUServerName
                                    LEFT JOIN LUCurrency AS cur ON cur.NMCurrencyID = nanp.currency
                            WHERE   dctr.CreateDateUTC IS NOT NULL
                                    AND dctr.[UserUniqueGuid] IS NOT NULL  
                                    
                                    
                                SELECT  DISTINCT CreativeID, ','  FROM #ClientInfo    
 SELECT * FROM NETMINING..campaign_creatives_NAN 
 WHERE creative_id IN (15657,15658,15659,15660,15661,15662,15663,15664,15665,15666,15667,15668,15669)
                                     
                    DELETE ci
                    FROM    #ClientInfo ci
                    JOIN SIProcessing_Attribution.dbo.TrackedExposureDisplayClicks tedc ON tedc.UserUniqueGUID = ci.UserUniqueGUID
                                            AND tedc.ClientID = ci.ClientID
                                            AND tedc.CreateDateUTC = ci.CreateDateUTC  

                     
                    UPDATE  ci
                    SET     RowNumber = 0 -- 0 IS A SUSPECT RECORD 
					FROM	#ClientInfo ci     	
					LEFT JOIN NETMINING..advertisers_nan a ON a.advertiser_id = ci.Advertiserid
					LEFT JOIN NETMINING..publishers_NAN p ON p.publisher_id = ci.PublisherID
					LEFT JOIN NETMINING..campaigns_nan c ON c.campaign_id = ci.CampaignID
						AND c.advertiser_id = ci.AdvertiserID
					LEFT JOIN NETMINING..categories_nan cat ON cat.category_id = ci.CategoryID	
						AND cat.advertiser_id = ci.AdvertiserID
					LEFT JOIN NETMINING..campaign_creatives_NAN cr ON cr.creative_id = ci.CreativeID
						AND cr.campaign_id = ci.CampaignID			   
                    WHERE   p.publisher_id IS NULL
                            OR PublisherCurrencyID IS NULL
                            OR CreateDateUTC IS NULL
                            OR ClientID IS NULL
                           -- OR a.advertiser_id IS NULL
                            --OR cat.category_id IS NULL
                           -- OR c.campaign_id IS NULL
                            OR cr.creative_id IS NULL 
                            OR RowNumber <> 1;   
                           
   
                            SELECT  COALESCE(c.ImpressionID,v.ImpressionID), 
									COALESCE(c.UserUniqueGUID,v.UserUniqueGUID),
                                    COALESCE(c.ClientID,v.ClientID),
                                    c.AffiliateID,
                                    COALESCE(c.AdvertiserID,v.AdvertiserID),
                                    COALESCE(c.PublisherID,v.PublisherID),
                                    c.PublisherCurrencyID,
                                    COALESCE(c.CategoryID,v.ADCategoryID),
                                    c.CampaignID,
                                    COALESCE(c.CreativeID,v.CreativeID),
                                    v.URL,
                                    v.ReferralURL,
                                    v.IPAddress,
                                    v.OSVersion,
                                    v.BrowserVersion,
                                    c.CreateDateUTC,
                                    c.EasternCreateDate,
                                    1,--TrackingSourceID
                                    GETUTCDATE(),
                                    c.WebServerID,
                                    v.WebServerName,
                                    c.AccessServerID,
                                    v.AccessServerName,
                                    ERROR_NUMBER(),
                                    ERROR_MESSAGE(),
                                    CASE WHEN c.AdvertiserID IS NULL
                                         THEN '- No AdvertiserID -'
                                         ELSE ''
                                    END
                                    + CASE WHEN c.PublisherID IS NULL
                                           THEN '- No PublisherID -'
                                           ELSE ''
                                      END
                                    + CASE WHEN c.PublisherCurrencyID IS NULL
                                           THEN '- No CurrencyID -'
                                           ELSE ''
                                      END
                                    + CASE WHEN c.ClientID IS NULL
                                           THEN '- No ClientID -'
                                           ELSE ''
                                      END
                                    + CASE WHEN c.CategoryID IS NULL
                                           THEN '- No Category -'
                                           ELSE ''
                                      END
                                    + CASE WHEN c.CampaignID IS NULL
                                           THEN '- No Campaign -'
                                           ELSE ''
                                      END
                                    + CASE WHEN c.CreativeID IS NULL
                                           THEN '- No Creative -'
                                           ELSE ''
                                      END
                            FROM   @DisplayClickTrackingRaw  AS v
                                    LEFT JOIN #ClientInfo AS c ON c.DCID = v.DCID
                                                                         AND c.CreateDateUTC = v.CreateDateUTC
                                                                         AND c.EasternCreateDate IS NOT NULL
                            WHERE   c.RowNumber = 0 OR v.UserUniqueGuid IS NULL;    

  
  
                            SELECT  1 AS ExposureTypeID,
                                    6 AS ChannelID,
                                    c.CreateDateUTC,
                                    1 AS TrackingSourceID,
                                    c.AffiliateID,
                                    c.ClientID,
                                    c.PublisherCurrencyID,
                                    c.UserUniqueGuid,
                                    c.DCID,
									c.GlobalTrackingTypeID,
									c.GlobalTrackingID									                                    
                            FROM    #ClientInfo AS c
                            WHERE   c.RowNumber = 1  
