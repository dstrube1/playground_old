

DECLARE
	@ClientID [int] = 9064,
	@StartDate [datetime]= '10/02/2013',
	@EndDate [datetime]='10/04/2013',--noninclusive
	@CampaignID [varchar](2000) = null,
	@AdCategoryID [varchar](max) = null,
	@SEID [varchar](2000) = null,
	@CustomerTransactionTypeID varchar(max) = '39202',
	@CurrencyID [int] = 73,
	@ChannelID tinyint = 1  -- 1 means PS, 5 means SocailMedia


	declare @ls_SQL NVARCHAR(MAX)
	declare @N1Desc nvarchar(100), @N2Desc nvarchar(100), @N3Desc nvarchar(100), @N4Desc nvarchar(100), @N5Desc nvarchar(100), @N6Desc nvarchar(100), @N7Desc nvarchar(100), @N8Desc nvarchar(100), @N9Desc nvarchar(100), @N10Desc nvarchar(100)
	declare @X1Desc nvarchar(100), @X2Desc nvarchar(100), @X3Desc nvarchar(100), @X4Desc nvarchar(100), @X5Desc nvarchar(100), @X6Desc nvarchar(100), @X7Desc nvarchar(100), @X8Desc nvarchar(100), @X9Desc nvarchar(100), @X10Desc nvarchar(100)
	
	select @ls_SQL =
	'DECLARE @Device TABLE
            (
              DeviceTypeID TINYINT ,
              RptDeviceTypeDesc NVARCHAR(100) ,
              PRIMARY KEY CLUSTERED ( DeviceTypeID )
            )
	
    INSERT  INTO @Device ( DeviceTypeID , RptDeviceTypeDesc )
                SELECT DISTINCT
                        DeviceTypeID ,
                        RptDeviceTypeDesc
                FROM    SIAccess.dbo.LUDeviceTypeSearchEngineMapping
                WHERE   RptDeviceTypeDesc IS NOT NULL
	'
                
	select @N1Desc = LTRIM(RTRIM(N1Desc)),
			@N2Desc = LTRIM(RTRIM(N2Desc)),
			@N3Desc = LTRIM(RTRIM(N3Desc)),
			@N4Desc = LTRIM(RTRIM(N4Desc)),
			@N5Desc = LTRIM(RTRIM(N5Desc)),
			@N6Desc = LTRIM(RTRIM(N6Desc)),
			@N7Desc = LTRIM(RTRIM(N7Desc)),
			@N8Desc = LTRIM(RTRIM(N8Desc)),
			@N9Desc = LTRIM(RTRIM(N9Desc)),
			@N10Desc = LTRIM(RTRIM(N10Desc)),
			@X1Desc = LTRIM(RTRIM(X1Desc)),
			@X2Desc = LTRIM(RTRIM(X2Desc)),
			@X3Desc = LTRIM(RTRIM(X3Desc)),
			@X4Desc = LTRIM(RTRIM(X4Desc)),
			@X5Desc = LTRIM(RTRIM(X5Desc)),
			@X6Desc = LTRIM(RTRIM(X6Desc)),
			@X7Desc = LTRIM(RTRIM(X7Desc)),
			@X8Desc = LTRIM(RTRIM(X8Desc)),
			@X9Desc = LTRIM(RTRIM(X9Desc)),
			@X10Desc = LTRIM(RTRIM(X10Desc))
	from SIOLAP.dbo.ClientTransactionVariableDesc 
	where ClientID = @ClientID

  select @StartDate = convert(datetime, convert(varchar(20), @StartDate, 101)),
         @EndDate = convert(datetime, convert(varchar(20), @EndDate, 101))

    select @ls_SQL = @ls_SQL + 'select TID, kw.CampaignID, kw.AdCategoryID, kw.CSKID, tt.Keyword, tt.SEID, KeywordMatchDesc, ClickTime, EasternCreateDate as [ConversionTime], CustomerTransactionName as [TransactionName], TransactionAmount, OrigTransactionAmt as [Original Revenue], se.CurrencyID as CurrencyID, ActionQuantity * isnull(Weight, 1) as TransactionCountWithWeight, ExposureType, ExposureSequence, AttributedExposures, ActionWeightFactor as ActionCredit,ld.RptDeviceTypeDesc AS Device '

    if @N1Desc is not NULL AND @N1Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N1 as [' + @N1Desc + ']'
    end

    if @N2Desc is not null AND @N2Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N2 as [' + @N2Desc + ']'
    end

    if @N3Desc is not null AND @N3Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N3 as [' + @N3Desc + ']'
    end

    if @N4Desc is not null AND @N4Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N4 as [' + @N4Desc + ']'
    end

    if @N5Desc is not null AND @N5Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N5 as [' + @N5Desc + ']'
    end

    if @N6Desc is not null AND @N6Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N6 as [' + @N6Desc + ']'
    end

    if @N7Desc is not null AND @N7Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N7 as [' + @N7Desc + ']'
    end

    if @N8Desc is not null AND @N8Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N8 as [' + @N8Desc + ']'
    end

    if @N9Desc is not null AND @N9Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N9 as [' + @N9Desc + ']'
    end

    if @N10Desc is not null AND @N10Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', N10 as [' + @N10Desc + ']'
    end

    if @X1Desc is not null AND @X1Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X1 as [' + @X1Desc + ']'
    end

    if @X2Desc is not null AND @X2Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X2 as  [' + @X2Desc + ']'
    end

    if @X3Desc is not null AND @X3Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X3 as [ ' + @X3Desc + ']'
    end

    if @X4Desc is not null AND @X4Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X4 as [ ' + @X4Desc + ']'
    end

    if @X5Desc is not null AND @X5Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X5 as [ ' + @X5Desc + ']'
    end

    if @X6Desc is not null AND @X6Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X6 as [ ' + @X6Desc + ']'
    end

    if @X7Desc is not null AND @X7Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X7 as  [' + @X7Desc + ']'
    end

    if @X8Desc is not null AND @X8Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X8 as [ ' + @X8Desc + ']'
    end

    if @X9Desc is not null AND @X9Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X9 as [ ' + @X9Desc + ']'
    end

    if @X10Desc is not null AND @X10Desc <> ''
    begin
      select @ls_SQL = @ls_SQL + ', X10 as [ ' + @X10Desc + ']'
    end

   select @ls_SQL = @ls_SQL + '  from SIProcessing.dbo.TransactionTracking tt 
	Join SIProcessing.dbo.CSKeywords kw  on kw.CSKID = tt.CSKID
    join MAIN_SearchIgnite_REPL.dbo.LUKeywordMatchType mt on mt.KeywordMatchTypeID = kw.KeywordMatchTypeID
    join MAIN_SearchIgnite_REPL.dbo.SearchEngine se  on se.SEID = tt.SEID
    join SIAnalysis.dbo.LUExposureType et on et.ExposureTypeID = tt.ExposureTypeID
    join SIAnalysis.dbo.v_ClientCustomerTransactionType ct on  ct.ClientID = tt.ClientID and ct.CustomerTransactionTypeID = tt.CustomerTransactionTypeID
    left JOIN @Device ld ON ld.DeviceTypeID = ISNULL(tt.DeviceTypeID,0)
	left join SIOLAP.dbo.ClientCustomerTransactionTypeWeightHistory tw on tw.ClientID = tt.ClientID and tw.StartDate <= tt.EasternCreateDate and tw.EndDate >= tt.EasternCreateDate and tw.CustomerTransactionTypeID = tt.CustomerTransactionTypeID
    where tt.ClientID = ' + convert(varchar(10), @ClientID) + ' 
    and tt.EasternCreateDate>= ''' + convert(varchar(20), @StartDate) + ''' 
    and tt.EasternCreateDate < ''' + convert(varchar(20), @EndDate) + ''''

	if @CustomerTransactionTypeID is not null and ltrim(rtrim(@CustomerTransactionTypeID)) <> ''
		select @ls_SQL = @ls_SQL + ' and tt.CustomerTransactionTypeID in (' + @CustomerTransactionTypeID + ')'

	SET @CampaignID = ISNULL(rtrim(@CampaignID), '')
	SET @AdCategoryID = ISNULL(rtrim(@AdCategoryID), '')

	if LEN(@CampaignID) > 0
	BEGIN
		select @ls_SQL = @ls_SQL + ' and (	kw.CampaignID in (' + @CampaignID + ')'

		if LEN(@AdCategoryID) > 0
			select @ls_SQL = @ls_SQL + ' OR kw.AdCategoryID in (' + @AdCategoryID + ') )'
		ELSE
			select @ls_SQL = @ls_SQL + ')'
	END
	ELSE IF LEN(@AdCategoryID) > 0
		select @ls_SQL = @ls_SQL + ' and kw.AdCategoryID in (' + @AdCategoryID + ')'

	if @SEID is not null and ltrim(rtrim(@SEID)) <> ''
		select @ls_SQL = @ls_SQL + ' and kw.SEID in (' + @SEID + ')'

	select @ls_SQL = @ls_SQL + ' and exists (select 1 from SIOLAP.dbo.SearchEngine_Parent where ParentSEID = se.ParentSEID and ChannelID = ' + convert(varchar(10), @ChannelID) + ')'
	
	PRINT (@LS_SQL)
	exec (@LS_SQL)


