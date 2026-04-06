USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcObtenerAutorizCambioIDHW]    Script Date: 04/16/2010 15:56:48 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerAutorizCambioIDHW]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		EXEC ('CREATE FUNCTION [ZL].[funcObtenerAutorizCambioIDHW] (@Serie varchar(7) ) RETURNS int AS BEGIN RETURN 0 END  ')
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcObtenerAutorizCambioIDHW]    Script Date: 04/16/2010 15:56:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<MatiasBuero>
-- Create date: <16-04-2010>
-- Description:	<Obtiene comprobante de autorización de cambio de HW o devuelve 0 >
-- =============================================
ALTER  FUNCTION [ZL].[funcObtenerAutorizCambioIDHW]
(
	@Serie varchar(7)
)
RETURNS int
AS
BEGIN
	
	DECLARE @Result int
	SET @Result = (

		SELECT TOP 1 codin 
		FROM ZL.Autcamhw
		WHERE nroserie = @Serie and cmpfecini > getdate() -1 --> dura un dia el permiso
				and  fchutili = '19000101' and hsutili = '' --no utilizado
		Order by codin asc --para consumir el más viejo en el caso de haber más de 1 para el mismo serie sin utilizar
	
					)
	IF @Result IS NULL SET @Result = 0
	
	RETURN @Result

END

GO


