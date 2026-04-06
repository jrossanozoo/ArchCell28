USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[estadoIssue]    Script Date: 03/07/2013 10:09:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[estadoIssue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[estadoIssue]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[estadoIssue]    Script Date: 03/07/2013 10:09:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Hector Daniel Correa
-- Create date: 06/03/2013
-- Description:	Devuelve 0 (Abierta) o 1 (Cerrada) de una Issue
-- =============================================
CREATE FUNCTION [ZL].[estadoIssue]
(
	-- Add the parameters for the function here
	@Codigo int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Estado int;

  SELECT
    @Estado = 
    CASE 
        WHEN ESTADOS.FECHAC = '19000101' THEN 0 /*ABIERTA*/
        ELSE 1 /*CERRADA*/
      END
  FROM 
    ZL.DTRGISS
    LEFT JOIN (SELECT CODIGO, MIN(FECHAC) AS FECHAC FROM ZL.DTRGISS GROUP BY CODIGO, FECHAC) AS ESTADOS ON ESTADOS.CODIGO = ZL.DTRGISS.CODIGO
  WHERE
    ZL.DTRGISS.CODIGO = @Codigo;
	-- Return the result of the function
	
	RETURN @Estado

END


GO


