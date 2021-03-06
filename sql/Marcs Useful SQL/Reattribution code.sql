
	
	IF OBJECT_ID ('tempdb..#TrackedActionID1') IS NOT NULL
	DROP TABLE #TrackedActionID1
	
		CREATE TABLE #TrackedActionID1 (
			TrackedActionID BIGINT,
			CreateDateUTC DATETIME,
			CurrencyID INT,
			TransactionAmount MONEY,
			CustomerTransactionTypeID INT,
			ClientID INT,
			UserUniqueGUID VARCHAR(36),
			LocalizedCreateDate DATETIME,
			AffiliateID INT,
			N2 NVARCHAR(100)
		)
		
		INSERT INTO #TrackedActionID1
		SELECT TrackedActionID ,
			  CreateDateUTC ,
			  CurrencyID ,
			  TransactionAmount ,
			  CustomerTransactionTypeID ,
			  ClientID ,
			  UserUniqueGUID ,
			  LocalizedCreateDate ,
			  AffiliateID ,
			  N2 
		FROM SIProcessing_Attribution..TrackedAction
		WHERE TrackingSourceID = 6
		AND ClientID IN (7634,7636,7637,7668,7673,7789,7855,7895,7674)
		and TrackingSourceCreateDateUTC < '2012-12-06 21:15:00.000'
		AND RecordStatus = 'A'
		
		CREATE CLUSTERED INDEX CX_Tmp_#TrackedActionID1 ON #TrackedActionID1(TrackedActionID)
		
		UPDATE ta
		SET RecordStatus = 'I',
			EffectiveEndDateUTC = GETUTCDATE()
		FROM SIProcessing_Attribution..TrackedAction ta
		WHERE EXISTS(SELECT 1 FROM #TrackedActionID1 WHERE ta.TrackedActionID = TrackedActionID AND ClientID = ta.ClientID AND CreateDateUTC = ta.CreateDateUTC )
			AND RecordStatus = 'A'

		EXEC SIProcessing_CacheHistory.dbo.SI_SP_ExposureSequence_Delete @InactiveActionDays = 70
		
		UPDATE ta
		SET RecordStatus = 'A',
			EffectiveEndDateUTC = NULL
		FROM SIProcessing_Attribution..TrackedAction ta
		WHERE EXISTS(SELECT 1 FROM #TrackedActionID1 WHERE ta.TrackedActionID = TrackedActionID AND ClientID = ta.ClientID AND CreateDateUTC = ta.CreateDateUTC)
			AND RecordStatus = 'I'

		INSERT INTO SIProcessing_CacheHistory..TrackedActionReprocess
			( TrackedActionID ,
			  CreateDateUTC ,
			  CurrencyID ,
			  TransactionAmount ,
			  CustomerTransactionTypeID ,
			  ClientID ,
			  UserUniqueGUID ,
			  LocalizedCreateDate ,
			  AffiliateID ,
			  N2 ,
			  isProcessed
			  )
		select TrackedActionID ,
			  CreateDateUTC ,
			  CurrencyID ,
			  TransactionAmount ,
			  CustomerTransactionTypeID ,
			  ClientID ,
			  UserUniqueGUID ,
			  LocalizedCreateDate ,
			  AffiliateID ,
			  N2 ,
			  0 
		from  #TrackedActionID1

/*
SELECT CAST(CreateDateUTC AS DATE), COUNT(1) 
FROM #TrackedActionID1
GROUP BY CAST(CreateDateUTC AS DATE)
ORDER BY CAST(CreateDateUTC AS DATE)
		
		
SELECT COUNT(1)--, MIN(CreatedDate), MAX(CreatedDate) 
FROM SIProcessing_CacheHistory..TrackedCache tc WITH (NOLOCK)
WHERE EXISTS(SELECT 1 FROM #TrackedActionID1 WHERE TrackedActionID = tc.TrackedActionID)

UPDATE ta
SET EffectiveEndDateUTC = GETUTCDATE()
FROM SIProcessing_Attribution..TrackedAction ta
WHERE EXISTS(SELECT 1 FROM #TrackedActionID1 WHERE ta.TrackedActionID = TrackedActionID AND ClientID = ta.ClientID AND CreateDateUTC = ta.CreateDateUTC)
	AND RecordStatus = 'I'
	
	
EXEC SIProcessing_CacheHistory.dbo.SI_SP_ExposureSequence_Delete @InactiveActionDays = 70

SELECT COUNt(1), SUM(CASE WHEN AffiliateID IS NULL THEN 1 ELSE 0 END) AS NonAffiliate,SUM(CASE WHEN AffiliateID IS NULL THEN 0 ELSE 1 END) AS Affiliate
FROM SIProcessing_CacheHistory..TrackedActionReprocess WITH (NOLOCK) 
WHERE isProcessed = 0



SELECT DATEDIFF(dd,'2012-10-18 04:00:19.000', GETDATE())

*/


