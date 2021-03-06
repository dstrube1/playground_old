USE [SearchIgnite]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SI_SP_DFATransactionTypeMapping_ReadByClientID]
@ClientID INT
AS
BEGIN
	SET NOCOUNT ON
	SELECT ActionType, ActionName, dm.CustomerTransactionTypeID, DFAActionId, CustomerTransactionName
	FROM dbo.DFATransactionTypeMapping dm left join dbo.v_ClientCustomerTransactionType ct on ct.ClientID = dm.ClientID and ct.CustomerTransactionTypeID = dm.CustomerTransactionTypeID and IsPrimaryOwner = 1
	WHERE dm.ClientID = @ClientID
END

GO
GRANT EXECUTE ON [dbo].[SI_SP_DFATransactionTypeMapping_ReadByClientID] TO [webaccess] AS [dbo]