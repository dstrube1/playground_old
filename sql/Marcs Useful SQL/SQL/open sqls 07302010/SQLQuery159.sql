EXEC SI_SP_RPT_OT_Summary_Keywords_Read
@ClientID = 4360,
@StartDate = '07/13/2010',
@EndDate = '07/14/2010'

EXEC SI_SP_RPT_OT_Summary_Keywords_Read
@ClientID = 4360,
@StartDate = '07/17/2010',
@EndDate = '07/18/2010'



select umKeywordID, 
		Keyword, 
		sum(TransactionCount) as TransactionCount, 
		sum(TransactionAmount * isnull(ExchangeRate, 1)) as TransactionAmount,
		 sum(TransactionCount*isnull(Weight, 1)) as TransactionCountWithWeight
		from dbo.RPT_UM_Summary_CustomerTT_ClientLevel tt 
		join NatureSearchEngine se ON tt.OTSEID = se.NSEID
		left join dbo.ClientCustomerTransactionTypeWeight tw on tw.ClientID = tt.ClientID and tw.CustomerTransactionTypeID = tt.CustomerTransactionTypeID
		left join dbo.CurrencyExchangeData ed on ed.FromCurrencyID = se.CurrencyID and ToCurrencyID = 73 
	    where tt.ClientID = 4360
		and GenerateDate between '07/17/2010' and '07/18/2010'


USE [SIOLAP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SI_SP_RPT_OT_Summary_Keywords_Read]
@ClientID int,
@StartDate smalldatetime,
@EndDate smalldatetime,
@CustomerTransactionTypeID varchar(5000) = null,
@OTSEID varchar(5000) = null,
@CurrencyID int = 73,
@IncludeCustomerTransaction tinyint = null
as
begin
--------------------------------------------------------------------------------------
--Change History
--------------------------------------------------------------------------------------
--07/31/2008 YZ Initial
--09/03/2008 ????
--10/21/2008 DA Using v_ClientCustomerTransactionType
--02/08/2009 YZ Add DFA, also per Moon, use UM tables instead OT tables
--04/13/2010 YZ SIP-3174 Missed currency conversion on Cost field
--05/06/2010 YZ JIRA SIP-3400 Convert all impressions to BidInt
--------------------------------------------------------------------------------------
	set nocount on
	declare @ls_SQL nvarchar(max), @ls_TT nvarchar(max), @ls_CustomerTransactionName nvarchar(max), @CTTypeID int
	create table #TT (KeywordID int, Keyword nvarchar(200), TransactionCount numeric(18,2), TransactionAmount money, TransactionCountWithWeight numeric(18,2))
	Create table #Result1 (KeywordID int, Keyword nvarchar(200), NumImpressions bigint, Cost money, NetMedia money, NumClicksTracked int, TransactionCount numeric(18,2), TransactionAmount money, TransactionCountWithWeight numeric(18,2))
	create table #T (CustomerTransactionTypeID int)

	select @StartDate = convert(datetime, convert(varchar(20), @StartDate, 101)),
			@EndDate = convert(datetime, convert(varchar(20), @EndDate, 101)),
			@CustomerTransactionTypeID = ltrim(rtrim(@CustomerTransactionTypeID))


	if @CustomerTransactionTypeID is not null and @CustomerTransactionTypeID  <> ''
	begin
		select @ls_TT = 'insert into #TT
			(KeywordID, Keyword, TransactionCount, TransactionAmount, TransactionCountWithWeight)
		select umKeywordID, Keyword, sum(TransactionCount) as TransactionCount, sum(TransactionAmount * isnull(ExchangeRate, 1)) as TransactionAmount, sum(TransactionCount*isnull(Weight, 1)) as TransactionCountWithWeight
		from dbo.RPT_UM_Summary_CustomerTT_ClientLevel tt 
		join NatureSearchEngine se ON tt.OTSEID = se.NSEID
		left join dbo.ClientCustomerTransactionTypeWeight tw on tw.ClientID = tt.ClientID and tw.CustomerTransactionTypeID = tt.CustomerTransactionTypeID
		left join dbo.CurrencyExchangeData ed on ed.FromCurrencyID = se.CurrencyID and ToCurrencyID = ' + convert(varchar(10), @CurrencyID)
		+ ' where tt.ClientID = ' + convert(varchar(10), @ClientID)
		+ ' and GenerateDate between ''' + convert(varchar(20), @StartDate) + ''' and ''' + convert(varchar(20), @EndDate) + ''''

		select @ls_SQL = 'select sk.UMKeywordID, sk.Keyword, sum(convert(bigint, NumImpressions)) as NumImpressions, sum(Cost) as Cost, sum(NetMedia) as NetMedia, sum(NumExposureReported) as NumClicksTracked, tt.TransactionCount, tt.TransactionAmount, tt.TransactionCountWithWeight from dbo.RPT_UM_Summary_Keywords sk join #TT tt on sk.ClientID = ' + convert(varchar(10), @ClientID) + ' and  GenerateDate between ''' + convert(varchar(20), @StartDate) + ''' and ''' + convert(varchar(20), @EndDate) + ''''



		if @OTSEID is not null
			select @ls_TT = @ls_TT + ' and OTSEID in (' + @OTSEID + ')',
					@ls_SQL = @ls_SQL + ' and OTSEID in (' + @OTSEID + ')'
		else
			select @ls_TT = @ls_TT + ' and OTSEID = OTSEID',
					@ls_SQL = @ls_SQL + ' and OTSEID = OTSEID'

		select @ls_TT = @ls_TT + ' and tt.CustomerTransactionTypeID in (' + @CustomerTransactionTypeID + ') group by UMKeywordID, Keyword'
		exec (@ls_TT)

		select @ls_SQL = @ls_SQL + ' and sk.UMKeywordID = tt.KeywordID group by sk.UMKeywordID, sk.Keyword, tt.TransactionCount, tt.TransactionAmount, tt.TransactionCountWithWeight'
	end
	else
	begin
		select @ls_SQL = 'select UMKeywordID, Keyword, sum(convert(bigint, NumImpressions)) as NumImpressions, sum(Cost * isnull(ExchangeRate, 1)) as Cost, sum(NetMedia) as NetMedia, sum(NumExposureReported) as NumClicksTracked, sum(TransactionCount) as TransactionCount, sum(TransactionAmount * isnull(ExchangeRate, 1)) as TransactionAmount, sum(TransactionCountWithWeight) as TransactionCountWithWeight from dbo.RPT_UM_Summary_Keywords tt join dbo.NatureSearchEngine se on tt.ClientID = ' + convert(varchar(10), @ClientID)
		+ ' and GenerateDate between ''' + convert(varchar(20), @StartDate) + ''' and ''' + convert(varchar(20), @EndDate) + ''' '

		if @OTSEID is not null and ltrim(rtrim(@OTSEID)) <> ''
			select @ls_SQL = @ls_SQL + ' and tt.OTSEID in (' + @OTSEID + ')'

		select @ls_SQL = @ls_SQL + ' and se.NSEID = tt.OTSEID left join dbo.CurrencyExchangeData et on et.FromCurrencyID = se.CurrencyID and et.ToCurrencyID = ' + convert(varchar(20), @CurrencyID)
		+ ' group by UMKeywordID, Keyword'
	end

	if isnull(@IncludeCustomerTransaction, 0) <> 1 or not exists (select 1 from v_ClientCustomerTransactionType where ClientID = @ClientID and CustomerTransactionTypeID > 3)
	begin
		insert into #Result1
			(KeywordID, Keyword, NumImpressions, Cost, NetMedia, NumClicksTracked, TransactionCount, TransactionAmount, TransactionCountWithWeight)
		exec (@ls_SQL)
		PRINT(@ls_SQL)
		
		select Keyword, NumImpressions, Cost, NetMedia, NumClicksTracked, TransactionCount, TransactionAmount, TransactionCountWithWeight
		from #Result1
	end
	else
	begin
		--Include CustomerTransactionType
		select @ls_CustomerTransactionName = ''

		insert into #Result1
			(KeywordID, Keyword, NumImpressions, Cost, NetMedia, NumClicksTracked, TransactionCount, TransactionAmount, TransactionCountWithWeight)
		exec (@ls_SQL)

		if @CustomerTransactionTypeID is not null and ltrim(rtrim(@CustomerTransactionTypeID)) <> ''
		begin
			insert into #T
				(CustomerTransactionTypeID)
			select ParseID
			from dbo.fn_ParseNumList (@CustomerTransactionTypeID)

			create index idx_TT on #T (CustomerTransactionTypeID asc)
		end

		select @CTTypeID = min(CustomerTransactionTypeID)
		from dbo.v_ClientCustomerTransactionType
		where ClientID = @ClientID
		and CustomerTransactionTypeID > 3
		and ascii(CustomerTransactionName) is not null
		and ltrim(rtrim(CustomerTransactionName)) <> ''

		while @CTTypeID > 0
		begin
			if @CustomerTransactionTypeID is null or exists (select 1 from #T where CustomerTransactionTypeID = @CTTypeID)
				select @ls_CustomerTransactionName = @ls_CustomerTransactionName + ',[' + substring(CustomerTransactionName, 1, 128) + ']'
				from  dbo.v_ClientCustomerTransactionType
				where ClientID = @ClientID
				and CustomerTransactionTypeID = @CTTypeID

			select @CTTypeID = min(CustomerTransactionTypeID)
			from dbo.v_ClientCustomerTransactionType
			where ClientID = @ClientID
			and CustomerTransactionTypeID > @CTTypeID
			and ascii(CustomerTransactionName) is not null
			and ltrim(rtrim(CustomerTransactionName)) <> ''
		end
		select @ls_CustomerTransactionName = ltrim(rtrim(@ls_CustomerTransactionName))
		select @ls_CustomerTransactionName = substring(@ls_CustomerTransactionName, 2, datalength(@ls_CustomerTransactionName))

		if @ls_CustomerTransactionName <> ''
		begin
			select @ls_SQL = 'select KeywordID,' + @ls_CustomerTransactionName + ' from (select UMKeywordID as KeywordID, CustomerTransactionName, TransactionAmount * isnull(ExchangeRate, 1) as TransactionAmount from dbo.RPT_UM_Summary_CustomerTT_ClientLevel sc join dbo.v_ClientCustomerTransactionType tt on sc.ClientID = '
							+ convert(nvarchar(20), @ClientID)
							+ ' and GenerateDate between ''' + convert(varchar(20), @StartDate, 101) + ''' and ''' + convert(varchar(20), @EndDate, 101)
							+ ''''

			if @CustomerTransactionTypeID is not null and ltrim(rtrim(@CustomerTransactionTypeID)) <> ''
				select @ls_SQL = @ls_SQL + ' and sc.CustomerTransactionTypeID in (' + @CustomerTransactionTypeID + ')'


			if @OTSEID is not null and ltrim(rtrim(@OTSEID)) <> ''
				select @ls_SQL = @ls_SQL + ' and sc.OTSEID in (' + @OTSEID + ')'

			select @ls_SQL = @ls_SQL + ' and sc.ClientID = tt.ClientID and sc.CustomerTransactionTypeID = tt.CustomerTransactionTypeID
										join NatureSearchEngine se on sc.OTSEID = se.NSEID
										left join dbo.CurrencyExchangeData ed on ed.FromCurrencyID = se.CurrencyID and ed.ToCurrencyID = ' + convert(varchar(20), isnull(@CurrencyID, 73)) + ') as a
								pivot (sum(TransactionAmount) for CustomerTransactionName in (' + @ls_CustomerTransactionName + ')) as b'

			select @ls_SQL = 'select re.Keyword, NumImpressions, Cost, NetMedia, NumClicksTracked, TransactionCount, TransactionAmount, TransactionCountWithWeight, ' + @ls_CustomerTransactionName + ' from #Result1 re left join (' + @ls_SQL +') ct on re.KeywordID = ct.KeywordID'
			exec (@ls_SQL)
		end
		else
			exec (@ls_SQL)
	END
	
	DROP table #TT 
	DROP table #Result1
	DROP table #T
end

GO
GRANT EXECUTE ON [dbo].[SI_SP_RPT_OT_Summary_Keywords_Read] TO [webaccess] AS [dbo]