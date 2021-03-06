   
    IF OBJECT_ID('tempdb..#DisplayClickRollup') IS NOT NULL 
        DROP TABLE #DisplayClickRollup
    IF OBJECT_ID('tempdb..#CostCountRollup') IS NOT NULL 
        DROP TABLE #CostCountRollup
    IF OBJECT_ID('tempdb..#NMImpCostRollup') IS NOT NULL 
        DROP TABLE  #NMImpCostRollup
    IF OBJECT_ID('tempdb..#RPT_DSP_Summary_Creative') IS NOT NULL 
        DROP TABLE #RPT_DSP_Summary_Creative
    
    
    CREATE TABLE #RPT_DSP_Summary_Creative
        (
          [ClientID] [int] NOT NULL ,
          [GenerateDate] [date] NOT NULL ,
          [creative_id] [bigint] NOT NULL ,
          [campaign_id] [int] NOT NULL ,
          [publisher_id] [int] NOT NULL ,
          [NumImpressions] [bigint] NOT NULL ,
          [Cost] [money] NOT NULL ,
          [NumClicksTracked] [bigint] NOT NULL ,
          [ViewBaseTransactionCount] [numeric](18, 2) NOT NULL ,
          [ViewBaseTransactionAmount] [money] NOT NULL ,
          [ClickBaseTransactionCount] [numeric](18, 2) NOT NULL ,
          [ClickBaseTransactionAmount] [money] NOT NULL ,
          [TransactionCountWithWeight] [numeric](18, 2) NULL ,
          [PublisherCost] [money]
            NOT NULL
            CONSTRAINT [DF_RPT_DSP_Summary_Creative_PublisherCost]
            DEFAULT ( (0) ) ,
          [CurrencyID] [int] NOT NULL ,
          [ThirdPartyDataCost] [money] NULL ,
          [ActualThirdPartyDataCost] [money] NULL
        ) 
    
    
    CREATE TABLE #DisplayClickRollup
        (
          GenerateDate DATE ,
          ClientID INT ,
          Creative_ID INT ,
          Campaign_ID INT ,
          Publisher_ID INT ,
          PublisherCurrencyID INT ,
          NumClicks BIGINT
        )


					
    CREATE TABLE #CostCountRollup
        (
          GenerateDate DATE ,
          ViewBaseTransactionCount NUMERIC(18, 2) ,
          ViewBaseTransactionAmount MONEY ,
          ClickBaseTransactionCount NUMERIC(18, 2) ,
          ClickBaseTransactionAmount MONEY ,
          ClientID INT ,
          Creative_ID INT ,
          Campaign_ID INT ,
          TransactionCountWithWeight NUMERIC(18, 2) ,
          PublisherCurrencyID INT ,
          Publisher_ID INT
        )
                        
                        
    CREATE TABLE #NMImpCostRollup
        (
          ClientID INT ,
          GenerateDate DATE ,
          Creative_ID INT ,
          Campaign_ID INT ,
          Publisher_ID INT ,
          NumImpressions BIGINT ,
          PublisherCost MONEY ,
          Cost MONEY ,
          ActualThirdPartyDataCost MONEY ,
          ThirdPartyDataCost MONEY ,
          CurrencyID INT
        )
                
                
    INSERT  INTO #DisplayClickRollup   ---  count of clicks.  not impressions
            SELECT  CAST(LocalizedCreateDate AS DATE) AS GenerateDate ,
                    TED.ClientID ,
                    CreativeID AS Creative_ID ,
                    CampaignID AS Campaign_ID ,
                    PublisherID AS Publisher_ID ,
                    PublisherCurrencyID ,
                    COUNT(1) AS NumClicks
            FROM    SIProcessing_Attribution.dbo.TrackedExposureDisplayClicks TED
                    INNER JOIN RPT_DSP_GenerateList l ON ( l.clientid = TED.clientID
                                                           AND TED.localizedCreateDate >= l.GenerateBeginDate
                                                           AND TED.localizedCreateDate <= l.GenerateEndDate
                                                         )
            GROUP BY CAST(LocalizedCreateDate AS DATE) ,
                    TED.ClientID ,
                    CreativeID ,
                    CampaignID ,
                    PublisherID ,
                    PublisherCurrencyID
						
						

    INSERT  INTO #CostCountRollup   --- transaction amounts
            SELECT  GenerateDate ,
                    ISNULL(SUM(ViewBaseTransactionCount), 0) AS ViewBaseTransactionCount ,
                    ISNULL(SUM(ViewBaseTransactionAmount), 0) AS ViewBaseTransactionAmount ,
                    ISNULL(SUM(ClickBaseTransactionCount), 0) AS ClickBaseTransactionCount ,
                    ISNULL(SUM(ClickBaseTransactionAmount), 0) AS ClickBaseTransactionAmount ,
                    ClientID ,
                    Creative_ID ,
                    Campaign_ID ,
                    ISNULL(SUM(( ViewBaseTransactionCount
                                 + ClickBaseTransactionCount ) * ISNULL(Weight,
                                                              1)), 0) AS TransactionCountWithWeight ,
                    CurrencyID AS PublisherCurrencyID ,
                    Publisher_ID
            FROM    dbo.RPT_DSP_Summary_CustomerTT_Creative
            GROUP BY GenerateDate ,
                    ClientID ,
                    Creative_ID ,
                    Campaign_ID ,
                    CurrencyID ,
                    Publisher_ID 
                        
                
                -- Records with Engine Data
    INSERT  INTO #NMImpCostRollup
            ( ClientID ,
              GenerateDate ,
              Creative_ID ,
              Campaign_ID ,
              Publisher_ID ,
              NumImpressions ,
              PublisherCost ,
              ThirdPartyDataCost ,
              ActualThirdpartyDataCost ,
              Cost ,
              CurrencyID 
                        
            )
            SELECT  NMCC.ClientID ,
                    NMCC.ReportDate AS GenerateDate ,
                    NMCC.NMCreativeID AS Creative_ID ,
                    NMCC.NMCampaignID AS Campaign_ID ,
                    NMCC.NMPublisherID AS Publisher_ID ,
                    SUM(NMCC.NumImpressions) NumImpressions ,
                    SUM(NMCC.PublisherCost) AS PublisherCost ,
                    SUM(NMCC.ThirdPartyDataCost) AS ThirdPartyCost ,
                    SUM(NMCC.ActualThirdPartyDataCost) AS ActualThirdPartyCost ,
                    SUM(NMCC.Cost) AS Cost ,
                    NMCC.PublisherCurrencyID AS CurrencyID
            FROM    SIProcessing.dbo.NMImpressionClicksCost NMCC --num impressions
                    INNER JOIN RPT_DSP_GenerateList l ON ( l.clientid = NMCC.clientID
                                                           AND NMCC.ReportDate >= l.GenerateBeginDate
                                                           AND NMCC.ReportDate <= l.GenerateEndDate
                                                         )
            GROUP BY NMCC.ClientID ,
                    NMCC.ReportDate ,
                    NMCC.NMCreativeID ,
                    NMCC.NMCampaignID ,
                    NMCC.NMPublisherID ,
                    NMCC.PublisherCurrencyID
                                      
                                			
    INSERT  INTO #RPT_DSP_Summary_Creative
            ( ClientID ,
              GenerateDate ,
              Creative_ID ,
              Campaign_ID ,
              Publisher_ID ,
              NumImpressions ,
              Cost ,
              NumClicksTracked ,
              ViewBaseTransactionCount ,
              ViewBaseTransactionAmount ,
              ClickBaseTransactionCount ,
              ClickBaseTransactionAmount ,
              TransactionCountWithWeight ,
              PublisherCost ,
              CurrencyID ,
              ThirdPartyDataCost ,
              ActualThirdPartyDataCost
                        
            )
            SELECT  NMCC.ClientID ,
                    NMCC.GenerateDate ,
                    NMCC.Creative_ID ,
                    NMCC.Campaign_ID ,
                    NMCC.Publisher_ID ,
                    NMCC.NumImpressions ,
                    ISNULL(Cost, 0) AS Cost ,   -- Future Replacement - Function.
                    ISNULL(DC.NumClicks, 0) AS NumClicksTracked ,
                    ISNULL(TS.ViewBaseTransactionCount, 0) ViewBaseTransactionCount ,
                    ISNULL(TS.ViewBaseTransactionAmount, 0) ViewBaseTransactionAmount ,
                    ISNULL(TS.ClickBaseTransactionCount, 0) ClickBaseTransactionCount ,
                    ISNULL(TS.ClickBaseTransactionAmount, 0) ClickBaseTransactionAmount ,
                    TS.TransactionCountWithWeight ,
                    NMCC.PublisherCost ,
                    NMCC.CurrencyID ,
                    ISNULL(ThirdPartyDataCost, 0) AS ThirdPartyDataCost ,   -- Future Replacement - Function.
                    ISNULL(ActualThirdPartyDataCost, 0) AS ActualThirdPartyDataCost   -- Future Replacement - Function.
            FROM    #NMImpCostRollup NMCC --num impressions
                    LEFT JOIN #CostCountRollup TS --transaction amounts
                    ON TS.ClientID = NMCC.ClientID
                       AND TS.Creative_ID = NMCC.Creative_ID
                       AND TS.Campaign_ID = NMCC.Campaign_ID
                       AND TS.Publisher_ID = NMCC.Publisher_ID
                       AND TS.GenerateDate = NMCC.GenerateDate
                    LEFT JOIN #DisplayClickRollup DC --num clicks
                    ON DC.ClientID = NMCC.ClientID
                       AND DC.Creative_ID = NMCC.Creative_ID
                       AND DC.Campaign_ID = NMCC.Campaign_ID
                       AND DC.Publisher_ID = NMCC.Publisher_ID
                       AND DC.GenerateDate = NMCC.GenerateDate	
                                			

					--  Records without Engine Data
    INSERT  INTO #RPT_DSP_Summary_Creative
            ( [ClientID] ,
              [GenerateDate] ,
              [creative_id] ,
              [campaign_id] ,
              [publisher_id] ,
              [NumImpressions] ,
              [Cost] ,
              [NumClicksTracked] ,
              [ViewBaseTransactionCount] ,
              [ViewBaseTransactionAmount] ,
              [ClickBaseTransactionCount] ,
              [ClickBaseTransactionAmount] ,
              [TransactionCountWithWeight] ,
              [PublisherCost] ,
              [CurrencyID] ,
              [ThirdPartyDataCost] ,
              [ActualThirdPartyDataCost]
                        
            )
            SELECT  TS.ClientID ,
                    TS.GenerateDate ,
                    TS.creative_id ,
                    TS.campaign_id ,
                    TS.publisher_id ,
                    0 AS NumImpressions ,
                    0 AS Cost ,
                    ISNULL(DC.NumClicks, 0) AS NumClicksTracked ,
                    ISNULL(TS.ViewBaseTransactionCount, 0) ViewBaseTransactionCount ,
                    ISNULL(TS.ViewBaseTransactionAmount, 0) ViewBaseTransactionAmount ,
                    ISNULL(TS.ClickBaseTransactionCount, 0) ClickBaseTransactionCount ,
                    ISNULL(TS.ClickBaseTransactionAmount, 0) ClickBaseTransactionAmount ,
                    ISNULL(TransactionCountWithWeight, 0) TransactionCountWithWeight ,
                    0 AS PublisherCost ,
                    TS.PublisherCurrencyID AS CurrencyID ,
                    0 AS ThirdPartyDataCost ,
                    0 AS ActualThirdPartyDataCost   --  Do not populate!  No Engine Data
            FROM    #CostCountRollup TS
                    LEFT JOIN #DisplayClickRollup DC ON DC.ClientID = TS.ClientID
                                                        AND DC.Creative_ID = TS.creative_id
                                                        AND DC.Campaign_ID = TS.campaign_id
                                                        AND DC.Publisher_ID = TS.publisher_id
                                                        AND DC.GenerateDate = TS.GenerateDate
            WHERE   NOT EXISTS ( SELECT 1
                                 FROM   #RPT_DSP_Summary_Creative
                                 WHERE  ClientID = TS.ClientID
                                        AND Creative_ID = TS.creative_id
                                        AND Campaign_ID = TS.campaign_id
                                        AND Publisher_ID = TS.publisher_id
                                        AND GenerateDate = TS.GenerateDate )
             
          
    INSERT  INTO #RPT_DSP_Summary_Creative
            ( [ClientID] ,
              [GenerateDate] ,
              [creative_id] ,
              [campaign_id] ,
              [publisher_id] ,
              [NumImpressions] ,
              [Cost] ,
              [NumClicksTracked] ,
              [ViewBaseTransactionCount] ,
              [ViewBaseTransactionAmount] ,
              [ClickBaseTransactionCount] ,
              [ClickBaseTransactionAmount] ,
              [TransactionCountWithWeight] ,
              [PublisherCost] ,
              [CurrencyID] ,
              [ThirdPartyDataCost] ,
              [ActualThirdPartyDataCost]
                        
            )
            SELECT  DC.ClientID ,
                    DC.GenerateDate ,
                    DC.creative_id ,
                    DC.campaign_id ,
                    DC.publisher_id ,
                    0 AS NumImpressions ,
                    0 AS Cost ,
                    ISNULL(DC.NumClicks, 0) AS NumClicksTracked ,
                    0 AS ViewBaseTransactionCount ,
                    0 AS ViewBaseTransactionAmount ,
                    0 AS ClickBaseTransactionCount ,
                    0 AS ClickBaseTransactionAmount ,
                    0 AS TransactionCountWithWeight ,
                    0 AS PublisherCost ,
                    DC.PublisherCurrencyID AS CurrencyID ,
                    0 AS ThirdPartyDataCost ,
                    0 AS ActualThirdPartyDataCost
            FROM    #DisplayClickRollup DC
            WHERE   NOT EXISTS ( SELECT 1
                                 FROM   #RPT_DSP_Summary_Creative
                                 WHERE  ClientID = DC.ClientID
                                        AND Creative_ID = DC.creative_id
                                        AND Campaign_ID = DC.campaign_id
                                        AND Publisher_ID = DC.publisher_id
                                        AND GenerateDate = DC.GenerateDate )                            
                                      								
					
						
    SELECT  GENerateDATE ,
            SUM(NumClicksTracked)
    FROM    #RPT_DSP_Summary_Creative
    GROUP BY GENerateDATE


     SELECT  GENerateDATE ,
            SUM(NumClicksTracked)
    FROM    RPT_DSP_Summary_Creative
    GROUP BY GENerateDATE
