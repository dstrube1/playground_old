USE [SearchIgnite]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SI_SP_DFATransactionTypeMapping_ReadByClientID]
@MasterClientID INT
AS
/*
03/07/2011 MRS 4.8 Change to read ction types from MasterClientID

[SI_SP_DFATransactionTypeMapping_ReadByClientID] 3830
*/
BEGIN
	SET NOCOUNT ON
	SELECT dm.ClientID, ActionType, ActionName, dm.CustomerTransactionTypeID, DFAActionId, CustomerTransactionName
	FROM dbo.DFATransactionTypeMapping dm 
		left join dbo.v_ClientCustomerTransactionType ct on ct.ClientID = dm.ClientID and ct.CustomerTransactionTypeID = dm.CustomerTransactionTypeID and IsPrimaryOwner = 1
	WHERE dm.ClientID IN (SELECT ClientID FROM External_AdvertiserClient_Mapping WHERE MasterClientID = @MasterClientID)
END

GO
GRANT EXECUTE ON [dbo].[SI_SP_DFATransactionTypeMapping_ReadByClientID] TO [webaccess] AS [dbo]