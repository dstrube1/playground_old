
SELECT GENERATEDATE,COUNT(1)
FROM siolap.dbo.RPT_PS_CreativeSUMmary_GroupLevel rp 
WHERE GENERATEDATE > '01/01/2011'
AND  SETitleID IS NULL
GROUP BY GENERATEDATE