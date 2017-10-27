USE Searchignite

BEGIN TRANSACTION
 
DECLARE @ClientId [int]  
DECLARE @SEID [int]   
DECLARE @CrawlGroupId INT  


IF OBJECT_ID('tempdb..#tmp') IS NOT NULL 
    DROP TABLE #tmp

CREATE TABLE #tmp
    (
      CrawlRecordId INT ,
      SEID INT ,
      ClientID INT ,
      Processed BIT
    )


INSERT  INTO #tmp ( CrawlRecordId ,SEID ,ClientID ,Processed )
        SELECT  CrawlRecordId , cr.SEID , cr.ClientID , 0
        FROM    dbo.CrawlRecord cr
        WHERE   CrawlRecordID IN (392266381,392266382,392266383,392266384,392266385,392266386,392266387,392266388,392266389,392266390,392266391,392266392,392266393,392266394,392266395,392266396,392266397,392266398,392266399,392266400,392266401,392266402,392266403,392266404,392266405,392266406,392266407,392266408,392266409,392266410,392266411,392266412,392266413,392266414,392266415,392266416,392266417,392266418,392266419,392266420,392266421,392266422,392266423,392266424,392266425,392266426,392266427,392266428,392266429,392266430,392266431,392266432,392266433,392266434,392266435,392266436,392266437,392266438,392266439,392266440,392266441,392266442,392266443,392266444,392266445,392266446,392266447,392266448,392266449,392266450,392266451,392266452,392266453,392266454,392266455,392266456,392266457,392266458,392266459,392266460,392266461,392266462,392266463,392266464,392266465,392266466,392266467,392266468,392266469,392266470,392266471,392266472,392266473,392266474,392266475,392266476,392266477,392266478,392266479,392266480,392266481,392266482,392266483,392266484,392266485,392266486,392266487,392266488,392266489,392266490,392266491,392266492,392266493,392266494,392266495,392266496,392266497,392266498,392266499,392266500,392266501,392266502,392266503,392266504,392266505,392266506,392266507,392266508,392266509,392266510,392266511,392266512,392266513,392266514,392266515,392266516,392266517,392266518,392266519,392266520,392266521,392266522,392266523,392266524,392266525,392266526,392266527,392266528,392266529,392266530,392266531,392266532,392266533,392266534,392266535,392266536,392266537,392266538,392266539,392266540,392266541,392266542,392266543,392266544,392266545,392266546,392266547,392266548,392266549,392266550,392266551,392266552,392266553,392266554,392266555,392266556,392266557,392266558,392266559,392266560,392266561,392266562,392266563,392266564,392266565,392266566,392266567,392266568,392266569,392266570,392266571,392266572,392266573,392266574,392266575,392266576,392266577,392266578,392266579,392266580,392266581,392266582,392266583,392266584,392266585,392266586,392266587,392266588,392266589,392266590,392266591,392266592,392266593,392266594,392266595,392266596,392266597,392266598,392266599,392266600,392266601,392266602,392266603,392266604,392266605,392266606,392266607,392266608,392266609,392266610,392266611,392266612,392266613,392266614,392266615,392266616,392266617,392266618,392266619,392266620,392266621,392266622,392266623,392266624,392266625,392266626,392266627,392266628,392266629,392266630,392266631,392266632,392266633,392266634,392266635,392266636,392266637,392266638,392266639,392266640,392266641,392266642,392266643,392266644,392266645,392266646,392266647,392266648,392266649,392266650,392266651,392266652,392266653,392266654,392266655,392266656,392266657,392266658,392266659,392266660,392266661,392266662,392266663,392266664,392266665,392266666,392266667,392266668,392266669,392266670,392266671,392266672,392266673,392266674,392266675,392266676,392266677,392266678,392266679,392266680,392266681,392266682,392266683,392266684,392266685,392266686,392266687,392266688,392266689,392266690,392266691,392266692,392266693,392266694,392266695,392266696,392266697,392266698,392266699,392266700,392266701,392266702,392266703,392266704,392266705,392266706,392266707,392266708,392266709,392266710,392266711,392266712,392266713,392266714,392266715,392266716,392266717,392266718,392266719,392266720,392266721,392266722,392266723,392266724,392266725,392266726,392266727,392266728,392266729,392266730,392266731,392266732,392266733,392266734,392266735,392266736,392266737,392266738,392266739,392266740,392266741,392266742,392266743,392266744,392266745,392266746)

WHILE EXISTS ( SELECT TOP 1 1 FROM #tmp WHERE Processed = 0 ) 
    BEGIN 
        SELECT TOP 1 @ClientId = ClientID , @SEID = SEID
        FROM    #tmp
        WHERE   Processed = 0

        UPDATE  cr
        SET     ProcessDateTime = NULL ,
                CrawlRecordStatusID = 5
        FROM    dbo.CrawlRecord cr
                JOIN #tmp t ON cr.CrawlRecordID = t.CrawlRecordId
        WHERE   t.ClientID = @ClientId
                AND t.SEID = @SEId

        INSERT  INTO CrawlGroup( ClientId ,SEID ,StatusFlag ,Priority)
        VALUES  ( @ClientId ,@SEID ,0 ,1 )
          
        SELECT  @CrawlGroupId = SCOPE_IDENTITY()  

        INSERT  CrawlRecordGroup( CrawlRecordId ,CrawlGroupId )
                SELECT  CrawlRecordId ,@CrawlGroupId
                FROM    #tmp t
                WHERE   t.ClientID = @ClientId
                        AND t.SEID = @SEId

        UPDATE  #tmp
        SET     Processed = 1
        WHERE   ClientID = @ClientId
                AND SEID = @SEId
    END 
--ROLLBACK
COMMIT TRAN

        SELECT  crg.*
        FROM    CrawlRecordGroup crg
        WHERE EXISTS (SELECT 1 FROM #tmp WHERE  crg.CrawlRecordID =CrawlRecordId )
                
        SELECT  cr.*
        FROM    CrawlRecord cr
        WHERE EXISTS (SELECT 1 FROM #tmp WHERE  cr.CrawlRecordID =CrawlRecordId )    
                
        SELECT  *
        FROM    CrawlGroup cg
        WHERE EXISTS (SELECT 1 FROM CrawlRecordGroup crg JOIN #tmp t ON crg.CrawlRecordID = t.CrawlRecordId AND crg.CrawlGroupID = cg.CrawlGroupID)
                
        SELECT * 
        FROM dbo.CrawlingErrorLog cel
        WHERE EXISTS (SELECT 1 FROM #tmp WHERE  cel.CrawlRecordID =CrawlRecordId)  
                