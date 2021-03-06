USE [SIProcessing_Attribution_Archive]

DECLARE	@debug					BIT = 1,
		@MMYY					VARCHAR(8),
		@SourceTable			VARCHAR(100),
        @tname					VARCHAR(100),
		@rowsql					VARCHAR(500),
		@Switch					VARCHAR(1000),
        @sql					VARCHAR(2000),
        @rundate				DATETIME,
        @date					DATETIME,
        @startdate				DATETIME,
        @mid					DATETIME,
        @enddate				DATETIME,
        @PartNum				INT,
        @rowcount				INT
        
SET @SourceTable = 'TrackedExposure'
SET @tname = 'TrackedExposure'
SET @date = '2010-01-01' --GETDATE() Put in the month after the month you are trying to pump
SET @rundate = GETDATE()
SET @startdate = (select DATEADD(month,-1,CAST(CAST(YEAR(@date) AS VARCHAR(4)) + '/' + CAST(MONTH(@date) AS VARCHAR(2)) + '/01' AS DATETIME)))
SET @mid = (select DATEADD(month,-1,CAST(CAST(YEAR(@date) AS VARCHAR(4)) + '/' + CAST(MONTH(@date) AS VARCHAR(2)) + '/16' AS DATETIME)))
SET @enddate = (select CAST(CAST(YEAR(@date) AS VARCHAR(4)) + '/' + CAST(MONTH(@date) AS VARCHAR(2)) + '/01' AS DATETIME))
SET @PartNum =  (DATEPART(month,DATEADD(month,-1,@date)) + (DATEPART(year,DATEADD(month,-1,@date))-2009)*12 - 11)*2 -1

IF(@debug = 1)
BEGIN
	PRINT @startdate
	PRINT @mid
	PRINT @enddate
	PRINT @PartNum
END

WHILE(@PartNUM < ((DATEPART(month,DATEADD(month,-1,@date)) + (DATEPART(year,DATEADD(month,-1,@date))-2009)*12 - 11)*2) + 1)
BEGIN

	IF(@PartNum = 2)
	Begin
	-- Check if destination table is clean
	IF (SELECT rows FROM sys.partitions WHERE object_id = OBJECT_ID(N'SIProcessing_Attribution_Archive..' +@tname+'') and partition_number = @PartNum and index_id = 1) > 0
	BEGIN
		SET @Switch = '	TRUNCATE TABLE SIProcessing_Attribution_Archive..'+@tname+'_swap
		ALTER TABLE '+@tname+' SWITCH PARTITION ('+CAST(@PartNum AS VARCHAR(10))+') TO '+@tname+'_swap PARTITION ('+CAST(@PartNum AS VARCHAR(10))+')
		TRUNCATE TABLE SIProcessing_Attribution_Archive..'+@tname+'_swap
		
		UPDATE SIProcessing_Attribution_Archive..ArchiveLog
		SET ErrorMessage = ''DELETED''
		where ErrorMessage = ''SUCCESS'' and RUNDATE < '''+ convert(varchar,@rundate,121)+''' and Tablename = '''+@SourceTable+''' and partition_number = '''+CAST(@PartNum AS VARCHAR(10))+'''
		'
		if(@debug = 1) 
			PRINT @Switch
		ELSE
			EXEC (@Switch)
	END

	SET @sql =  
	'BEGIN TRY
		TRUNCATE TABLE SIProcessing_Attribution_Archive..'+@tname+'_swap
		INSERT INTO SIProcessing_Attribution_Archive..'+@tname+'_swap SELECT * FROM SIProcessing_Attribution..'+@SourceTable+' where CreateDateUTC >= '''+convert(varchar,@startdate,121)+''' and CreateDateUTC < '''+convert(varchar,@mid,121)+'''
	END TRY

	BEGIN CATCH
		DECLARE @err INT = ERROR_NUMBER()                    
		DECLARE @msg VARCHAR(2000) = ERROR_MESSAGE()
		RAISERROR (''The SIProcessing_Attribution_Archive..'+@tname+'_swap failed with error# %d and with the following message: %s'', 16, 1, @err, @msg )
		
		UPDATE SIProcessing_Attribution_Archive..ArchiveLog
		SET ErrorMessage = ''The SIProcessing_Attribution_Archive..'+@tname+'_swap failed with error# ''+cast(@err as VARCHAR)+'' and with the following message: ''+@msg+''.''
		where RUNDATE = '''+ convert(varchar,@rundate,121)+''' and Tablename = '''+@SourceTable+'''  and partition_number = '''+CAST(@PartNum AS VARCHAR(10))+'''
		
		TRUNCATE TABLE SIProcessing_Attribution_Archive..'+@tname+'_swap
		
	END CATCH'
	SET @Switch = 'ALTER TABLE '+@tname+'_swap SWITCH PARTITION ('+CAST(@PartNum AS VARCHAR(10)) +') TO '+@tname+' PARTITION ('+CAST(@PartNum AS VARCHAR(10))+ ')'

	IF(@debug = 0)
	BEGIN
		INSERT INTO SIProcessing_Attribution_Archive..ArchiveLog([DATE],[TableName],[Partition_Number],[SQL_Statement],[Switch_Statement], [RUNDATE])
		Values (@startdate, @SourceTable, @PartNum, @sql, @Switch, @rundate)
	END

	-- Dynamic SQL to find row count in Source table and insert it in ArchiveLog
	SET @rowsql = 'UPDATE SIProcessing_Attribution_Archive..ArchiveLog
		SET SIProcessing_RowCount = (SELECT count(1) FROM SIProcessing_Attribution..' + @SourceTable+' where CreateDateUTC >= '''+convert(varchar,@startdate,121)+''' and CreateDateUTC < '''+convert(varchar,@mid,121)+''')
		where RUNDATE = '''+ convert(varchar,@rundate,121)+''' and Tablename = '''+@SourceTable+''' and partition_number = '''+CAST(@PartNum AS VARCHAR(10))+''''
	IF(@debug = 0)
		EXEC(@rowsql)
	SELECT @rowcount = SIProcessing_RowCount FROM SIProcessing_Attribution_Archive..ArchiveLog WHERE RUNDATE = @rundate and Partition_Number = @PartNum

	IF @debug = 1
	BEGIN
		PRINT (@sql)
		PRINT (@Switch)
	END

	ELSE
	BEGIN
		EXEC (@sql)
		IF (SELECT rows FROM sys.partitions WHERE object_id = OBJECT_ID(N'SIProcessing_Attribution_Archive..' +@tname+ '_swap') and partition_number = @PartNum and index_id = 1) > 0
		EXEC (@switch)

		UPDATE SIProcessing_Attribution_Archive..ArchiveLog
		SET Archive_RowCount = (SELECT rows FROM sys.partitions WHERE object_id = OBJECT_ID(N'SIProcessing_Attribution_Archive..' +@tname+ '') and partition_number = @PartNum and index_id = 1)
		where RUNDATE = @rundate and Tablename = @SourceTable and Partition_Number = @PartNum

		IF (SELECT rows FROM sys.partitions WHERE object_id = OBJECT_ID(N'SIProcessing_Attribution_Archive..' +@tname+'') and partition_number = @PartNum and index_id = 1)= @rowcount
		UPDATE SIProcessing_Attribution_Archive..ArchiveLog
		SET ErrorMessage = 'SUCCESS'
		where RUNDATE = @rundate and Tablename = @SourceTable and Partition_Number = @PartNum
	END
	END

	SET @Partnum = @PartNum + 1	
	SET @startdate = @mid
	SET @mid = @enddate
	SET @rundate = GETDATE()

END
