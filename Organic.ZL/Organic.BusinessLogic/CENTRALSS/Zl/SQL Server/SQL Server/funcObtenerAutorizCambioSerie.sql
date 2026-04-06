USE [ZL]
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerAutorizCambioSerie]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcObtenerAutorizCambioSerie]
GO

USE [ZL]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<MatiasBuero>
-- Create date: <01-11-2010>
-- Description:	<Obtiene comprobante de autorización de cambio de serie>
-- =============================================
CREATE FUNCTION [ZL].[funcObtenerAutorizCambioSerie]
(
	@Serie varchar(7)
)
RETURNS int
AS
BEGIN
	
	DECLARE @Result int
	SET @Result = (
			SELECT TOP 1 [Codin]
      
			FROM [ZL].[ZL].[AUTCAMSE]
  
			WHERE [Fchvence] >= DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)) 
				and [Serieant] = @Serie
				and [Fchutili] = '19000101' and [Hsutili] = ''
			ORDER BY [Codin] ASC
					)
	IF @Result IS NULL SET @Result = 0
	
	RETURN @Result

END


GO
